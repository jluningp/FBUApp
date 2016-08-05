//
//  TestViewController.swift
//  
//
//  Created by Jeanne Luning Prak on 7/29/16.
//
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var countingUp: UILabel!
    
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        countingUp.text = "Counting Up: \(counter)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
