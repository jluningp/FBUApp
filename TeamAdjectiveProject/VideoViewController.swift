//
//  VideoViewController.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/12/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var descriptionBoxTextView: UITextView!
    
    
    let playerVars: [String : String] = ["playsinline": "1"]
    var chosenVideos = [Video]()
    var videoIndex = 0
    var currentVideoId : String?
    var currentVideo : Video?
    
    var startTime = 0
    var endTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentVideoId == nil {
            loadVideo(nil)
        } else {
            if let nextVideo = currentVideo {
                self.videoTitleLabel.text = nextVideo.title
                self.channelTitleLabel.text = "By: \(nextVideo.channelTitle)"
                
                if let likeCount = nextVideo.likeCount {
                    self.likeCountLabel.text = String(likeCount)
                }
                else {
                    self.likeCountLabel.text = ""
                }
                
                if let dislikeCount = nextVideo.dislikeCount {
                    self.dislikeCountLabel.text = String(dislikeCount)
                }
                else {
                    self.dislikeCountLabel.text = ""
                }
                self.descriptionBoxTextView.text = nextVideo.descriptionBox
            }
            self.playerView?.loadWithVideoId(currentVideoId!, playerVars: self.playerVars)
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self, action: #selector(onPrevVideo(_:)))
        navigationItem.leftBarButtonItem = backButton
        
        let nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: #selector(onNextVideo(_:)))
        navigationItem.rightBarButtonItem = nextButton
        
        navigationItem.title = "Video"
        
        let stringViews = String(self.currentVideo!.viewCount)
        self.viewCountLabel.text = stringViews
        self.videoTitleLabel.text = self.currentVideo!.title
        self.channelTitleLabel.text = "By: \(self.currentVideo!.channelTitle)"
        
        if let likeCount = self.currentVideo!.likeCount {
            self.likeCountLabel.text = String(likeCount)
        }
        else {
            self.likeCountLabel.text = ""
        }
        
        if let dislikeCount = self.currentVideo!.dislikeCount {
            self.dislikeCountLabel.text = String(dislikeCount)
        }
        else {
            self.dislikeCountLabel.text = ""
        }
        
        self.descriptionBoxTextView.text = self.currentVideo!.descriptionBox
    }
    
    override func viewWillAppear(animated: Bool) {
        self.startTime = Countdown.sharedInstance!.secsRemaining
        // !! change to video view function call??
        Countdown.articleViewFunctionCall = updateTime
        
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let time = Countdown.sharedInstance!.secsRemaining
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: false)
        timeView.text = Countdown.sharedInstance!.getFormatTime()
    }
    
    
    func loadVideo(video : Video?) {
        if let video = video {
            print("----reloading a video already displayed")
            self.currentVideoId = video.id
            self.currentVideo = video
        }
        else {
            print("--- getting a new video")
            let nextVideo = VideoSource.getNextVideo(Countdown.sharedInstance!.secsRemaining)
            
            self.currentVideo = nextVideo
            self.currentVideoId = nextVideo.id
            self.playerView.loadWithVideoId(self.currentVideoId!, playerVars: self.playerVars)
            
            
            ArticleSource.allArticles.insert(self.currentVideo!, atIndex: ArticleSource.articleIndex)
        }
        
 
    }
    
    override func viewDidAppear(animated: Bool) {
        startTime = Countdown.sharedInstance?.secsRemaining ?? 0
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(forwardSwipe(_:)))
        edgePan.edges = .Right
        view.addGestureRecognizer(edgePan)
        
        let backEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(backSwipe(_:)))
        backEdgePan.edges = .Left
        view.addGestureRecognizer(backEdgePan)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onPlay(sender: AnyObject) {
        playerView.playVideo()
    }
    
    @IBAction func onPause(sender: AnyObject) {
        playerView.pauseVideo()
    }
    
    @IBAction func onNextVideo(sender: AnyObject) {
        next()
    }
    
    func next() {
        ArticleSource.articleIndex = ArticleSource.articleIndex + 1
        let noArticles = ArticleSource.noTimes && ArticleSource.noBuzzfeed
        let noVideos = Settings.videoCategories.count == 0
        var videoProbability = Int((ArticleSource.typeProbabilities["video"] ?? 0.5) * 100.0)
        if videoProbability < 15 {
            videoProbability = 15
        }
        let coinFlip = Int(arc4random_uniform(UInt32(100)))
        if ArticleSource.latestArticleIndex < ArticleSource.articleIndex { //checks if it should show new articles
            //uses previous viewing statistics to decide how likely seeing a video should be, with a floor of 15%
            if (coinFlip > videoProbability && !noArticles) || noVideos {
                //article was chosen
                let nextArticle = ArticleViewController()
                self.navigationController?.pushViewController(nextArticle, animated: true)
            } else {
                //video was chosen
                let nextVideo = VideoViewController()
                self.navigationController?.pushViewController(nextVideo, animated: true)
            }
        } else { //occurs if it's gone back and is going forward again, showing articles/videos already presented
            if ArticleSource.articleIndex < ArticleSource.allArticles.count { //checks if it's safe to access array of articles/videos
                if let video = ArticleSource.allArticles[ArticleSource.articleIndex] as? Video { //checks if next thing in the array is a video
                    let nextVideo = VideoViewController()
                    nextVideo.loadVideo(video)
                    self.navigationController?.pushViewController(nextVideo, animated: true)
                } else {
                    let nextArticle = ArticleViewController()
                    self.navigationController?.pushViewController(nextArticle, animated: true)
                }
            } else {
                if (coinFlip > videoProbability && !noArticles) || noVideos {
                    //article was chosen
                    let nextArticle = ArticleViewController()
                    self.navigationController?.pushViewController(nextArticle, animated: true)
                } else {
                    //video was chosen
                    let nextVideo = VideoViewController()
                    self.navigationController?.pushViewController(nextVideo, animated: true)
                }
            }
        }
        if ArticleSource.latestArticleIndex < ArticleSource.articleIndex { //updates latest article seen (allows it to check if it's seen new articles)
            ArticleSource.latestArticleIndex = ArticleSource.articleIndex
        }
    }
    
    func updateTime(time : Int) {
        timeView.text = Countdown.sharedInstance!.getFormatTime()
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: true)
        
        if Int(time) == 0 {
            showWhenDone()
            ArticleSource.allArticles = Array(ArticleSource.allArticles.prefix(ArticleSource.articleIndex + 1))
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(done))
            navigationItem.rightBarButtonItem = doneButton
        }
    }
    
    
    func done(sender : AnyObject?) {
        Countdown.sharedInstance = nil
        ArticleSource.reset()
        ArticleSource.preloadData()
        VideoSource.loadVideosInBackground("home")
        // how to preloadVideos?
        let hvc = UINavigationController(rootViewController: HomeViewController())
        self.presentViewController(hvc, animated: false, completion: nil)
    }
    
    
    func showWhenDone() {
        let alertController = UIAlertController(title: "Your time's up!", message: "", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Done", style: .Default, handler: {(action) in self.done(nil) })
        
        let cancelAction = UIAlertAction(title: "Keep Watching", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPrevVideo(sender: AnyObject) {
        previous()
    }
    
    func previous() {
        if ArticleSource.articleIndex > 0 {
            ArticleSource.articleIndex = ArticleSource.articleIndex - 1
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    @IBAction func onAuthorize(sender: AnyObject) {
        VideoSource.authorize()
    }
    
    @IBAction func onRevokeAccess(sender: AnyObject) {
        VideoSource.revokeAccess()
    }
    
    override func viewWillDisappear(animated: Bool) {
        updateTrackingData()
    }
    
    func updateTrackingData() {
        endTime = Countdown.sharedInstance?.secsRemaining ?? 0
        
        
        // !!! Update to use chosen categories from settings
        
//        var category = "mostPopular"
//        if VideoSource.isAuthorized() {
//            category = "home"
//        }
        print("start - end time", startTime - endTime)
        UserTracking.updateReadArticles(currentVideo!.id, type: "video", category: currentVideo!.category, estimatedTime: currentVideo!.duration, time: startTime - endTime)
    }
    
    func forwardSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            next()
        }
    }
    
    func backSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            previous()
        }
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
