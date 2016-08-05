//
//  ArticlesViewController.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/15/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import MBProgressHUD

class ArticleViewController: UIViewController, UIWebViewDelegate {

    
    @IBOutlet weak var articleView: UIWebView!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var articleTop: NSLayoutConstraint!
    
    var currentArticle : Article {
        get {
            return ArticleSource.getArticles()
        }
    }
    
    var thisPageArticle : Article?
    
    var startTime = 0
    var endTime = 0
    var currentTime = 0
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.articleView.scalesPageToFit = true
        
        articleView.delegate = self
        

        self.automaticallyAdjustsScrollViewInsets = false
        
        NSLayoutConstraint(item: timeView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 15).active = true
        NSLayoutConstraint(item: articleView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0).active = true
        
        navigationItem.title = "Article"
        
        loadCurrentArticle(currentArticle)
    }
    
    func loadCurrentArticle(article : Article) {
        thisPageArticle = article
        
        let cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
        
        if ArticleSource.articleIndex > 0 {
            let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self, action: #selector(backButton(_:)))
            navigationItem.leftBarButtonItem = backButton
        }
        
        let nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: #selector(forwardButton(_:)))
        navigationItem.rightBarButtonItem = nextButton
        
        if ArticleSource.articleIndex == ArticleSource.allArticles.count - 1 && Int(Countdown.sharedInstance!.secsRemaining) == 0 {
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(done))
            navigationItem.rightBarButtonItem = doneButton
        }
        
        if self.currentArticle.url == "error" {
            self.articleView.loadHTMLString("<div style='text-align: center; padding: 1em; font-size: 3em;' <h2>Nothing more to see here!<br><br> Why not play a game or join the chat?</h2></center></div>", baseURL: nil)
            navigationItem.rightBarButtonItem = nil
        } else if self.currentArticle.type == "nytimes" {
            let html = NYTimesArticle.editArticleText(self.currentArticle.rawText)
            self.articleView.loadHTMLString(html, baseURL: nil)
            self.articleTop.constant = -30
            
            for thisView in articleView.scrollView.subviews {
                thisView.userInteractionEnabled = false
            }
        } else {
            self.articleView.loadRequest(NSURLRequest(URL: NSURL(string: self.currentArticle.url)!))
        }
        MBProgressHUD.showHUDAddedTo(view, animated: true)

    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loaded = true
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        Countdown.articleViewFunctionCall = updateTime
        
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let time = Countdown.sharedInstance!.secsRemaining
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: false)
        timeView.text = getFormatTime(time)
    
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
    
    override func viewWillDisappear(animated: Bool) {
        updateTrackingData()
    }
    
    func updateTrackingData() {
        endTime = Countdown.sharedInstance?.secsRemaining ?? 0
        print(startTime - endTime)
        print("typecat", thisPageArticle!.type, thisPageArticle!.category)
        if(thisPageArticle!.url != "error") {
            UserTracking.updateReadArticles(thisPageArticle!.url, type: thisPageArticle!.type, category: thisPageArticle!.category, estimatedTime: ArticleSource.getWordCount(thisPageArticle!) / 250, time: startTime - endTime)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func forwardButton(sender: AnyObject) {
        nextArticle()
    }
    
    func forwardSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            nextArticle()
        }
    }
    
    func nextArticle() {
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

    
    func backButton(sender: AnyObject) {
        previousArticle()
    }
    
    func backSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            previousArticle()
        }
    }
    
    func previousArticle() {
        if ArticleSource.articleIndex > 0 {
            ArticleSource.articleIndex = ArticleSource.articleIndex - 1
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    func onSettings(sender: AnyObject) {
        self.presentViewController(SettingsViewController(), animated: true, completion: nil)

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
        timeView.text = getFormatTime(time)
   
     
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(Float((totalTime - 0.5 * Double(time)) / totalTime), animated: true)
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
        let hvc = UINavigationController(rootViewController: HomeViewController())
        self.presentViewController(hvc, animated: false, completion: nil)
    }

    
    func showWhenDone() {
        let alertController = UIAlertController(title: "Your time's up!", message: "", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Done", style: .Default, handler: {(action) in self.done(nil) })
        
        let cancelAction = UIAlertAction(title: "Keep Reading", style: .Cancel, handler: nil)
        
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
