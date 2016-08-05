//
//  CategoryDataSource.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/25/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class CategoryDataSource: NSObject, UITableViewDataSource {
    
    var nytimes = [String : Double]()
    var buzzfeed = [String : Double]()
    var video = [String : Double]()
    
    var values = [Double]()
    var labels = [String]()
    
    var dataSource : DataSource!
    
    func calculate() {
        nytimes = ArticleSource.nytimesProbabilities
        buzzfeed = ArticleSource.buzzfeedProbabilities
        video = VideoSource.videoProbabilities
        var total = 0.0
        for (_, num) in nytimes {
            total += num
        }
        for (_, num) in buzzfeed {
            total += num
        }
        for (_, num) in video {
            total += num
        }
        for (key, num) in nytimes {
            let newNum = (num / total) * 100.0
            nytimes[key] = newNum
            values.append(newNum)
            labels.append(key)
        }
        for (key, num) in buzzfeed {
            let newNum = (num / total) * 100.0
            buzzfeed[key] = newNum
            values.append(newNum)
            labels.append(key)
        }
        for (key, num) in video {
            let newNum = (num / total) * 100.0
            video[key] = newNum
            values.append(newNum)
            labels.append(key)
        }
        dataSource = DataSource(items: values)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let color = dataSource.colorForDataPointAtIndex(indexPath.row).CGColor
        cell.imageView?.image = dataSource.makeColorImage(color)
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.layer.masksToBounds = true
        let percent = values[indexPath.row]
        let percentString = String.localizedStringWithFormat("\(labels[indexPath.row]): %.2f", percent) + "%"
        cell.textLabel?.text = percentString
        cell.textLabel?.font = cell.textLabel?.font.fontWithSize(14)
        return cell
    }
}
