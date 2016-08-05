//
//  ChatViewController.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/12/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import TKKeyboardControl

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatBox: UITextField!
    
    @IBOutlet weak var welcomeMessage: UIView!
    @IBOutlet weak var usernamePicker: UITextField!
    @IBOutlet weak var hideChat: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeCenter: NSLayoutConstraint!
    @IBOutlet weak var timeBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeView: UIView!
    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var posts : [Chat] {
        get {
            return Chat.storedPosts
        }
        set(posts) {
            Chat.storedPosts = posts
        }
    }
    var indexPath = NSIndexPath()
    var firstReturn = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLayoutConstraint(item: countdownView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -2).active = true
        navigationItem.title = "Chat"
        
        self.timeBarHeight.constant = self.tabBarController!.tabBar.frame.height
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: "chatCell")
        
        chatBox.delegate = self
        
        if Chat.username == nil {
            showWelcomeView()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWasShown(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        self.view.keyboardTriggerOffset = 44.0; // Input view frame height
        
        // Make sure to call self.view.removeKeyboardControl before the view is released.
        // (It's the balancing call)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //usernamePicker.delegate = self
        usernamePicker.becomeFirstResponder()
        Countdown.articleViewFunctionCall = updateTime
    }
    
    override func viewDidAppear(animated: Bool) {
        let totalTime = Double(Countdown.sharedInstance!.totalTime)
        let time = Countdown.sharedInstance!.secsRemaining
        let fractionalTime = Float((totalTime - Double(time)) / totalTime)
        progressView.setProgress(fractionalTime, animated: false)
        timeLabel.text = getFormatTime(time)
        
        self.view.addKeyboardPanningWithFrameBasedActionHandler({ (keyboardFrameInView, opening, closing) in
            if closing {
                self.bottomConstraint.constant = 10
            }
            
            let chatBoxOrigin = CGPoint(x: self.chatBox.frame.origin.x, y: keyboardFrameInView.origin.y - self.chatBox.frame.height - 10)
            if chatBoxOrigin.y < self.timeView.frame.origin.y - self.chatBox.frame.height - 10 {
                self.chatBox.frame.origin = chatBoxOrigin
                let difference = self.chatBox.frame.origin.y - (self.tableView.frame.origin.y + self.tableView.frame.height + 13)
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: self.tableView.frame.height + difference)
                self.tableView.updateConstraints()
            } else {
                self.chatBox.frame.origin = CGPoint(x: chatBoxOrigin.x, y: self.timeView.frame.origin.y - self.chatBox.frame.height - 10)
                let difference = self.chatBox.frame.origin.y - (self.tableView.frame.origin.y + self.tableView.frame.height + 13)
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: self.tableView.frame.height + difference)
                self.tableView.updateConstraints()
            }
            }, constraintBasedActionHandler: nil)
        
        if Chat.username != nil {
            Chat.getChat(reload)
        }
    }

    deinit {
        releaseAll()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func releaseAll() {
        //self.view.removeKeyboardControl()
        Chat.releaseChat()
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if Chat.username == nil {
                self.welcomeCenter.constant = keyboardFrame.size.height + 10 - self.timeBarHeight.constant
            } else {
                self.bottomConstraint.constant = keyboardFrame.size.height + 10 - self.timeBarHeight.constant
            }
            }, completion: {(completed) in
                if Chat.username != nil {
                    self.tableView.updateConstraints()
                    if self.posts.count > 0 {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.posts.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
                    }
                }
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomConstraint.constant = 10
            self.welcomeCenter.constant = 8
        })
    }
    
    
    @IBAction func tapToReleaseKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendChat()
        return true
    }
    
    func sendChat() {
        let chat : String = chatBox.text ?? ""
        Chat.sendChat(chat, ifNil: showWelcomeView)
        chatBox.text = ""
    }
    
    func showWelcomeView() {
        welcomeMessage.hidden = false
        hideChat.hidden = false
    }
    
    func hideWelcomeView() {
        self.welcomeMessage.hidden = true
        self.hideChat.hidden = true
        view.endEditing(true)
        Chat.getChat(reload)
    }
    
    @IBAction func setUsername(sender: AnyObject) {
        let username : String = usernamePicker.text ?? ""
        if username == "" {
            print("bad username")
        } else {
            Chat.username = username
            hideWelcomeView()
        }
    }
    
    @IBAction func nextActivity(sender: AnyObject) {
        usernamePicker.endEditing(true)
        chatBox.endEditing(true)
        releaseAll()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func reload(posts : [Chat]) {
        self.posts = posts
        self.tableView.reloadData()
        if posts.count > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: posts.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
        }
        if Chat.username == nil {
            UIView.animateWithDuration(0.7, animations: {
                self.hideChat.alpha = 0.7
                }, completion: nil)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCell
        if indexPath.row != 0 {
            cell.makeUI(posts[indexPath.row], previousChat: posts[indexPath.row - 1])
        } else {
            cell.makeUI(posts[indexPath.row], previousChat: nil)
        }
        self.indexPath = indexPath
        return cell
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
        
        let cancelAction = UIAlertAction(title: "Stay in Chat", style: .Cancel, handler: nil)
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
