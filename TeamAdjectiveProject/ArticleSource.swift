//
//  ArticleSource.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/7/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import UIKit

class ArticleSource {
    static var allArticles = [AnyObject]()
    static var topics = [String]()

    static var articleIndex = 0
    static var latestArticleIndex = 0
    
    static var buzzfeedProbabilities = [String : Double]()
    static var nytimesProbabilities = [String : Double]()
    static var typeProbabilities = [String : Double]()
    
    static var wasLoaded = true
    
    static var noTimes : Bool {
        get {
            return NYTimesArticleSource.topics.count == 0
        }
    }
    static var noBuzzfeed : Bool {
        get {
            return (BuzzfeedArticleSource.categories.count == 0)
        }
    }
    
    class func reset() {
        allArticles = []
        articleIndex = 0
        BuzzfeedArticleSource.allBuzzfeedArticles = []
        NYTimesArticleSource.allNYTimesArticles = [:]
        buzzfeedProbabilities = [:]
        typeProbabilities = [:]
    }
    
    class func getArticles() -> Article {
        if articleIndex < allArticles.count {
            return allArticles[articleIndex] as! Article
        } else {
            let article = getNewArticle(Int(Countdown.sharedInstance!.secsRemaining))
            allArticles.append(article)
            return article
        }
    }
    
    class func getProbabilities() {
        UserTracking.getAllStats({ (types) in
            typeProbabilities = UserTracking.calculatePercentage(types, allTopics: Array(types.keys))
            }) { (categories) in
                var nytimesCategories = [String : Double]()
                for (category, percent) in categories {
                    if NYTimesArticleSource.topics.indexOf(category) != nil {
                        nytimesCategories[category] = percent
                    }
                }
                var buzzfeedCategories = [String : Double]()
                for (category, percent) in categories {
                    if BuzzfeedArticleSource.categories.indexOf(category) != nil {
                        buzzfeedCategories[category] = percent
                    }
                }
                //I put this here so that we only have to do the database query for all the statistics once, instead of once for articles and once for videos
                var videoCategories = [String : Double]()
                for (category, percent) in categories {
                    if VideoSource.allVideoCategories.indexOf(category) != nil {
                        videoCategories[category] = percent
                    }
                }
                nytimesProbabilities = UserTracking.calculatePercentage(nytimesCategories, allTopics: NYTimesArticleSource.topics)
                buzzfeedProbabilities = UserTracking.calculatePercentage(buzzfeedCategories, allTopics: BuzzfeedArticleSource.categories)
                VideoSource.videoProbabilities = UserTracking.calculatePercentage(videoCategories, allTopics: VideoSource.allVideoCategories)
        }
    }
    

    
    /*
     * Use when app first loads to preload available articles
     */
    class func preloadData() {
        getProbabilities()
        NYTimesArticleSource.preloadData()
        print("preloading")
        BuzzfeedArticleSource.preloadData()
    }
    
    /*
     * Use to get collection of articles that fits the amount of time
     */
    class func makeArticleList(seconds : Int, completion : ([AnyObject]) -> ()) {
        var secondOne = false
        var articleDict = [String : Article]()
        var nytimesPercent = typeProbabilities["nytimes"]
        var buzzfeedPercent = typeProbabilities["buzzfeed"]
        if nytimesPercent == nil || buzzfeedPercent == nil {
            nytimesPercent = 0.5
            buzzfeedPercent = 0.5
        }
        print("got here")
        NYTimesArticleSource.getArticles(Int(Double(seconds) * nytimesPercent!)) { (articles) in
            for article in articles {
                articleDict[article.url] = Article(time: article.time, url: article.url, rawText: article.rawText, type: "nytimes", category: article.category)
            }
            if secondOne {
                allArticles = Array(articleDict.values)
                completion(allArticles)
            } else {
                secondOne = true
            }
        }
 

        BuzzfeedArticleSource.getArticles(Int(Double(seconds) * buzzfeedPercent!)) { (articles) in
            for article in articles {
                articleDict[article.url] = Article(time: article.time, url: article.url, rawText: article.rawText, type: "buzzfeed", category: article.category)
            }
            if secondOne {
                allArticles = Array(articleDict.values)
                completion(allArticles)
            } else {
                secondOne = true
            }
        }
    }
    
