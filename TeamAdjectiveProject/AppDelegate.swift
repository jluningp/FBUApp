//
//  AppDelegate.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/5/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //remember to remove article view controller before submitting diff
        UserTracking.initialize()
        //UserTracking.analyzeData()
        ArticleSource.preloadData()
        VideoSource.setupOAuth()
        PhotoSource.connectToTumblrAPI(0)
        VideoSource.preloadVideoForSelectedCategories { (vids) in }

        // Initialize the window
        window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        // Set Background Color of window
        window?.backgroundColor = UIColor.whiteColor()
        
        // Allocate memory for an instance of the 'MainViewController' class
        let homeViewController = HomeViewController()
        let navController = UINavigationController(rootViewController: homeViewController)
        
        // Set the root view controller of the app's window
        window!.rootViewController = navController
        
        // Make the window visible
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // you should probably first check if this is your URL being opened
//        if url == "com.googleusercontent.apps.844433410634-3utiiauoea914ji6mkth2jrjtm1qdu13:/oauth" {
//            
//            
//            
//            VideoSource.oauth2.handleRedirectURL(url)
//            return true
//        }
//        return false
        print("url: \(url)")
        VideoSource.oauth2.handleRedirectURL(url)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

