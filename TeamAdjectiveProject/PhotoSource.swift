//
//  PhotoSource.swift
//  TeamAdjectiveProject
//
//  Created by Allison Tang on 7/21/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Foundation


class PhotoSource {
  
    static let key = "lHDSNUQNgjEzU2aiwAIw7PDPxIkFAbmstvYncEsAUZOi1DYEXV"
    static let blogName = "cuteanimals"
    static let type = "photo"

    static var pictures: [String]! = []
    static var pictureHeight: [Int]! = []
    
    class func getPhotos() -> ([String]) {
        return self.pictures
    }
    
    class func getHeights() -> ([Int]) {
        return self.pictureHeight

    }
    
    class func connectToTumblrAPI(offset: Int) {
        let url = NSURL(string: "https://api.tumblr.com/v2/blog/\(blogName)/posts/\(type)?api_key=\(key)&offset=\(offset)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration() , delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try? NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as! NSDictionary {
                    //print (responseDictionary) //827 total posts
                    self.pictures = accessPhotos(responseDictionary["response"] as! NSDictionary)

                }
            }
        })
        task.resume()
}

    
    private class func accessPhotos(blog: NSDictionary) -> ([String]) {
       var allPhotos: [String]! = []
        let posts = blog["posts"] as! NSArray
            for post in posts {
            let photos = post["photos"] as! NSArray
            let photoSizes = photos[0]["alt_sizes"] as! NSArray
            let picture = photoSizes[0]["url"] as! String
            let picHeight = photoSizes[0]["height"] as! Int

            allPhotos.append(picture)
            self.pictureHeight.append(picHeight)
    }
        //print (allPhotos.count) //20
        return allPhotos

        }

}







