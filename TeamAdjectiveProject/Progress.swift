//
//  Progress.swift
//  TeamAdjectiveProject
//
//  Created by Allison Tang on 7/18/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class Progress: NSObject {
    static var sharedInstance: Progress?
    //mimic Countdown class but update more often
    var timeOn: Bool = true
    var progress: Float = 0.0
    
    func updateProgress() -> (Float) {
        while timeOn == true {
        let percentDone = 1 - ((Countdown.sharedInstance?.secsRemaining)! / (Countdown.sharedInstance?.totalTime)!)
        progress = Float(percentDone)
        if progress == 1.0 {
            print ("time is up!")
            //self.navigationController?.pushViewController(AddTimeViewController() as UIViewController, animated: true)
        }
        print (progress)
    }
        return progress
    }


}
