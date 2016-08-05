//
//  Video.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/13/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class Video : CustomStringConvertible{
    
    let id : String
    let title : String
    let duration : Int
    let category: String
    let thumbnails: Dictionary<NSObject, AnyObject>
    let publishedAt: String
    let descriptionBox: String
    let channelTitle: String
    let viewCount: Int
    let likeCount: Int?
    let dislikeCount: Int?
    
    var description: String { return ("\(category) - \(duration): \(title) (\(id))") }
    
    init(videoDictionary: Dictionary<String, AnyObject>) {
        self.id = videoDictionary["id"] as! String
        self.title = videoDictionary["title"] as! String
        self.duration = Video.durationStringToSecs((videoDictionary["duration"] as? String))
        self.category = videoDictionary["category"] as! String
        
        self.publishedAt = videoDictionary["publishedAt"] as! String
        self.descriptionBox = videoDictionary["description"] as! String // another type to keep formatting characters?
        self.channelTitle = videoDictionary["channelTitle"] as! String
        self.thumbnails = videoDictionary["thumbnails"] as! Dictionary<NSObject, AnyObject>
        self.viewCount = Int(videoDictionary["viewCount"] as! String)!
        
        if let likeCount = videoDictionary["likeCount"]
        {
            self.likeCount = Int(likeCount as! String)!
        }
        else {
            self.likeCount = nil
        }
        
        if let dislikeCount = videoDictionary["dislikeCount"]
        {
            self.dislikeCount = Int(dislikeCount as! String)!
        }
        else {
            self.dislikeCount = nil
        }

        

    }
    
    class func durationStringToSecs(videoDuration: String?) -> Int {
        
        var videoDurationString = videoDuration! as NSString
        
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
        let timeRange = videoDurationString.rangeOfString("T")
        
        videoDurationString = videoDurationString.substringFromIndex(timeRange.location)
        while videoDurationString.length > 1 {
            
            videoDurationString = videoDurationString.substringFromIndex(1)
            
            let scanner = NSScanner(string: videoDurationString as String) as NSScanner
            var part: NSString?
            
            scanner.scanCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet(), intoString: &part)
            
            let partRange: NSRange = videoDurationString.rangeOfString(part! as String)
            
            videoDurationString = videoDurationString.substringFromIndex(partRange.location + partRange.length)
            let timeUnit: String = videoDurationString.substringToIndex(1)
            
            
            if (timeUnit == "H") {
                hours = Int(part as! String)!
            }
            else if (timeUnit == "M") {
                minutes = Int(part as! String)!
            }
            else if (timeUnit == "S") {
                seconds   = Int(part! as String)!
            }
            else{
            }
            
        }
        return hours*3600 + minutes*60 + seconds
    }
    
    
}