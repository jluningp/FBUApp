//
//  HomeViewController.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/8/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import MBProgressHUD


class HomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var beginWaitingButton: UIButton!
    
    let timeIncrements = [2, 5, 10, 20, 30]
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsTriangle: UIImageView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var startView: UIView!
    
    @IBOutlet var gestureRec: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
         
        if !Settings.tutorialDone {
            settingsView.hidden = false
            settingsTriangle.hidden = false
        } else {
            view.removeGestureRecognizer(gestureRec)
        }
    
        settingsView.layer.shadowOpacity = 0.5
        settingsView.layer.shadowColor = UIColor.blueColor().CGColor
        settingsView.layer.shadowOffset = CGSizeMake(0,0)
        settingsView.layer.shadowRadius = 10
        
        timeView.layer.shadowOpacity = 0.5
        timeView.layer.shadowColor = UIColor.blueColor().CGColor
        timeView.layer.shadowOffset = CGSizeMake(0,0)
        timeView.layer.shadowRadius = 10
        
        startView.layer.shadowOpacity = 0.5
        startView.layer.shadowColor = UIColor.whiteColor().CGColor
        startView.layer.shadowOffset = CGSizeMake(0,0)
        startView.layer.shadowRadius = 10
    
        let titleView = UILabel()
        titleView.text = "Wait for It"
        //titleView.font = UIFont(name: "futura", size: 15)
        self.navigationItem.title = "Wait for It"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                                                                        NSFontAttributeName: UIFont(name: "futura", size: 18)!]
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "navGear"), style: .Plain, target: self, action: #selector(onSettings(_:)))
        navigationItem.leftBarButtonItem = settingsButton

        let goButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(beginWaiting(_:)))
        navigationItem.rightBarButtonItem = goButton
        
        beginWaitingButton.titleLabel?.shadowColor = beginWaitingButton.titleLabel?.textColor
        
        
        beginWaitingButton.titleLabel!.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
        beginWaitingButton.titleLabel!.layer.shadowRadius = 10.0;
        beginWaitingButton.titleLabel!.layer.shadowOpacity = 0.7;
        beginWaitingButton.titleLabel!.layer.shadowOffset = CGSize(width: 1, height: 1);
        beginWaitingButton.titleLabel!.layer.masksToBounds = false;


    }
    
    @IBAction func tutorialTap(sender: AnyObject) {
        if !settingsView.hidden {
            settingsView.hidden = true
            settingsTriangle.hidden = true
            timeView.hidden = false
        } else if !timeView.hidden {
            timeView.hidden = true
            startView.hidden = false
        } else {
            startView.hidden = true
            Settings.tutorialDone = true
            view.removeGestureRecognizer(gestureRec)
        }
    }
    
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
            return false;
        }
        else {
            return true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeIncrements.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(55)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let darkBlue = UIColor(red: CGFloat(446.0/255.0), green: CGFloat(64.0/255.0),blue: CGFloat(87.0/255.0),  alpha: CGFloat(1.0))
        let lightBlue = UIColor(red: CGFloat(159.0/255.0), green: CGFloat(197.0/255.0),blue: CGFloat(232.0/255.0),  alpha: CGFloat(1.0))
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text =  "\(timeIncrements[indexPath.row]) minutes"
        let colorView = UIView()
        colorView.backgroundColor = lightBlue
        cell.selectedBackgroundView = colorView
        cell.textLabel?.highlightedTextColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        return cell
    }
    
    @IBAction func beginWaiting(sender: AnyObject) {
        // Prevent multiple timers from being created
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        // make sure "home" endpoint isn't used even if the user tries to
        if (!VideoSource.isAuthorized()) {
            if let index = Settings.videoCategories.indexOf("home") {
                Settings.videoCategories.removeAtIndex(index)
            }
        }
        
        if Countdown.sharedInstance == nil {
            if tableView.indexPathForSelectedRow?.row == nil {
                print ("No time chosen - default set to 5 minutes")
                Countdown.sharedInstance = Countdown(time: 60 * (timeIncrements[1]))
                
            }
            else {
            Countdown.sharedInstance = Countdown(time: 60 * (timeIncrements[(tableView.indexPathForSelectedRow?.row)!]))
            }
        }
        
        let noVideos = Settings.videoCategories.count == 0
        print(VideoSource.videoCategoriesDisplay)
        
        if ArticleSource.noTimes && ArticleSource.noBuzzfeed && !noVideos {
            print("here")
            VideoSource.preloadVideoForSelectedCategories { (preloadedVideos:[Video]) in
                let tabs = TabBarController()
                tabs.articleViewController = VideoViewController()
                self.presentViewController(tabs, animated: true, completion: nil)
            }
        } else {
            ArticleSource.makeArticleList(Countdown.sharedInstance!.totalTime, completion: {(article) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let tabs = TabBarController()
                self.presentViewController(tabs, animated: true, completion: nil)
            })
        }

        
        
    }
    
    @IBAction func onSettings(sender: AnyObject) {
        let svc = UINavigationController(rootViewController: SettingsViewController())
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    func didFinishAddTime(controller: HomeViewController) {
        //do something in this class
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    //for testing only
    @IBAction func onVideo(sender: AnyObject) {
        self.navigationController?.pushViewController(VideoViewController(), animated: true)
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
