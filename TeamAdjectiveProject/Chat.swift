//
//  Chat.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/12/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class Chat {
    static var ref = FIRDatabase.database().reference()
    static var posts = [Chat]()
    static var _username : String?
    static var username : String? {
        get {
            if let _username = _username {
                return _username
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let username = defaults.stringForKey("username") {
                    _username = username
                }
                return _username
            }
        }
        set(name) {
            if let name = name {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(name, forKey: "username")
            }
            _username = name
        }
    }

    
    static var userID : String {
        get {
            return UserTracking.userID
        }
    }
    static var authId : String?
    static var postsToLoad = 50
    static var storedPosts = [Chat]()
    
    //Sets up an observer that gets all chats sent as they are sent - this only needs to be called once
    class func getChat(completion : [Chat] -> Void) {
        ref.child("chat").observeEventType(.Value, withBlock: { snapshot in
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDictionary = snap.value as? NSDictionary {
                        let message = postDictionary["message"] as? String
                        let username = postDictionary["username"] as? String
                        let userID = postDictionary["userID"] as? String
                        if let message = message, username = username, userID = userID {
                            let key = snap.key
                            self.posts.append(Chat(message: message, username: username, userID: userID, key: key))
                        }
                    }
                }
                completion(posts)
                updateCurrentThread()
            }
        })
    }
    
    //makes releases observers
    class func releaseChat() {
        ref.removeAllObservers()
    }
    
    //Sends a new chat to the database
    class func sendChat(message : String, ifNil : Void -> Void) {
        if let username = username {
            if message != "" {
                let chatRef = ref.child("chat").childByAutoId()
                chatRef.setValue(["username" : username, "message" : message, "userID" : userID])
            }
        } else {
            ifNil()
        }
    }
    
    class func updateCurrentThread() {
        if posts.count > postsToLoad {
            let key = posts[0].key
            ref.child("chat").child(key).removeValue()
        }
    }
    
    var message : String
    var username : String
    var userID : String
    var key : String
    
    init(message: String, username : String, userID : String, key : String) {
        self.message = message
        self.username = username
        self.userID = userID
        self.key = key
    }
}