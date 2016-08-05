//
//  Settings.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/11/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    static var _topicsList : [String]?
    static var topicsList : [String] {
        get {
            if let _topicsList = _topicsList {
                return _topicsList
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let topics = defaults.arrayForKey("topicsList") {
                    _topicsList = topics as? [String]
                    if _topicsList == nil {
                        _topicsList = ["home"]
                    }
                } else {
                    _topicsList = ["home"]
                }
                return _topicsList!
            }
        }
        set(topics) {
            _topicsList = topics
            ArticleSource.setTopics(topics)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(topics, forKey: "topicsList")
        }
    }
    
    static var _buzzfeedTopicsList : [String]?
    static var buzzfeedTopicsList : [String] {
        get {
            if let _buzzfeedTopicsList = _buzzfeedTopicsList {
                return _buzzfeedTopicsList
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let topics = defaults.arrayForKey("buzzfeedTopicsList") {
                    _buzzfeedTopicsList = topics as? [String]
                    if _buzzfeedTopicsList == nil {
                        _buzzfeedTopicsList = ["bigstories", "cute"]
                    }
                } else {
                    _buzzfeedTopicsList = ["bigstories", "cute"]
                }
                return _buzzfeedTopicsList!
            }
        }
        set(topics) {
            _buzzfeedTopicsList = topics
            ArticleSource.setBuzzfeedTopics(topics)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(topics, forKey: "buzzfeedTopicsList")
        }
    }

    static var _videoCategories : [String]?
    static var videoCategories : [String] {
        get {
            if let _videoCategories = _videoCategories {
                return _videoCategories
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let categories = defaults.arrayForKey("videoCategories") {
                    _videoCategories = categories as? [String]
                    if _videoCategories == nil {
                        _videoCategories = ["mostPopular"]
                    }
                } else {
                    _videoCategories = ["mostPopular"]
                }
                return _videoCategories!
            }
        }
        set(topics) {
            _videoCategories = topics
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(topics, forKey: "videoCategories")
        }
    }
    
    static var _tutorialDone : Bool?
    static var tutorialDone : Bool {
        get {
            if let _tutorialDone = _tutorialDone {
                return _tutorialDone
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                _tutorialDone = defaults.boolForKey("tutorialDone")
                return _tutorialDone!
            }
        }
        set(done) {
            _tutorialDone = done
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(done, forKey: "tutorialDone")
        }
    }
    
    
    static var textColor = UIColor(red: 46/255, green: 64/255, blue: 87/255, alpha: 1.0)
    static var buttonBackground = UIColor(red: 8/255, green: 61/255, blue: 119/255, alpha: 1.0)
    static var backgroundColor = UIColor.whiteColor()
    static var highlightColor = UIColor(red: 0/255, green: 170/255, blue: 255/255, alpha: 1.0)
    
    static var currentGame = 0

}