    /*
     * Use if the user runs out of articles to read
     */
    class func getNewArticle(secondsRemaining : Int) -> Article {
        let nytimesCutoff = Int((typeProbabilities["nytimes"] ?? 0.5) * 100)
        let coinFlip = Int(arc4random_uniform(UInt32(100)))
        if (coinFlip < nytimesCutoff || noBuzzfeed) && !noTimes {
            let article = NYTimesArticleSource.getNewArticle(secondsRemaining)
            return Article(time: article.time, url: article.url, rawText: article.rawText, type: "nytimes", category: article.category)
        } else {
            let article = BuzzfeedArticleSource.getNewArticle(secondsRemaining)
            return Article(time: article.time, url: article.url, rawText: article.rawText, type: "buzzfeed", category: article.category)
        }
    }
    
    /*
     * Sets the list of topics for articles
     * No more than 10, 5-ish would be ideal
     */
    class func setTopics(topics : [String]) {
        self.topics = topics
        NYTimesArticleSource.setTopics(topics)
    }
    
    class func setBuzzfeedTopics(topics : [String]) {
        BuzzfeedArticleSource.setTopics(topics)
    }
    
    class func getWordCount(article : Article) -> Int {
        var text = article.rawText
        if text == "" {
            text = downloadPage(article.url)
        }
        let plainText = stripHTML(text)
        return countWithRemovedSpaces(plainText)
    }
    
    private class func countWithRemovedSpaces(string: String) -> Int {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let filtered = components.filter({!$0.isEmpty})
        return filtered.count
    }
    
    private class func stripHTML(page : String) -> String {
        var str = page.stringByReplacingOccurrencesOfString("<script[^<]+</script>", withString: "", options: .RegularExpressionSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        return str
    }
    
    private class func downloadPage(url : String) -> String {
        let myURL = NSURL(string: url)
        if let myURL = myURL {
            do {
                let theHTMLString = try String(contentsOfURL: myURL)
                return theHTMLString
            } catch _ {
                return ""
            }
        } else {
            return ""
        }
    }
}

class Article {
    var time : Double
    var url : String
    var rawText : String
    var type : String
    var category : String
    
    init(time : Double, url : String, rawText : String, type : String, category : String) {
        self.time = time
        self.url = url
        self.rawText = rawText
        self.type = type
        self.category = category
    }

}


class NYTimesArticleSource {
    
    //NOTE : NEED TO TURN OFF APP TRANSPORT SECURITY FOR THIS TO WORK
    
    static var allNYTimesArticles = [String : [NYTimesArticle]]()
    static var sortedNYTimesArticles = [String : [NYTimesArticle]]()
    static var topics = Settings.topicsList
    
    /* Here's the full array of topics:
     
     ["home",
     "opinion",
     "world",
     "national",
     "politics",
     "upshot",
     "nyregion",
     "business",
     "technology",
     "science",
     "health",
     "sports",
     "arts",
     "books",
     "movies",
     "theater",
     "sundayreview",
     "fashion",
     "tmagazine",
     "food",
     "travel",
     "magazine",
     "realestate",
     "automobiles",
     "obituaries",
     "insider"]
     
     */
    
    /*
     * Use when app first loads to preload available articles
     */
    class func preloadData() {
        var shouldLoad = true
        for i in 0..<topics.count {
            let topic = topics[i]
            getArticlesFromAPI(topic, completion: {(articles : [NYTimesArticle]) -> () in
                if i == 0 && allNYTimesArticles.count > 0 {
                    shouldLoad = false
                } else {
                    if shouldLoad {
                        allNYTimesArticles[topic] = articles
                    }
                }
            })
            if !shouldLoad  {
                return
            }
        }
    }
    
    /*
     * Use to get collection of articles that fits the amount of time
     */
    class func getArticles(seconds : Int, completion : ([NYTimesArticle]) -> ()) {
        if topics.count == 0 {
            completion([])
        }
        if allNYTimesArticles.count == 0 {
            for i in 0..<topics.count {
                let topic = topics[i]
                NYTimesArticleSource.getArticlesFromAPI(topic, completion: {(articles : [NYTimesArticle]) -> () in
                    allNYTimesArticles[topic] = articles
                    if i == topics.count - 1 {
                        let articlesInTime = subsetSumIsh(Double(seconds) / 60.0, articles: allNYTimesArticles)
                        completion(articlesInTime)
                    }
                })
            }
        } else {
            let articlesInTime = subsetSumIsh(Double(seconds) / 60.0, articles: allNYTimesArticles)
            completion(articlesInTime)
        }
    }
    
