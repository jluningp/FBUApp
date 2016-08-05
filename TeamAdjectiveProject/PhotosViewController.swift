//
//  PhotosViewController.swift
//  TeamAdjectiveProject
//
//  Created by Allison Tang on 7/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var picturesView: UIImageView!
    @IBOutlet weak var countdownView: UIView!

    var photos: [String]!
    var index: Int = 0
    var offsetMultiplier: Int = 1
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photos = PhotoSource.getPhotos()
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "Photos"
        if index > 0 {
            self.leftBarItem.enabled = true
        }
        self.rightBarItem.action = #selector(forwardButton(_:))
        self.leftBarItem.action = #selector(backButton(_:))
        self.timeProgressView.setProgress(0, animated: true)
        presentPhotos(index)
    }

    override func viewDidAppear(animated: Bool) {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(forwardSwipe(_:)))
        edgePan.edges = .Right
        view.addGestureRecognizer(edgePan)
        let backEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(backSwipe(_:)))
        backEdgePan.edges = .Left
        view.addGestureRecognizer(backEdgePan)
        Countdown.articleViewFunctionCall = updateTime
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let time = Countdown.sharedInstance!.secsRemaining
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        timeProgressView.setProgress(fractionalTime, animated: false)
        timeLabel.text = "\(getFormatTime(time))"
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(nextPhoto), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
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
    
    func updateTime(time: Int) {
        timeLabel.text = "\(getFormatTime(time))"
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        timeProgressView.setProgress(Float((totalTime - 0.5 * Double(time)) / totalTime), animated: true)
        timeProgressView.setProgress(fractionalTime, animated: true)
        if Int(time) == 0 {
            showWhenDone()
        }
    }
    
    func done(sender : AnyObject?) {
        Countdown.sharedInstance = nil
        ArticleSource.reset()
        ArticleSource.preloadData()
        let hvc = UINavigationController(rootViewController: HomeViewController())
        timer.invalidate()
        self.presentViewController(hvc, animated: false, completion: nil)
    }
    
    func showWhenDone() {
        let alertController = UIAlertController(title: "Your time's up!", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Keep Scrolling", style: .Cancel, handler: nil)
        let defaultAction = UIAlertAction(title: "Done", style: .Default, handler: {(action) in self.done(nil) })
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
    presentViewController(alertController, animated: true, completion: nil)
        timer.invalidate()
    }
        
    func forwardButton(sender: AnyObject) {
            nextPhoto()
            makeTimer()
        }
        
    func backButton(sender: AnyObject) {
            previousPhoto()
            makeTimer()
        }
    
    func makeTimer() {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(nextPhoto), userInfo: nil, repeats: true)
    }
    
    func presentPhotos(ind: Int) {
        let request = NSURLRequest(URL: NSURL(string: self.photos[ind])!)
        NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if error == nil {
                        self.picturesView.alpha = 0.0
                         self.picturesView.image = UIImage(data: data!)
                        UIView.animateWithDuration(1, animations: { 
                           self.picturesView.alpha = 1.0
                        })
                        
                    }
            })
                }


    func nextPhoto() {
        //print ("going to the next photo")
        if index == 15 {
            print ("loading more photos")
            //print (photos)
            PhotoSource.connectToTumblrAPI(20*offsetMultiplier)
        }
        if index == 19 {
            print ("getting more photos")
            photos = PhotoSource.getPhotos()
            offsetMultiplier += 1
            print (photos)
            index = 0
        }
        index += 1
        presentPhotos(index)
    }
    
    func previousPhoto() {
        if index != 0 {
            index -= 1
            print("going to the previous photo")
            presentPhotos(index)
        }
        else {
            print ("this is the first photo")
        }
    }
    
    
    func forwardSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            nextPhoto()
            makeTimer()
        }
    }
    
    func backSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Recognized {
            previousPhoto()
            makeTimer()
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
