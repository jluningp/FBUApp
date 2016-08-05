//
//  Countdown.swift
//  TeamAdjectiveProject
//
//  Created by David Melvin on 7/8/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class Countdown {
    static var sharedInstance : Countdown?
    
    static var articleViewFunctionCall : (Int -> Void)?
    
    //optional to support starting an stopping by creating new isntaces
    private var timer: NSTimer?
    
    var totalTime : Int = -1 // Original time set plus additional time
    var secsRemaining : Int = -1
    
    
    init(time: NSTimeInterval){
        secsRemaining = Int(time)
        totalTime = Int(time)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(decrementSecsRemaining), userInfo: nil, repeats: true)

    }
    
    //only for testing with specific durations
    init(time: Int){
        
        secsRemaining = time
        totalTime = time
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(decrementSecsRemaining), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func decrementSecsRemaining(sender: AnyObject){
        self.secsRemaining -= 1

        if let articleViewFunctionCall = Countdown.articleViewFunctionCall {
            articleViewFunctionCall(self.secsRemaining)
        }
        
        if(secsRemaining == 0) {
            timerFinished()
        }
    }
    
     func addTime(time: NSTimeInterval){
        if timer == nil {
            print("Timer was done, making new one.")
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(decrementSecsRemaining), userInfo: nil, repeats: true)
        secsRemaining += Int(time)
        totalTime += Int(time)
        }
        else {
            print("timer isn't done yet, but I'll add time anyway.")
            secsRemaining += Int(time)
            totalTime += Int(time)
        }
    }
    
    //for testing purposes
    func addTime(time: Int){
        if timer == nil {
            print("Timer was done, making new one.")
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(decrementSecsRemaining), userInfo: nil, repeats: true)
            secsRemaining += Int(time)
            totalTime += Int(time)
        }
        else {
            print("timer isn't done yet, but I'll add time anyway.")
            secsRemaining += Int(time)
            totalTime += Int(time)
        }
    }
    
     func timerFinished() {
        if timer != nil {
            timer!.invalidate()
            timer = nil //allows us to make a new timer when ready to add time
            print("Timer has finished!")
        }
    }
    
    func formatTime (seconds: Int) -> String {
        //hr and min will only show if time is >=60min or >= 1min
        var formattedTime: String = ""
        if seconds / 3600 >= 1 {
            formattedTime.appendContentsOf("\(seconds/3600)hr")
        }
        if (seconds % 3600)/60 > 1 {
            formattedTime.appendContentsOf(" \((seconds % 3600)/60)m")
        }
        if ((seconds % 3600) % 60) >= 1 {
            formattedTime.appendContentsOf(" \((seconds % 3600) % 60)s")
        }
        return formattedTime
    }
    
    func formattedSecsRemaining() -> String {
        //hr and min will only show if time is >=60min or >= 1min
        var formattedTime: String = ""
        let seconds = Int(secsRemaining)
        if seconds / 3600 >= 1 {
            formattedTime.appendContentsOf("\(seconds/3600)hr")
        }
        if (seconds % 3600)/60 > 1 {
            formattedTime.appendContentsOf(" \((seconds % 3600)/60)m")
        }
        if ((seconds % 3600) % 60) >= 1 {
            formattedTime.appendContentsOf(" \((seconds % 3600) % 60)s")
        }
        return formattedTime
    }

    func getFormatTime() -> String {
        let minutes = Int(secsRemaining / 60)
        let seconds = Int(secsRemaining % 60)
        var printSeconds = "\(seconds)"
        if seconds < 10 {
            printSeconds = "0\(seconds)"
        }
        return "\(minutes):\(printSeconds)"
    }
    
    
}
