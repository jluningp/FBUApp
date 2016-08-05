//
//  UserTracking.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/19/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class UserTracking {
    static var ref = FIRDatabase.database().reference()
    static var authID : String?
    static var _userID : String?
    static var userID : String {
        get {
            if let _userID = _userID {
                return _userID
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let id = defaults.stringForKey("userID") {
                    _userID = id
                } else {
                    let id = generateUID()
                    defaults.setObject(id, forKey: "userID")
                    _userID = id
                }
                return _userID!
            }
        }
    }
    
    static var currentArticles = [String: TrackedArticle]()
    static var allArticles = [String: TrackedArticle]()
    
    //generates a random ten-digit number as a user id
    class func generateUID() -> String {
        var uid = ""
        for _ in 0..<10 {
            let rand = arc4random_uniform(UInt32(10))
            uid += "\(rand)"
        }
        return uid
    }
    
    // Configures Firebase and signs the app in to the only account - this only needs to be called once
    class func initialize() {
        FIRApp.configure()
        FIRAuth.auth()?.signInWithEmail("jluningp@fb.com", password: "AtBV6xdOwMTK") { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                authID = user.uid
            } else {
                print("a strange error occured")  //idk what it means if there's no error and no user ¯\_(ツ)_/¯
            }
        }
    }
    
    class func getArticlesInfo(completion : [String: TrackedArticle] -> Void){
        var allArticles = [String: TrackedArticle]()
        ref.child(userID).child("data").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let articleData = snap.value as? NSDictionary {
                        let url = articleData["url"] as? String
                        let time = articleData["timeSpent"] as? Int
                        let type = articleData["type"] as? String
                        let estimatedTime = articleData["estimatedTime"] as? Int
                        let category = articleData["category"] as? String
                        if let url=url, time=time, type=type, estimatedTime=estimatedTime, category=category {
                            allArticles[stripURL(url)] = TrackedArticle(url: url, type: type, timeSpent: time, estimatedTime: estimatedTime, category: category)
                        }
                    }
                }
                completion(allArticles)
            }
        })
    }
    
    class func stripURL(url : String) -> String {
        if url == "" {
            print("url was empty")
            return "error"
        }
        var newURL = url.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newURL = newURL.stringByReplacingOccurrencesOfString("#", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newURL = newURL.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newURL = newURL.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newURL = newURL.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newURL = newURL.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return newURL
    }
    
    class func getArticleInfo(url: String, completion : TrackedArticle? -> Void){
        ref.child(userID).child("data").child(stripURL(url)).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            var article : TrackedArticle?
            if let articleData = snapshot.value as? NSDictionary {
                let url = articleData["url"] as? String
                let time = articleData["time"] as? Int
                let type = articleData["type"] as? String
                let estimatedTime = articleData["estimatedTime"] as? Int
                let category = articleData["category"] as? String
                if let url=url, time=time, type=type, estimatedTime=estimatedTime, category=category {
                    article = TrackedArticle(url: url, type: type, timeSpent: time, estimatedTime: estimatedTime, category: category)
                }
            }
            completion(article)
        })
    }
    
    class func analyzeData() {
        getArticlesInfo { (allArticles) in
            //Make this asynchronous
            for (_, article) in allArticles {
                article.timePerWord = Double(article.timeSpent) / Double(article.estimatedTime)
            }
            var categoryStats = [String: Stats]()
            for (_, article) in allArticles {
                let stats = Stats(estimatedTime: article.estimatedTime, timeSpent: article.timeSpent, category: article.category, type: article.type, average: 0)
                if categoryStats[article.category] != nil {
                    categoryStats[article.category]!.estimatedTime += stats.estimatedTime
                    categoryStats[article.category]!.timeSpent += stats.timeSpent
                } else {
                    categoryStats[article.category] = stats
                }
            }
            for (category, stats) in categoryStats {
                categoryStats[category]!.average = Double(stats.timeSpent) / Double(stats.estimatedTime)
            }
            
            //Want to rank topics based on which causes highest time per word
            //Want to rank types based on which causes hightest time per word
            
            //Store probabilities of each category and type and wordcount in firebase
            //First three categories get the first 50% of articles at 25%, 15%, and 10% and all others are uniform probability across the other 50%
            //Only two types - can I get a % that one is better than the other? Like, on average, people spend x% more time/word on buzzfeed, so buzzfeed should be x% more common
        }
    }

    class func sendUpdates(article : TrackedArticle) {
        let userRef = ref.child(userID).child("data").child(stripURL(article.url))
        userRef.setValue(["url": article.url, "type": article.type, "timeSpent": article.timeSpent, "estimatedTime": article.estimatedTime, "category": article.category])
        updateStats(article)
    }
    
    class func updateStats(article : TrackedArticle) {
        let userRefTotals = ref.child(userID).child("stats").child(article.type).child(article.category)
        getStat(article) { (stats) in
            if let stats = stats {
                let totalTimeSpent = stats.timeSpent + article.timeSpent
                let totalEstimatedTime = stats.estimatedTime + article.estimatedTime
                let average = Double(totalTimeSpent) / Double(totalEstimatedTime)
                userRefTotals.setValue(["estimatedTime" : totalEstimatedTime, "timeSpent" : totalTimeSpent, "average" : average])
            } else {
                let average : Double = Double(article.timeSpent) / Double(article.estimatedTime)
                userRefTotals.setValue(["estimatedTime" : article.estimatedTime, "timeSpent" : article.timeSpent, "average" : average])
            }
        }
    }
    
    class func getStat(article : TrackedArticle, completion : Stats? -> Void) {
        ref.child(userID).child("stats").child(article.type).child(article.category).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let statsData = snapshot.value as? NSDictionary {
                let estimatedTime = statsData["estimatedTime"] as? Int
                let timeSpent = statsData["timeSpent"] as? Int
                let average = statsData["average"] as? Double
                if let estimatedTime = estimatedTime, timeSpent = timeSpent, average = average {
                    completion(Stats(estimatedTime: estimatedTime, timeSpent: timeSpent, category: article.category, type: article.type, average: average))
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        })
        
    }
    
    class func clearData() {
        ref.child(userID).setValue([:])
    }
    
    class func getAllStats(typesCompletion : [String : Double] -> Void, categoryCompletion : [String : Double] -> Void) {
        var categoryStats = [String : Double]()
        var typeStats = [String : Double]()
        ref.child(userID).child("stats").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let statsData = snapshot.value as? NSDictionary {
                for (type, data) in statsData {
                    let categoryData = data as? NSDictionary
                    if let categoryData = categoryData {
                        var typeTotalEst = 0.0
                        var typeTotalSpent = 0.0
                        for (category, stats) in categoryData {
                            if let statDict = stats as? NSDictionary {
                                categoryStats[category as! String] = statDict["average"] as? Double
                                typeTotalEst += Double(statDict["estimatedTime"] as! Int)
                                typeTotalSpent += Double(statDict["timeSpent"] as! Int)
                            }
                        }
                        if typeTotalEst != 0.0 {
                            typeStats[type as! String] = typeTotalSpent / typeTotalEst
                        }
                    }
                    
                }
            }
            typesCompletion(typeStats)
            categoryCompletion(categoryStats)
        })
    }
    
    class func calculatePercentage(averages : [String : Double], allTopics : [String]) -> [String : Double] {
        var percentages = [String : Double]()
        var summed = 0.0
        for (_, avg) in averages {
            summed += avg
        }
        
        var missingTopics = [String]()
        for topic in allTopics {
            if averages[topic] == nil {
                missingTopics.append(topic)
            }
        }
        if missingTopics.count == 0 {
            for (type, avg) in averages {
                percentages[type] = avg / summed
            }
        } else {
            for (type, avg) in averages {
                percentages[type] = (avg / summed) / 2
            }
            let numMissing = Double(missingTopics.count)
            for missing in missingTopics {
                percentages[missing] = 0.5 / numMissing
            }
            
        }
        return percentages
    }
    
    class func updateReadArticles(url : String, type : String, category : String, estimatedTime : Int, time : Int) {
        if let prevEntry = currentArticles[stripURL(url)] {
            let entry = TrackedArticle(url: url, type: type, timeSpent: time + prevEntry.timeSpent, estimatedTime: estimatedTime, category: category)
            currentArticles[stripURL(url)] = entry
            allArticles[stripURL(url)] = entry
            sendUpdates(entry)
        } else {
            getArticleInfo(url, completion: { (article) in
                if let article = article {
                    let entry = TrackedArticle(url: url, type: type, timeSpent: time + article.timeSpent, estimatedTime: estimatedTime, category: category)
                    currentArticles[stripURL(url)] = entry
                    allArticles[stripURL(url)] = entry
                    sendUpdates(entry)
                } else {
                    let entry = TrackedArticle(url: url, type: type, timeSpent: time, estimatedTime: estimatedTime, category: category)
                    currentArticles[stripURL(url)] = entry
                    allArticles[stripURL(url)] = entry
                    sendUpdates(entry)
                }
            })
        }
    }
    
    class func getKeyFromDatabase(article : TrackedArticle) -> String? {
        return nil
    }
    
}

class TrackedArticle {
    var url : String
    var type : String
    var timeSpent : Int
    var estimatedTime : Int
    var category : String
    var timePerWord : Double?
    
    init(url : String, type: String, timeSpent : Int, estimatedTime: Int, category: String) {
        self.url = url
        self.type = type
        self.timeSpent = timeSpent
        self.estimatedTime = estimatedTime
        self.category = category
    }
}

struct Stats {
    var estimatedTime = 0
    var timeSpent = 0
    var category = ""
    var type = ""
    var average : Double = 0.0
}