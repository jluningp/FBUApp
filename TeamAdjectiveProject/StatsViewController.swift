//
//  StatsViewController.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/25/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import ASPCircleChart

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var circleChart: ASPCircleChart!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var categoryChart: ASPCircleChart!
    @IBOutlet weak var categoryTable: UITableView!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    var dataSource : DataSource!
    
    
    var labels = [String]()
    var values = [Double]()
    
    let categoryTableDataSource = CategoryDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableDataSource.calculate()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        categoryTable.dataSource = categoryTableDataSource
        categoryTable.delegate = self
        
        navigationItem.title = "Stats"
        
        values = Array(ArticleSource.typeProbabilities.values.map({ (prob) -> Double in
            prob * 100.0
        }))
        labels = Array(ArticleSource.typeProbabilities.keys)
        if values.count == 0 || categoryTableDataSource.values.count == 0 {
            noDataLabel.hidden = false
        } else {
            noDataLabel.hidden = true
        }
        
        dataSource = DataSource(items: values)
        circleChart.dataSource = dataSource
        circleChart.reloadData()
        tableView.reloadData()
        
        categoryChart.dataSource = categoryTableDataSource.dataSource
        categoryChart.reloadData()
        categoryTable.reloadData()

        // Do any additional setup after loading the view.
    }

    func done(sender : AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    @IBAction func showWhenDeletePressed(sender: AnyObject) {
        let title = "Are you sure?"
        let message = "Your viewing information is used to provide better recommendations. Are you sure you want to delete all viewing data?\n\n(Note: Your video/article preferences will not be deleted.)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action) in self.deleteData() })
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deleteData() {
        UserTracking.clearData()
        ArticleSource.reset()
        noDataLabel.hidden = false
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
