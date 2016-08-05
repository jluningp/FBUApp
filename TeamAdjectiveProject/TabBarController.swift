//
//  TabBarController.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/15/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
        override func viewDidLoad() {
            super.viewDidLoad()
            delegate = self
        }
    
    var articleViewController : AnyObject = ArticleViewController()
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var articlesTab = UIViewController()
        if let articleViewController = articleViewController as? ArticleViewController {
            articlesTab = UINavigationController(rootViewController: articleViewController)
        } else {
            articlesTab = UINavigationController(rootViewController: articleViewController as! VideoViewController)
        }
        let articlesIcon = UITabBarItem(title: "Recommended", image: UIImage(named: "emptyStar"), selectedImage: UIImage(named: "fullStar"))
        articlesTab.tabBarItem = articlesIcon
        
        let settingsTab = UINavigationController(rootViewController: SettingsViewController())
        let settingsIcon = UITabBarItem(title: "Settings", image: UIImage(named: "emptySettings"), selectedImage: UIImage(named: "fullSettings"))
        settingsTab.tabBarItem = settingsIcon
        
        let chatTab = UINavigationController(rootViewController: ChatViewController())
        let chatIcon = UITabBarItem(title: "Chat", image: UIImage(named: "emptySpeech"), selectedImage: UIImage(named: "fullSpeech"))
        chatTab.tabBarItem = chatIcon
        
        let gameTab = UINavigationController(rootViewController: GameViewController())
        let gameIcon = UITabBarItem(title: "Games", image: UIImage(named: "emptyGame"), selectedImage: UIImage(named: "fullGame"))
        gameTab.tabBarItem = gameIcon
        
        let photosTab = PhotosViewController()

        let photosIcon = UITabBarItem(title: "Photos", image: UIImage(named: "emptyPhotos"), selectedImage: UIImage(named: "fullPhotos"))
        photosTab.tabBarItem = photosIcon
        
        let controllers = [articlesTab, chatTab, gameTab, photosTab, settingsTab]


        self.viewControllers = controllers
    }
    
        //Delegate methods
        func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
            return true;
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