    /*
     * Use if the user runs out of articles to read
     */
    class func getNewArticle(secondsRemaining : Int) -> NYTimesArticle {
        //for (topic, articles) in allNYTimesArticles {
        //    sortedNYTimesArticles[topic] = sortedArticles(articles)
        //    print(sortedNYTimesArticles[topic])
        //}
        sortedNYTimesArticles = allNYTimesArticles
        if allNYTimesArticles.count != 0 {
            let topic = pickTopic(sortedNYTimesArticles)!
            let index = findClosestTime(sortedNYTimesArticles[topic]!, seconds: secondsRemaining)
            let article = sortedNYTimesArticles[topic]![index]
            sortedNYTimesArticles[topic]!.removeAtIndex(index)
            for i in 0..<allNYTimesArticles.count {
                if allNYTimesArticles[topic]![i].url == article.url {
                    allNYTimesArticles[topic]!.removeAtIndex(i)
                    break
                }
            }
            return article
        } else {
            print("No articles to pull from")
            return NYTimesArticle(article: ["url" : "error", "title" : "No More Articles Available", "byline" : ""], category: "")
        }
    }
    
    class func findClosestTime(articles : [NYTimesArticle], seconds : Int) -> Int {
        let minutes = Double(seconds / 60)
        for i in 0..<articles.count {
            if articles[i].time > minutes {
                if i > 0 {
                    if abs(articles[i].time - minutes) < abs(articles[i - 1].time - minutes) {
                        return i
                    } else {
                        return i - 1
                    }
                } else {
                    return i
                }
            }
        }
        return Int(arc4random_uniform(UInt32(allNYTimesArticles.count)))
    }
    
    /*
     * Sets topics to pick articles from
     */
    class func setTopics(topics : [String]) {
        if topics.count > 10 {
            print("too many topics")
            self.topics = Array(topics.prefix(10))
        } else {
            self.topics = topics
        }
    }
    
    private class func sortedArticles(articles : [NYTimesArticle]) -> [NYTimesArticle] {
        return articles.sort() {(article1, article2) -> Bool in article1.time < article2.time}
    }
    
    private class func getArticlesFromAPI(category : String, completion : ([NYTimesArticle]) -> ()) {
        let key = "a2967d1a5ba845e880a477c918b92510"
        let url = NSURL(string: "https://api.nytimes.com/svc/topstories/v2/\(category).json")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "api-key")
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                do {
                    let results = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let articles = results["results"] as? [NSDictionary]
                    if let articles = articles {
                        let allNYTimesArticles = parseData(category, data: articles)
                        completion(allNYTimesArticles)
                    } else {
                        print("An error occured converting results to NSDictionary Array")
                        
                    }
                } catch _ {
                    print("An error occured in parsing JSON to NSDictionary")
                }
            } else {
                print(error)
            }
        }
        task.resume()
    }
    
    private class func parseData(category: String, data : [NSDictionary]) -> [NYTimesArticle] {
        var allNYTimesArticles = [NYTimesArticle]()
        for article in data {
            let nextArticle = NYTimesArticle(article: article, category: category)
            allNYTimesArticles.append(nextArticle)
        }
        return allNYTimesArticles
    }
    
    private class func downloadPage(url : String) -> String {
        let myURL = NSURL(string: url)
        if let myURL = myURL {
            do {
                let theHTMLString = try String(contentsOfURL: myURL)
                return theHTMLString
            } catch _ {
                return ""
            }
        } else {
            return ""
        }
    }
    
    //Sorry for the title - it made me laugh - this is O(n)-ish so it's definitely not subset sum
    private class func subsetSumIsh(total : Double, articles : [String : [NYTimesArticle]]) -> [NYTimesArticle] {
        var time = 0.0
        var chosenArticles = [NYTimesArticle]()
        var remainingArticles = articles

        while time < total && !emptyArrInDict(remainingArticles) {
            let topic = pickTopic(remainingArticles)
            if let topicArticles = remainingArticles[topic!] {
                let randArticle = Int(arc4random_uniform(UInt32(topicArticles.count)))
                time += topicArticles[randArticle].time
                chosenArticles.append(topicArticles[randArticle])
                remainingArticles[topic!]!.removeAtIndex(randArticle)
                if remainingArticles[topic!]!.count == 0 {
                    remainingArticles.removeValueForKey(topic!)
                }
            }
        }
        allNYTimesArticles = remainingArticles
        return chosenArticles
    }
    
    private class func pickTopic(articles : [String : [NYTimesArticle]]) -> String? {
        let sumOfPercents = sumPercents(articles)
        let randTopic = Int(arc4random_uniform(UInt32(100 * sumOfPercents)))
        var total = 0
        for (article, percent) in ArticleSource.nytimesProbabilities {
            if topics.indexOf(article) != nil && articles[article] != nil {
                let cutoff = total + Int(percent * 100)
                if randTopic < cutoff {
                    return article
                }
                total += cutoff
            }
        }
        return nil
    }
    
    private class func sumPercents(articles : [String : [NYTimesArticle]]) -> Double {
        var total = 0.0
        for (article, percent) in ArticleSource.nytimesProbabilities {
            if topics.indexOf(article) != nil && articles[article] != nil {
                total += percent
            }
        }
        return total
    }
    
    private class func emptyArrInDict(dict : [String : [NYTimesArticle]]) -> Bool {
        if dict.count == 0 {
            return true
        }
        for (_, arr) in dict {
            if arr.count != 0 {
                return false
            }
        }
        return true
    }
    
}

