//
//  ArticleView.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/14/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class ArticleView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    
    func setText(article : NSAttributedString) {
        print(self.textView)
        self.textView.attributedText = article
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
