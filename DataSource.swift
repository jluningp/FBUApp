//
//  DataSource.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/25/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import ASPCircleChart

class DataSource : ASPCircleChartDataSource {
    var items: [Double]
    var colors : [UIColor]
    
    init(items : [Double]) {
        self.items = items
        self.colors = Array(count: items.count, repeatedValue: UIColor.whiteColor())
        let defaults = [UIColor.purpleColor(), UIColor.blueColor(), UIColor.cyanColor(), UIColor.greenColor(), UIColor.yellowColor()]
        for i in 0..<self.colors.count {
            if i < defaults.count {
                self.colors[i] = defaults[i]
            } else {
                self.colors[i] = UIColor(red: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), green: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), alpha: 1.0)
            }
        }
    }
    
    @objc func numberOfDataPoints() -> Int {
        return items.count
    }
    
    @objc func dataPointsSum() -> Double {
        return items.reduce(0.0, combine: { (initial, new) -> Double in
            return initial + new
        })
    }
    
    @objc func dataPointAtIndex(index: Int) -> Double {
        return items[index]
    }
    
    
    @objc func colorForDataPointAtIndex(index: Int) -> UIColor {
        return colors[index]
    }
    
    func makeColorImage(color : CGColor) -> UIImage {
        let rect : CGRect = CGRectMake(0, 0, 30, 20)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, color)
        CGContextFillRect(context, rect);
        
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}