class NYTimesArticle {
    private var url : String
    
    private var _rawText : String?
    private var rawText : String {
        get {
            if let _rawText = _rawText {
                return _rawText
            } else {
                _rawText = NYTimesArticleSource.downloadPage(url)
                return _rawText!
            }
        }
    }
    
    var _time : Double?
    var time : Double {
        get {
            if let _time = _time {
                return _time
            } else {
                let plainText = ArticleSource.stripHTML(rawText)
                _time = Double(ArticleSource.countWithRemovedSpaces(plainText)) / 250
                return _time!
            }
        }
    }
    
    var title : String
    var author : String
    var category : String
    
    init(article : NSDictionary, category: String) {
        let url = article["url"] as? String
        let title = article["title"] as? String
        let author = article["byline"] as? String
        self.category = category
        if let url = url, title = title, author = author {
            self.url = url
            self.title = title
            self.author = author
        } else {
            print(article)
            self.url = "error"
            self.title = "Error loading article"
            self.author = ""
            print("Error appending article - cast to string or key access failed")
        }
    }
    
    private class func getTime(words : Int) -> Double {
        return Double(words) / 250.0
    }
    
    class func editArticleText(articleText : String) -> String {
        var newText = articleText.stringByReplacingOccurrencesOfString("<nav id=\"ribbon\"", withString: "<nav id=\"ribbon\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<header id=\"masthead\"", withString: "<header id=\"masthead\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<nav id=\"navigation\"", withString: "<nav id=\"navigation\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<nav id=\"mobile-navigation\"", withString: "<nav id=\"mobile-navigation\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<nav id=\"navigation-edge\"", withString: "<nav id=\"navigation-edge\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<div id=\"TopAd\"", withString: "<nav id=\"TopAd\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString("<div id=\"TragedyAd\"", withString: "<nav id=\"TragedyAd\" style='display:none;'", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if let range = newText.rangeOfString("</article>", options: .LiteralSearch, range: nil, locale: nil) {
            return newText.substringToIndex(range.endIndex)
        }
        return newText
    }

}


class BuzzfeedArticleSource {
    
    // I'm sorry there's a lot of duplicated code here. I'll go clean it up later if I have time. :/
    
    static var allBuzzfeedArticles = [BuzzfeedArticle]()
    static var sortedBuzzfeedArticles = [BuzzfeedArticle]()
    static var categories = Settings.buzzfeedTopicsList
    static var nsfw = false
    
    class func setTopics(topics : [String]) {
        self.categories = topics
    }
    
    class func preloadData() {
        for category in categories {
            getArticlesFromAPI(category) { (articles) in
                self.allBuzzfeedArticles += articles
            }
        }
    }
    
    class func getArticles(seconds : Int, completion : [BuzzfeedArticle] -> ()) {
        if self.categories.count == 0 {
            completion([])
        }
        var chosenBuzzfeedArticles = [BuzzfeedArticle]()
        if self.allBuzzfeedArticles.count > 0 {
            chosenBuzzfeedArticles = subsetSumIsh(Double(seconds) / 60.0, articles: allBuzzfeedArticles)
            completion(chosenBuzzfeedArticles)
        } else {
            for i in 0..<categories.count {
                let category = categories[i]
                getArticlesFromAPI(category, completion: { (articles) in
                    self.allBuzzfeedArticles += articles
                    if i == categories.count - 1 {
                        chosenBuzzfeedArticles = subsetSumIsh(Double(seconds) / 60.0, articles: self.allBuzzfeedArticles)
                        completion(chosenBuzzfeedArticles)
                    }
                })
            }
        }
    }
    
