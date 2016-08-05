//
//  Content.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/14/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import UIKit

class Content {
    static var contents = [Content]()
    
    class func getArticles(seconds : Int) {
        ArticleSource.getArticles(seconds) { (returnedArticles) in
            for article in returnedArticles {
                //contents.append(article.makeContent())
            }
        }
    }
    
    class func getVideos(seconds : Int) {
        //get videos somehow
    }
    
    class func selectMedia(contents : [Content]) {
        
    }
    
    var time : Int
    var view : UIView
    
    init(time : Int, view : UIView) {
        self.time = time
        self.view = view
    }
}