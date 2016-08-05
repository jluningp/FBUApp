//
//  VideoSource.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/13/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import p2_OAuth2

class VideoSource: AnyObject {
    
    static let apiKey = "AIzaSyD4wlkCmkmAKNtdf-nNoQCDVgJYfEnk7yc"
    static var pageToken = ""
    static var reachedFinalPage = false
    static var allVideoCategories = ["home", "mostPopular", "animals", "sports", "vlogs", "gaming", "music"]
    
    static var videoProbabilities = [String : Double]()
    
    // Fetch the same number of videos per request/category, with 50 total
    static var maxNumOfVideosPerRequest : Int {
        get { return Int(50/Settings.videoCategories.count) }
    }
    
    static var fetchedVideos = [Video]()
    static var unplayedVideos = [Video]()
    static var playedVideos = [Video]()
    static var playedVideosIds = [String]()
    //static var selectedCategories = [String]()
    //static var selectedCategories: Set<String> = []
    static var authorizedNotificationKey = "com.WaitForIt.AuthorizedKey"
    static var unAuthorizedNotificationKey = "com.WaitForIt.unAuthorizedKey"
    static var videoCategoriesDisplay = ["YouTube - Sign In", "Your Recommended Videos", "Most Popular",  "Animals", "Gaming", "Sports", "Vlogs", "Music"]
    static var username: String? = nil
    static var prevRequestCategories: [String] = [String]()
    