    class func getNewArticle(secondsRemaining : Int) -> BuzzfeedArticle {
        if allBuzzfeedArticles.count != 0 {
            let index = findClosestTime(secondsRemaining)
            let article = allBuzzfeedArticles[index]
            allBuzzfeedArticles.removeAtIndex(index)
            return article
        } else {
            print("No articles to pull from")
            return BuzzfeedArticle(title: "Article Not Found", rawText: "No articles could be found to display.", url: "error", category: "error")
        }

    }
    
    class func findClosestTime(seconds : Int) -> Int {
        let minutes = Double(seconds / 60)
        for i in 0..<sortedBuzzfeedArticles.count {
            if sortedBuzzfeedArticles[i].time > minutes {
                if i > 0 {
                    if abs(sortedBuzzfeedArticles[i].time - minutes) < abs(sortedBuzzfeedArticles[i - 1].time - minutes) {
                        return i
                    } else {
                        return i - 1
                    }
                } else {
                    return i
                }
            }
        }
        return Int(arc4random_uniform(UInt32(allBuzzfeedArticles.count)))
    }
    
    private class func sortedArticles(articles : [BuzzfeedArticle]) -> [BuzzfeedArticle] {
        return articles.sort() {(article1, article2) -> Bool in article1.time < article2.time}
    }
    
    private class func getArticlesFromAPI(category : String, completion : ([BuzzfeedArticle]) -> ()) {
        let url = NSURL(string: "http://www.buzzfeed.com/api/v2/feeds/\(category)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                do {
                    let results = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let articles = results["buzzes"] as? [NSDictionary]
                    if let articles = articles {
                        parseData(category, articles: articles, completion: {
                            completion(allBuzzfeedArticles)
                            }
                        )
                    } else {
                        print("An error occured converting results to NSDictionary Array")
                    }
                } catch _ {
                    print("An error occured in parsing JSON to NSDictionary")
                }
            } else {
                print(error)
            }
        }
        task.resume()
    }
    
    private class func parseData(category: String, articles : [NSDictionary], completion : Void -> Void) {
        for article in articles {
            let username = article["username"] as? String
            let uri = article["uri"] as? String
            let title = article["title"] as? String
            var isnsfw = false
            let flags = article["flags"] as? NSDictionary
            if let flags = flags {
                if Int(flags["nsfw"] as! String)! != 0 {
                    isnsfw = true
                }
            }
            let language = article["language"] as? String
            var isEnglish = false
            if let language = language {
                isEnglish = language == "en"
            }
            if !isnsfw && isEnglish { //|| self.nsfw == isnsfw {
                if let username = username, uri = uri, title = title {
                    let url = "https://www.buzzfeed.com/\(username)/\(uri)"
                    let rawText = "" //this is needed for the Article class, but downloading Buzzfeed articles is too time intensive - it's done in the webview
                    allBuzzfeedArticles.append(BuzzfeedArticle(title: title, rawText: rawText, url: url, category: category))
                }
            }
        }
        completion()
        
    }
    
    private class func getArticleText(url : String) -> String {
        return downloadPage(url)
    }
    
    private class func downloadPage(url : String) -> String {
        let myURL = NSURL(string: url)
        if let myURL = myURL {
            do {
                let theHTMLString = try String(contentsOfURL: myURL)
                return theHTMLString
            } catch _ {
                return ""
            }
        } else {
            return ""
        }
    }
    
    private class func subsetSumIsh(total : Double, articles : [BuzzfeedArticle]) -> [BuzzfeedArticle] {
        var time = 0.0
        var chosenArticles = [BuzzfeedArticle]()
        var remainingArticles = articles
        
        while time < total && remainingArticles.count != 0 {
            let randArticle = Int(arc4random_uniform(UInt32(remainingArticles.count)))
            time += remainingArticles[randArticle].time
            chosenArticles.append(remainingArticles[randArticle])
            remainingArticles.removeAtIndex(randArticle)
        }
        allBuzzfeedArticles = remainingArticles
        return chosenArticles
    }
    
}

class BuzzfeedArticle {
    var title : String
    var rawText : String
    var _time : Double?
    var time : Double {
        get {
            if let _time = _time {
                return _time
            } else {
                let page = ArticleSource.downloadPage(url)
                let plainText = ArticleSource.stripHTML(page)
                _time = Double(ArticleSource.countWithRemovedSpaces(plainText)) / 250
                return _time!
            }
        }
    }
    var url : String
    var category : String
    
    init(title : String, rawText : String, url : String, category : String) {
        self.rawText = rawText
        self.title = title
        self.url = url
        self.category = category
    }

}

