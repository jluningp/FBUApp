//
//  SettingsViewController.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/7/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    
    
    var selectedTopics = Settings.topicsList
    var buzzfeedTopics = Settings.buzzfeedTopicsList
    var selectedVideoRows = Set<String>()
    
    var topicLabel = UILabel()
    var selectList = [UIView]()
    var allTopics =     ["home",
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
    
    
    
    var topics = ["home",
                  "opinion",
                  "world",
                  "politics",
                  "health",
                  "sports",
                  "food"]
    
    var printTopics = ["Home",
                       "Opinion",
                       "World",
                       "Politics",
                       "Health",
                       "Sports",
                       "Food"]
    
    //var videoEndpoints = ["popular", "recommended videos - tap to sign in"]
    
    var buzzfeed = ["bigstories", "lol", "cute"]
    
    var printBuzzfeed = ["Big Stories", "LOL", "Cute"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.tableFooterView = UIView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        if Countdown.sharedInstance == nil {
            countdownView.hidden = true
            settingsTableView.tableHeaderView = nil
            tableViewTop.constant = tableViewTop.constant - 33
        }
        NSLayoutConstraint(item: countdownView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -2).active = true
        NSLayoutConstraint(item: settingsTableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0).active = true
        
        let saveIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveSettings(_:)))
        navigationItem.rightBarButtonItem = saveIcon
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.YouTubeSignedInListener), name: VideoSource.authorizedNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.YouTubeSignedOutListener), name: VideoSource.unAuthorizedNotificationKey, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        Countdown.articleViewFunctionCall = updateTime
        
        self.navigationItem.title = "Settings"
        
        selectedTopics = Settings.topicsList
        buzzfeedTopics = Settings.buzzfeedTopicsList
        selectedVideoRows = Set(Settings.videoCategories)
        settingsTableView.reloadData()

        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if Countdown.sharedInstance != nil {
            let totalTime = Double(Countdown.sharedInstance!.totalTime)
            let time = Countdown.sharedInstance!.secsRemaining
            let fractionalTime = Float((totalTime - Double(time)) / totalTime)
            progressView.setProgress(fractionalTime, animated: false)
            timeLabel.text = getFormatTime(time)
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dict = [String: AnyObject]()
        dict["new york times topics"] = printTopics
        dict["buzzfeed"] = printBuzzfeed
        //dict["videos"] = videoEndpoints
        //dict["videos"] = VideoSource.videoSettingsCategories
        let arr1 = dict["new york times topics"] as! [String]
        let arr2 = dict["buzzfeed"] as! [String]
        //let arr3 = dict["videos"] as! [String]
        let arr3 = VideoSource.videoCategoriesDisplay
        dict["new york times topics"] = arr1
        dict["buzzfeed"] = arr2
        dict["videos"] = arr3
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "TopicsCell")
        var checkImage : UIImage?
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 1 {
            cell.textLabel?.text = arr1[indexPath.row]
            let topic = topics[indexPath.row]
            cell.imageView?.image = UIImage(named: "times")
            cell.imageView?.layer.cornerRadius = 15
            cell.imageView?.layer.masksToBounds = true
            for current in selectedTopics {
                if current == topic {
                    checkImage = UIImage(named: "checkMark")
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                }
            }
        }
        else if indexPath.section == 0 {
            cell.textLabel?.text = arr2[indexPath.row]
            let topic = buzzfeed[indexPath.row]
            cell.imageView?.image = UIImage(named: buzzfeed[indexPath.row])
            for current in buzzfeedTopics {
                if current == topic {
                    checkImage = UIImage(named: "checkMark")
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                }
            }
            
        }
        else if indexPath.section == 2 {
            cell.textLabel?.text = arr3[indexPath.row]
            cell.imageView?.image = UIImage(named: "youtube")
            
            // handle first row of this section which is essentially a sign in/log out button
            if (indexPath.row == 0) {
                if VideoSource.isAuthorized() {
                    if let username = VideoSource.username {
                        cell.textLabel?.text = "YouTube - Sign Out of \(username)"
                    }
                    else {
                        VideoSource.fetchCurrentUsername({ (username) in
                            cell.textLabel?.text = "YouTube - Sign Out of \(username)"
                        })
                    }
                }
                else {
                    cell.textLabel?.text = "YouTube - Sign In"
                }
            }
            else {
                // display checkmarks
                switch indexPath.row {
                case 1:
                    if Settings.videoCategories.contains("home") {
                        
                        // only select this row if you are actually logged in
                        if (VideoSource.isAuthorized()) {
                            checkImage = UIImage(named: "checkMark")
                            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                        }
                        else {
                            selectedVideoRows.remove("home")
                            tableView.deselectRowAtIndexPath(indexPath, animated: false)
                        }
                        
                    }
                case 2:
                    if Settings.videoCategories.contains("mostPopular") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                case 3:
                    if Settings.videoCategories.contains("animals") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                case 4:
                    if Settings.videoCategories.contains("gaming") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                case 5:
                    if Settings.videoCategories.contains("sports") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                case 6:
                    if Settings.videoCategories.contains("vlogs") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                case 7:
                    if Settings.videoCategories.contains("music") {
                        checkImage = UIImage(named: "checkMark")
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                default:
                    print("No video categories selected. :(")
                }
                
            }
            
            
        } else {
            cell.textLabel?.text = "Viewing Statistics"
        }
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        
        let checkImageView = UIImageView(image: checkImage)
        cell.accessoryView = checkImageView
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0) {
            print(buzzfeedTopics, buzzfeed[indexPath.row])
            if buzzfeedTopics.indexOf(buzzfeed[indexPath.row]) == nil {
                print(buzzfeed[indexPath.row])
                buzzfeedTopics.append(buzzfeed[indexPath.row])
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        if indexPath.section == 1 {
            print(selectedTopics, topics[indexPath.row])
            if selectedTopics.indexOf(topics[indexPath.row]) == nil {
                selectedTopics.append(topics[indexPath.row])
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        
        if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                youtubeSignIn()
            }
            
            // Your recommended videos row
            if indexPath.row == 1 {
                if (!VideoSource.isAuthorized()) {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                    let alert = UIAlertController(title: "Alert", message: "You must sign in to YouTube to view your recommended videos", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Sign In Now", style: UIAlertActionStyle.Default, handler: {action in
                        self.youtubeSignIn()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    selectedVideoRows.insert("home")
                    Settings.videoCategories = Array(selectedVideoRows)
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                
            }
            else {
                switch indexPath.row {
                case 1:
                    selectedVideoRows.insert("home")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 2:
                    selectedVideoRows.insert("mostPopular")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 3:
                    selectedVideoRows.insert("animals")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 4:
                    selectedVideoRows.insert("gaming")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 5:
                    selectedVideoRows.insert("sports")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 6:
                    selectedVideoRows.insert("vlogs")
                    Settings.videoCategories = Array(selectedVideoRows)
                case 7:
                    selectedVideoRows.insert("music")
                    Settings.videoCategories = Array(selectedVideoRows)
                default: break
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
            
        }
        if indexPath.section == 3 {
            let vc = StatsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0) {
            print(topics[indexPath.row])
            if let topicIndex = buzzfeedTopics.indexOf(buzzfeed[indexPath.row]) {
                buzzfeedTopics.removeAtIndex(topicIndex)
            }
        }
        if indexPath.section == 1 {
            print(topics[indexPath.row])
            if let topicIndex = selectedTopics.indexOf(topics[indexPath.row]) {
                selectedTopics.removeAtIndex(topicIndex)
                print(selectedTopics)
            }
        }
        if indexPath.section == 2 {
            print("deselect video row: ", indexPath.row)
            //            //["tap to sign into YouTube", "your recommended videos", "most popular videos today",  "animals", "gaming", "sports"]
            switch indexPath.row {
            case 1:
                selectedVideoRows.remove("home")
                Settings.videoCategories = Array(selectedVideoRows)
                //VideoSource.removeVideosOfCategory("home")
                
            case 2:
                selectedVideoRows.remove("mostPopular")
                Settings.videoCategories = Array(selectedVideoRows)
                //VideoSource.removeVideosOfCategory("mostPopular")
                
            case 3:
                selectedVideoRows.remove("animals")
                Settings.videoCategories = Array(selectedVideoRows)
                //VideoSource.removeVideosOfCategory("animals")
                
            case 4:
                selectedVideoRows.remove("gaming")
                Settings.videoCategories = Array(selectedVideoRows)
                //VideoSource.removeVideosOfCategory("gaming")
                
            case 5:
                selectedVideoRows.remove("sports")
                Settings.videoCategories = Array(selectedVideoRows)
                VideoSource.removeVideosOfCategory("sports")
                
            case 6:
                selectedVideoRows.remove("vlogs")
                Settings.videoCategories = Array(selectedVideoRows)
                VideoSource.removeVideosOfCategory("vlogs")
                
            case 7:
                selectedVideoRows.remove("music")
                Settings.videoCategories = Array(selectedVideoRows)
                VideoSource.removeVideosOfCategory("music")
                
            default:
                print("No video categories to remove (or the 0th row was deselected)")
            }
            
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return topics.count
        }
        else if section == 0 {
            return buzzfeed.count
        }
        else if section == 2 {
            return VideoSource.videoCategoriesDisplay.count
        } else {
            return 1
        }
    }
    
    func youtubeSignIn(){
        if (VideoSource.isAuthorized()) {
            VideoSource.revokeAccess()
            VideoSource.videoCategoriesDisplay[0] = "YouTube - Sign In"
            selectedVideoRows.remove("home")
            Settings.videoCategories = Array(selectedVideoRows)
            settingsTableView.reloadData()
        }
        else {
            VideoSource.authorize()
        }
    }
    
    func YouTubeSignedInListener() {
        VideoSource.videoCategoriesDisplay[0] = "YouTube - Log Out"
        settingsTableView.reloadData()
    }
    
    func YouTubeSignedOutListener() {
        VideoSource.videoCategoriesDisplay[0] = "YouTube - Sign In"
        settingsTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "New York Times Topics"
        }
        else if section == 0 {
            return "Buzzfeed Feeds"
        }
            
        else if section == 2 {
            return "YouTube Video Categories"
        } else {
            return "Advanced"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let blue = UIColor.lightGrayColor() //UIColor(red: CGFloat(150.0/255.0), green: CGFloat(190.0/255.0),blue: CGFloat(255.0/255.0),  alpha: CGFloat(1.0))
        view.tintColor = blue
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        print("------selected rows in other func ", self.settingsTableView.indexPathsForSelectedRows)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
         print("------selected rows in did scroll func ", self.settingsTableView.indexPathsForSelectedRows)
    }
    
    func isSomethingSelected() -> Bool {
        if !Settings.videoCategories.isEmpty {
            return true
        }
        if !Settings.buzzfeedTopicsList.isEmpty {
            return true
        }
        if !Settings.topicsList.isEmpty {
            return true
        }
        return false
    }
    
    func saveSettings(sender: AnyObject) {

        
        Settings.topicsList = selectedTopics
        Settings.buzzfeedTopicsList = buzzfeedTopics
        ArticleSource.reset()
        ArticleSource.preloadData()
        Settings.videoCategories = Array(selectedVideoRows)
        
        print("index paths for selected rows: ", self.settingsTableView.indexPathsForSelectedRows)
        if let selectedIndexPaths = self.settingsTableView.indexPathsForSelectedRows {
            
            // make sure any selected row is counted, even if it was selected in a previous time
            for indexPath in selectedIndexPaths {
                if indexPath.section == 2 {
                    //print ("selected row: ", indexPath.row)
                    
                    switch indexPath.row {
                    case 1:
                        selectedVideoRows.insert("home")
                    case 2:
                        selectedVideoRows.insert("mostPopular")
                    case 3:
                        selectedVideoRows.insert("animals")
                    case 4:
                        selectedVideoRows.insert("gaming")
                    case 5:
                        selectedVideoRows.insert("sports")
                    case 6:
                        selectedVideoRows.insert("vlogs")
                    case 7:
                        selectedVideoRows.insert("music")
                    default: break
                    }
                    
                }
            }
            
            Settings.videoCategories = Array(selectedVideoRows)
            
        }
        
        // nothing is selected
        else if !isSomethingSelected(){
            
            let alertController = UIAlertController(title: "Invalid Settings", message: "You haven't selected any content categories. Please select at least one to continue!", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            
            return // don't do the rest of the function because there is nothing selected yet
        }
        
        VideoSource.removeDeselectedVideoCategories()
        
        
        
        
        if Countdown.sharedInstance != nil {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            let noVideos = Settings.videoCategories.count == 0
            
            // reload a new video
            if ArticleSource.noTimes && ArticleSource.noBuzzfeed && !noVideos {
                print("selected categories on save settings: ", Settings.videoCategories)
                VideoSource.preloadVideoForSelectedCategories { (preloadedVideos:[Video]) in
                    print("Preloading videos completion handler from saveSettings()")
                    
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
            
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func getFormatTime(time : Int) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time % 60)
        var printSeconds = "\(seconds)"
        if seconds < 10 {
            printSeconds = "0\(seconds)"
        }
        return "\(minutes):\(printSeconds)"
    }
    
    func updateTime(time : Int) {
        timeLabel.text = getFormatTime(time)
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: true)
        if Int(time) == 0 {
            showWhenDone()
            ArticleSource.allArticles = Array(ArticleSource.allArticles.prefix(ArticleSource.articleIndex + 1))
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(done(_:)))
            navigationItem.rightBarButtonItem = doneButton
        }
    }
    
    
    @IBAction func donePressed(sender: AnyObject) {
        done(nil)
    }
    
    func done(sender : AnyObject?) {
        Countdown.sharedInstance?.timerFinished()
        Countdown.sharedInstance = nil
        ArticleSource.reset()
        ArticleSource.preloadData()
        let hvc = UINavigationController(rootViewController: HomeViewController())
        self.presentViewController(hvc, animated: false, completion: nil)
    }
    
    func showWhenDone() {
        let alertController = UIAlertController(title: "Your time's up!", message: "", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Stay on Page", style: .Cancel, handler: nil)
        let defaultAction = UIAlertAction(title: "Done", style: .Default, handler: {(action) in self.done(nil) })
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
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

extension String {
    func capitalizeFirstLetter() -> String {
        let first = String(characters.prefix(1)).uppercaseString
        let other = String(characters.dropFirst())
        return first + other
    }
}