    static let oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "844433410634-3utiiauoea914ji6mkth2jrjtm1qdu13.apps.googleusercontent.com",
        "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://www.googleapis.com/oauth2/v3/token",
        "scope": "https://www.googleapis.com/auth/youtube.readonly",
        "redirect_uris": ["com.googleusercontent.apps.844433410634-3utiiauoea914ji6mkth2jrjtm1qdu13:/oauth"],
        "response_type": "code"
        ])
    
    // !! check if videos of this category are actually there first
    class func removeVideosOfCategory(category: String) {
        print("unplayedVideos count: ", unplayedVideos.count)
        if (!unplayedVideos.isEmpty) {
            for i in (0..<unplayedVideos.count).reverse() {
                
                //print("deleting [\(i)]: \(unplayedVideos[i])")
                
                if unplayedVideos[i].category == category {
                    unplayedVideos.removeAtIndex(i)
                }
            }
        }
    }
    
    class func removeDeselectedVideoCategories() {
        if (!unplayedVideos.isEmpty) {
            for i in (0 ..< unplayedVideos.count).reverse() {
                
                print("deleting [\(i)]: \(unplayedVideos[i])")
                let currentVideoCategory = unplayedVideos[i].category
                if !Settings.videoCategories.contains(currentVideoCategory){
                    unplayedVideos.removeAtIndex(i)
                }
            }
        }
    }
    
    class func revokeAccess() {
        oauth2.forgetTokens()
        VideoSource.username = nil
    }
    
    class func authorize() {
        oauth2.authorize()
    }
    
    class func isAuthorized() -> Bool {
        return oauth2.hasUnexpiredAccessToken()
    }
    
    class func setupOAuth() {
        oauth2.onFailure = { error in        // `error` is nil on cancel
            if let error = error {
                print("OAuth error: \(error)")
                
                NSNotificationCenter.defaultCenter().postNotificationName(VideoSource.unAuthorizedNotificationKey, object: self)
                
                let alert = UIAlertController(title: "Alert", message: "Error signing in to YouTube.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: {action in
                    authorize()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            }
        }
        
        oauth2.onAuthorize = { parameters in
            NSNotificationCenter.defaultCenter().postNotificationName(VideoSource.authorizedNotificationKey, object: self)
            
            fetchCurrentUsername({ (username) in
                VideoSource.username = username
            })
        }
        
        
    }
    
    private class func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        
        let req = oauth2.request(forURL: targetURL) // will log about signing request if not logged in
        // set up your request, e.g. `req.HTTPMethod = "POST"`
        let task = oauth2.session.dataTaskWithRequest(req) { data, response, error in
            if let error = error {
                print("oauth2 error: \(error)")
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
                    
                })
            }
        }
        
        task.resume()
    }
    
    private class func getUrlString(category: String) -> String {
        
        let mostPopularResponseFields = "items(contentDetails/duration,id,snippet(categoryId,channelTitle,description,publishedAt,thumbnails,title),statistics(dislikeCount,likeCount,viewCount)),nextPageToken,pageInfo,prevPageToken,tokenPagination"
        let mostPopularResponseParts = "snippet,contentDetails,statistics"
        
        if (category == "mostPopular") {
            //            return "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&key=\(VideoSource.apiKey)&pageToken=\(VideoSource.pageToken)&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&part=snippet,contentDetails&fields=items/id,items/snippet/title,items/contentDetails/duration,nextPageToken,prevPageToken,pageInfo"
            
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=10&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        else if (category == "home") {
            return "https://www.googleapis.com/youtube/v3/activities?part=snippet%2CcontentDetails&home=true&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&fields=items(contentDetails(recommendation%2FresourceId%2FvideoId%2Cupload)%2Csnippet(title%2Ctype))%2CnextPageToken%2CpageInfo%2CprevPageToken%2CtokenPagination&key=\(VideoSource.apiKey)"
        }
        else if category == "animals" {
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=15&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        else if category == "sports" {
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=17&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        else if category == "vlogs" {
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=22&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        else if category == "gaming" {
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=20&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        else if category == "music" {
            return "https://www.googleapis.com/youtube/v3/videos?part=\(mostPopularResponseParts)&chart=mostPopular&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&videoCategoryId=10&fields=\(mostPopularResponseFields)&pageToken=\(VideoSource.pageToken)&key=\(VideoSource.apiKey)"
        }
        
        
        return ""
    }
    
    class func fetchVideoData(category: String, completion: ([Video]) -> Void) {
        //print("pageToken: \(VideoSource.pageToken)")
        
        
        
        let urlString: String = getUrlString(category)
        let targetURL = NSURL(string: urlString)
        
        VideoSource.performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary.
                var resultsDict = Dictionary<NSObject, AnyObject>()
                
                do {
                    resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                }
                catch let error as NSError {
                    print("json error: \(error)")
                }
                
                if let token = resultsDict["nextPageToken"] as? String {
                    self.pageToken = token
                }
                else {
                    self.pageToken = "" //restart from beginning?
                    self.reachedFinalPage = true
                }
                
                let items: AnyObject! = resultsDict["items"] as AnyObject!
                
                if (category == "home") {
                    VideoSource.parseHomeVideos(items) { (parsedVideos) ->Void in
                        completion(parsedVideos)
                    }
                }
                    //                else if (category == "mostPopular") {
                    //                    let parsedVideos = VideoSource.parseMostPopularVideos(items)
                    //                    completion(parsedVideos)
                    //                }
                else  {
                    let parsedVideos = VideoSource.parseMostPopularVideos(category, items: items)
                    completion(parsedVideos)
                }
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error fetching video data: \(error)")
                
                var resultsDict = Dictionary<NSObject, AnyObject>()
                
                do {
                    resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                }
                catch let error as NSError {
                    print("json error: \(error)")
                }
                
                print("fetching video data: \(resultsDict)")
            }
        })
        
        
    }
    
    private class func paginatedFetchVideoData(category: String, completion: ([Video]) -> ()) {
        //let category = category
        var urlString: String!
        print("paginated pageToken: \(VideoSource.pageToken)")
        urlString = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&key=\(VideoSource.apiKey)&pageToken=\(VideoSource.pageToken)&maxResults=\(VideoSource.maxNumOfVideosPerRequest)&part=snippet,contentDetails&fields=items/id,items/snippet/title,items/contentDetails/duration,nextPageToken,prevPageToken,pageInfo"
        let targetURL = NSURL(string: urlString)
        
        VideoSource.performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary.
                var resultsDict = Dictionary<NSObject, AnyObject>()
                
                do {
                    resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                }
                catch let error as NSError {
                    print("json error: \(error)")
                }
                
                if let token = resultsDict["nextPageToken"] as? String {
                    self.pageToken = token
                }
                else {
                    self.pageToken = "" //restart from beginning?
                    self.reachedFinalPage = true
                }
                
                // Get the first dictionary item from the returned items (usually there's just one item).
                let items: AnyObject! = resultsDict["items"] as AnyObject!
                
                var fetchedVideos = [Video]()
                for i in 0..<items.count {
                    let currentItem = (items as! Array<AnyObject>)[i] as! Dictionary<NSObject, AnyObject>
                    
                    var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    
                    desiredValuesDict["id"] = currentItem["id"]
                    
                    // Get the snippet dictionary that contains the desired data.
                    let snippetDict = currentItem["snippet"] as! Dictionary<NSObject, AnyObject>
                    desiredValuesDict["title"] = snippetDict["title"]
                    
                    let contentDetailsDict = currentItem["contentDetails"] as! Dictionary<NSObject, AnyObject>
                    
                    desiredValuesDict["duration"] =  contentDetailsDict["duration"] as! String
                    
                    
                    let video = Video(videoDictionary: desiredValuesDict)
                    
                    fetchedVideos.append(video)
                    
                }
                
                //sort videos in descending order by duration to support smarter selection
                fetchedVideos = fetchedVideos.sort { $0.duration > $1.duration }
                
                completion(fetchedVideos)
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error:\(error)")
                print("Data: \(data)")
            }
        })
        
        
    }
    
    class func fetchCurrentUsername(fetchCurrentUsernameCompletion: (String) -> ()) {
        let targetURL = NSURL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true&fields=items(snippet%2Ftitle)&key=\(VideoSource.apiKey)")
        
        VideoSource.performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                
                // Convert the JSON data to a dictionary.
                var resultsDict = Dictionary<NSObject, AnyObject>()
                
                do {
                    resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                }
                catch let error as NSError {
                    print("json error: \(error)")
                }
                
                if let token = resultsDict["nextPageToken"] as? String {
                    self.pageToken = token
                }
                else {
                    self.pageToken = "" //restart from beginning?
                    self.reachedFinalPage = true
                }
                
                let items: [AnyObject] = resultsDict["items"] as! [AnyObject]
                let currentItem = items[0] as! Dictionary<NSObject, AnyObject> // there is usually only one channel per account
                
                let snippetDict = currentItem["snippet"] as! Dictionary<NSObject, AnyObject>
                
                let username = snippetDict["title"] as! String
                
                fetchCurrentUsernameCompletion(username)
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                print("Error data: \(data)")
                
            }
        })
    }
    
    private class func fetchVideoDataFromIds(videoIdArray: [String], fetchVideoDataFromIdsCompletion: ([Dictionary<String, AnyObject>]) -> ()) {
        var videoIdString = ""
        
        for id in videoIdArray {
            videoIdString += id
            if id != videoIdArray.last {
                videoIdString += "%2C"
            }
        }
        
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=\(videoIdString)&fields=items(contentDetails%2Fduration%2Cid%2Csnippet(categoryId%2CchannelTitle%2Cdescription%2CpublishedAt%2Cthumbnails%2Ctitle)%2Cstatistics(dislikeCount%2ClikeCount%2CviewCount))%2CnextPageToken%2CpageInfo%2CprevPageToken%2CtokenPagination&key=\(VideoSource.apiKey)"
        
        
        let targetURL = NSURL(string: urlString)
        
        
        VideoSource.performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                
                // Convert the JSON data to a dictionary.
                var resultsDict = Dictionary<NSObject, AnyObject>()
                
                do {
                    resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                }
                catch let error as NSError {
                    print("json error: \(error)")
                }
                
                if let token = resultsDict["nextPageToken"] as? String {
                    self.pageToken = token
                }
                else {
                    self.pageToken = "" //restart from beginning?
                    self.reachedFinalPage = true
                }
                
                let items: [AnyObject] = resultsDict["items"] as! [AnyObject]
                
                var desiredValuesDictArray: [Dictionary<String, AnyObject>] = [Dictionary<String, AnyObject>]()
                
                for i in 0..<items.count {
                    let currentItem = items[i] as! Dictionary<NSObject, AnyObject>
                    let contentDetails = currentItem["contentDetails"] as! Dictionary<NSObject, AnyObject>
                    let snippetDict = currentItem["snippet"] as! Dictionary<NSObject, AnyObject>
                    let statsDict = currentItem["statistics"] as! Dictionary<NSObject, AnyObject>
                    
                    var currentDesiredValuesDict = Dictionary<String, AnyObject>()
                    
                    
                    currentDesiredValuesDict["category"] = "home"
                    currentDesiredValuesDict["title"] = snippetDict["title"]
                    currentDesiredValuesDict["publishedAt"] = snippetDict["publishedAt"]
                    currentDesiredValuesDict["description"] = snippetDict["description"]
                    currentDesiredValuesDict["channelTitle"] = snippetDict["channelTitle"]
                    currentDesiredValuesDict["thumbnails"] = snippetDict["thumbnails"]
                    
                    currentDesiredValuesDict["viewCount"] = statsDict["viewCount"]
                    currentDesiredValuesDict["likeCount"] = statsDict["likeCount"]
                    currentDesiredValuesDict["dislikeCount"] = statsDict["dislikeCount"]
                    
                    let duration = contentDetails["duration"] as! String
                    
                    currentDesiredValuesDict["duration"] = duration
                    currentDesiredValuesDict["id"] = videoIdArray[i]
                    
                    
                    
                    
                    desiredValuesDictArray.append(currentDesiredValuesDict)
                    //durationArray.append(duration)
                }
                
                
                
                fetchVideoDataFromIdsCompletion(desiredValuesDictArray)
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                
            }
        })
        
    }
    
    private class func parseHomeVideos(items: AnyObject, parseCompletion: ([Video]) -> ()) {
        
        var fetchedVideos = [Video]()
        
        var videoIds: [String] = []
        
        
        
        for i in 0..<items.count {
            
            let currentItem = (items as! Array<AnyObject>)[i] as! Dictionary<NSObject, AnyObject>
            let snippetDict = currentItem["snippet"] as! Dictionary<NSObject, AnyObject>
            let contentDetails = currentItem["contentDetails"] as! Dictionary<NSObject, AnyObject>
            let videoType = snippetDict["type"] as! String
            
            if (videoType == "upload") {
                videoIds.append(contentDetails["upload"]!["videoId"] as! String)
            }
            else if (videoType == "recommendation") {
                videoIds.append(contentDetails["recommendation"]!["resourceId"]!!["videoId"] as! String)
            }
            

            
            //desiredValuesDictArray.append(currentDesiredValuesDict)
        }
        
        fetchVideoDataFromIds(videoIds) { (videoDicts: [Dictionary<String, AnyObject>]) in
            // id and category and title need to be set at the same time as duration b/c the object is created with a dictionary with all the info
            for i in 0..<items.count {
                let video = Video(videoDictionary: videoDicts[i])
                fetchedVideos.append(video)
            }
            
            //sort videos in descending order by duration to support smarter selection
            fetchedVideos = fetchedVideos.sort { $0.duration > $1.duration }
            
            parseCompletion(fetchedVideos)
        }
        
    }
    
    private class func parseMostPopularVideos(category: String, items: AnyObject) -> [Video] {
        
        var fetchedVideos = [Video]()
        for i in 0..<items.count {
            let currentItem = (items as! Array<AnyObject>)[i] as! Dictionary<NSObject, AnyObject>
            
            var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            
            desiredValuesDict["id"] = currentItem["id"]
            
            // Get the snippet dictionary that contains the desired data.
            let snippetDict = currentItem["snippet"] as! Dictionary<NSObject, AnyObject>
            desiredValuesDict["title"] = snippetDict["title"]
            desiredValuesDict["publishedAt"] = snippetDict["publishedAt"]
            desiredValuesDict["description"] = snippetDict["description"]
            desiredValuesDict["channelTitle"] = snippetDict["channelTitle"]
            desiredValuesDict["thumbnails"] = snippetDict["thumbnails"]
            
            
            let contentDetailsDict = currentItem["contentDetails"] as! Dictionary<NSObject, AnyObject>
            desiredValuesDict["duration"] =  contentDetailsDict["duration"] as! String
            
            
            let statsDict = currentItem["statistics"] as! Dictionary<NSObject, AnyObject>
            
            desiredValuesDict["viewCount"] = statsDict["viewCount"] as! String
            if let likeCount = statsDict["likeCount"] as? String
            {
                desiredValuesDict["likeCount"] = likeCount
            }
            if let dislikeCount = statsDict["dislikeCount"] as? String {
                desiredValuesDict["dislikeCount"] = dislikeCount
            }
            
            desiredValuesDict["category"] = category
            
            let video = Video(videoDictionary: desiredValuesDict)
            
            fetchedVideos.append(video)
            
        }
        
        fetchedVideos = fetchedVideos.sort { $0.duration > $1.duration }
        
        return fetchedVideos
    }
    
    class func preloadVideoForCategory(category: String, preloadVideoDatacompletion: ([Video]) -> ()) {
        
        VideoSource.fetchVideoData(category) { (parsedVideos:[Video]) in
            for video in parsedVideos {
                // append not set equal in case preloadVideoData is called multiple times
                self.fetchedVideos.append(video)
                self.unplayedVideos.append(video)
            }
            
            preloadVideoDatacompletion(parsedVideos)
        }
    }
    
    class func preloadVideoForSelectedCategories(preloadVideoDatacompletion: ([Video]) -> ()) {
        
        var videosFromAllCategories: [Video] = [Video]()
        
        let serviceGroup = dispatch_group_create()
        
        print("--- previous categories:", prevRequestCategories)
        print("----selected categories in preload selected: ", Settings.videoCategories)
        
        if prevRequestCategories != Settings.videoCategories {
            
            // make sure that prevRequestCategories is only per session and isn't persistently stored like Settings.videoCategories
            for category in Settings.videoCategories {
                print("category: ", category)
                prevRequestCategories.append(category)
            }
            
            for category in Settings.videoCategories {
                dispatch_group_enter(serviceGroup)
                VideoSource.fetchVideoData(category) { (parsedVideos:[Video]) in
                    //print("------preloadvideoforselected categories > fetch video data completion:")
                    for video in parsedVideos {
                        
                        // append not set equal in case preloadVideoData is called multiple times
                        self.fetchedVideos.append(video)
                        self.unplayedVideos.append(video)
                        
                        //print(video.title)
                    }
                    
                    videosFromAllCategories.appendContentsOf(parsedVideos)
                    //print("videosfromallcategories: \(videosFromAllCategories)")
                    dispatch_group_leave(serviceGroup)
                }
            }
            
            dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
                
                videosFromAllCategories = videosFromAllCategories.sort { $0.duration > $1.duration }
                
                VideoSource.fetchedVideos = videosFromAllCategories
                VideoSource.unplayedVideos = videosFromAllCategories
                
                preloadVideoDatacompletion(videosFromAllCategories)
            }
        }
        else {
            print("Video categories haven't changed since last pull so I won't fetch again yet")
            preloadVideoDatacompletion(VideoSource.unplayedVideos)
        }
        
    }
    
    
    class func loadVideosInBackground(category: String) {
        VideoSource.fetchVideoData(category) { (parsedVideos:[Video]) in
            for video in parsedVideos {
                
                // append not set equal in case preloadVideoData is called multiple times
                self.fetchedVideos.append(video)
                self.unplayedVideos.append(video)
            }
        }
    }
    
    class func getVideoTitle(videoId: String? = nil) -> String {
        if let id = videoId {
            let playedVideoIndex = playedVideosIds.indexOf(id)
            
            if let index = playedVideoIndex {
                //print("looking up index: \(playedVideos[index].title)")
                return playedVideos[index].title
            }
            
        }
        else if playedVideos.count > 0 {
            //print("most recent title: \(playedVideos.last!.title)")
            return playedVideos.last!.title
        }
        
        //print("returning empty string for video title")
        return ""
    }
    
    class func getNextVideo(remainingTime: Int) -> Video {
        var longestFitVideo = self.unplayedVideos[0]
        
        // fetched videos is already sorted so the first choice is the longestFitVideo
        for i in 0..<self.unplayedVideos.count {
            let video = self.unplayedVideos[i]
            
            if (Double(video.duration) <= Double(remainingTime)*1.1) {
                self.unplayedVideos.removeAtIndex(i)
                longestFitVideo = video
                //print("accepting this video : \(video.duration): \(video.title), difference: \(video.duration - remainingTime)")
                
                self.playedVideos.append(longestFitVideo)
                self.playedVideosIds.append(longestFitVideo.id)
                
                return longestFitVideo
            }
        }
        
        if self.unplayedVideos.count >= 1 {
            let count = UInt32(truncatingBitPattern: self.unplayedVideos.count)
            let randomInt = Int(arc4random_uniform(count))
            let randomVideo = self.unplayedVideos[randomInt]
            //print("none of the videos fit so choose a random \(randomInt)th one: \(randomVideo.duration): \(randomVideo.title)")
            longestFitVideo = randomVideo
            
            self.playedVideos.append(longestFitVideo)
            self.playedVideosIds.append(longestFitVideo.id)
            
            return longestFitVideo
        }
        
        
        // what to do if there are no videos to return? how to throw an error?
        let defaultVideoDict = ["id" : "IrpjOLPuxrg", "title": "Ultimate Fails Compilation 2014 || FailArmy Best Fails of the Year", "duration": "PT25M22S"]
        let defaultVideo = Video(videoDictionary: defaultVideoDict)
        //print("choosing default video : \(defaultVideo.duration): \(defaultVideo.title)")
        longestFitVideo = defaultVideo
        
        self.playedVideos.append(longestFitVideo)
        self.playedVideosIds.append(longestFitVideo.id)
        
        return longestFitVideo
    }
    
    class func getPrevVideoId(currentVideoId: String) -> String {
        
        if let currentIndex = self.playedVideosIds.indexOf(currentVideoId) {
            var prevIndex = 0
            if currentIndex > 0 {
                prevIndex = currentIndex - 1
                
            }
            return self.playedVideos[prevIndex].id
        }
        else {
            print("Somehow that id was not previously played.")
            return ""
        }
        
    }
    
}