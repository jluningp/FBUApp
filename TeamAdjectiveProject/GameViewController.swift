//
//  GameViewController.swift
//  TeamAdjectiveProject
//
//  Created by Allison Tang on 7/13/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var gameView: UIWebView!
    @IBOutlet weak var tetrisView: UIWebView!
    var chatted = false
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var gamePage: UIPageControl!
    @IBOutlet var swipeRec: UISwipeGestureRecognizer!
    @IBOutlet var swipePrevRec: UISwipeGestureRecognizer!
    var currentGame = 0
    var gameColors = [UIColor(red: 250/255, green: 247/255, blue: 235/255, alpha: 1.0),
                      UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0),
                      UIColor(red: 71/255, green: 192/255, blue: 203/255, alpha: 1.0)]

    @IBOutlet weak var flappyView: UIWebView!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "Game"
        
        NSLayoutConstraint(item: gameView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0).active = true
    
        let mainBundle: NSBundle = NSBundle.mainBundle()
        let homeIndexUrl: NSURL = mainBundle.URLForResource("2048-master/index", withExtension: "html")!
        let urlReq: NSURLRequest = NSURLRequest(URL: homeIndexUrl)
        self.gameView.loadRequest(urlReq)
        self.gameView.scrollView.scrollEnabled = false
        self.gameView.scrollView.bounces = false
        
        let urlReqTetris: NSURLRequest = NSURLRequest(URL: NSURL(string: "http://www.baptistebrunet.com/games/tetris_js/")!)
        self.tetrisView.loadRequest(urlReqTetris)
        
        let urlReqFlappy: NSURLRequest = NSURLRequest(URL: NSURL(string: "http://hyspace.io/flappy/")!)
        self.flappyView.loadRequest(urlReqFlappy)

        switchGame(nil)
        
        print("gamehere")
        swipeRec.addTarget(self, action: #selector(nextGame(_:)))
        swipePrevRec.addTarget(self, action: #selector(prevGame(_:)))
        // Do any additional setup after loading the view.
    }
    
    func nextGame(sender : AnyObject?) {
        if currentGame < 2 {
            currentGame += 1
            switchGame(nil)
            gamePage.currentPage = currentGame
            view.backgroundColor = gameColors[currentGame]
        }
    }
    
    func prevGame(sender: AnyObject) {
        if currentGame > 0 {
            currentGame -= 1
            switchGame(nil)
            gamePage.currentPage = currentGame
            view.backgroundColor = gameColors[currentGame]
        }
    }
    
    func switchGame(sender : AnyObject?) {
        switch currentGame {
        case 0:
            tetrisView.hidden = true
            flappyView.hidden = true
            gameView.hidden = false
        case 1:
            flappyView.hidden = true
            gameView.hidden = true
            tetrisView.hidden = false
        case 2:
            tetrisView.hidden = true
            gameView.hidden = true
            flappyView.hidden = false
        default: break
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        Countdown.articleViewFunctionCall = updateTime
    }
    
    override func viewDidAppear(animated: Bool) {
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let time = Countdown.sharedInstance!.secsRemaining
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: false)
        timeLabel.text = getFormatTime(time)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goChat() {
        self.presentViewController(ChatViewController(), animated: true, completion: {
            self.chatted = true
        })
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
    
    func done(sender : AnyObject?) {
        Countdown.sharedInstance = nil
        ArticleSource.reset()
        ArticleSource.preloadData()
        let hvc = UINavigationController(rootViewController: HomeViewController())
        self.presentViewController(hvc, animated: false, completion: nil)
    }
    
    func showWhenDone() {
        let alertController = UIAlertController(title: "Your time's up!", message: "", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Keep Playing", style: .Cancel, handler: nil)
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
