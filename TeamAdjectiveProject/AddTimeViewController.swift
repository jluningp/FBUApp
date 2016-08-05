//
//  AddTimeViewController.swift
//  TeamAdjectiveProject
//
//  Created by Allison Tang on 7/7/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class AddTimeViewController: UIViewController {

    @IBOutlet weak var addTimeDatePicker: UIDatePicker!
    @IBOutlet weak var doneWaitingButton: UIButton!
    var delegate: HomeViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addTimeDatePicker.datePickerMode = UIDatePickerMode.CountDownTimer
        
        // Do any additional setup after loading the view.
        let darkBlue = UIColor(red: CGFloat(46.0/255.0), green: CGFloat(64.0/255.0),blue: CGFloat(87.0/255.0),  alpha: CGFloat(1.0))
        
        addTimeDatePicker.setValue(darkBlue, forKeyPath: "textColor")
        
        doneWaitingButton.titleLabel?.shadowColor = doneWaitingButton.titleLabel?.textColor
        
        
        doneWaitingButton.titleLabel!.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
        doneWaitingButton.titleLabel!.layer.shadowRadius = 10.0;
        doneWaitingButton.titleLabel!.layer.shadowOpacity = 0.7;
        doneWaitingButton.titleLabel!.layer.shadowOffset = CGSize(width: 1, height: 1);
        doneWaitingButton.titleLabel!.layer.masksToBounds = false;
        addTimeDatePicker.subviews[0].subviews[1].backgroundColor = UIColor(red: CGFloat(46.0/255.0), green: CGFloat(64.0/255.0),blue: CGFloat(87.0/255.0),  alpha: CGFloat(0.2))
        addTimeDatePicker.subviews[0].subviews[2].backgroundColor = UIColor(red: CGFloat(46.0/255.0), green: CGFloat(64.0/255.0),blue: CGFloat(87.0/255.0),  alpha: CGFloat(0.2))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAddTime(sender: AnyObject) {
        print("add \(addTimeDatePicker.countDownDuration) seconds")
        Countdown.sharedInstance?.addTime(addTimeDatePicker.countDownDuration)
        //how to do "back" instead of making a new ArticleViewController?
        //self.navigationController!.pushViewController(ArticleViewController() as UIViewController, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
        
        
    }

    @IBAction func onDoneWaiting(sender: AnyObject) {
        Countdown.sharedInstance = nil //end that countdown
        self.navigationController!.pushViewController(HomeViewController() as UIViewController, animated: true)
        
    }

    @IBAction func onSettings(sender: AnyObject) {
        self.navigationController!.pushViewController(SettingsViewController() as UIViewController, animated: true)
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

//protocol AddTimeDelegate {
//    func didFinishAddTime(controller: AddTimeViewController)
//}