//
//  ChatCell.swift
//  TeamAdjectiveProject
//
//  Created by Jeanne Luning Prak on 7/13/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    var messageLabel = UILabel()
    var usernameLabel = UILabel()
    var chatView = UIView()
    var myMessageConstraints = [NSLayoutConstraint]()
    var otherMessageConstraints = [NSLayoutConstraint]()
    var spacingConstraint : NSLayoutConstraint?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFontOfSize(16)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFontOfSize(13)
        
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.layer.cornerRadius = 10
        chatView.layer.masksToBounds = true
        chatView.addSubview(messageLabel)
        contentView.addSubview(usernameLabel)
        
        contentView.addSubview(chatView)

        layout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func makeUI(chat : Chat, previousChat : Chat?) {
        if let previousChat = previousChat {
            if chat.userID == previousChat.userID {
                usernameLabel.text = ""
            } else {
                usernameLabel.text = chat.username
            }
        } else {
            usernameLabel.text = chat.username
        }
        if chat.userID == Chat.userID {
            let bubbleColor = Settings.buttonBackground
            chatView.backgroundColor = bubbleColor
            usernameLabel.textColor = bubbleColor
            messageLabel.textColor = .whiteColor()
            for constraint in otherMessageConstraints {
                constraint.active = false
            }
            for constraint in myMessageConstraints {
                constraint.active = true
            }
        } else {
            chatView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            usernameLabel.textColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0)
            messageLabel.textColor = .blackColor()
            for constraint in myMessageConstraints {
                constraint.active = false
            }
            for constraint in otherMessageConstraints {
                constraint.active = true
            }
        }
        messageLabel.text = chat.message
    }
    
    func layout() {
        NSLayoutConstraint(item: messageLabel,
                           attribute: .Leading,
                           relatedBy: .Equal,
                           toItem: chatView,
                           attribute: .LeadingMargin,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: messageLabel,
                           attribute: .Trailing,
                           relatedBy: .Equal,
                           toItem: chatView,
                           attribute: .TrailingMargin,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: messageLabel,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: chatView,
                           attribute: .TopMargin,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: messageLabel,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: chatView,
                           attribute: .BottomMargin,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: usernameLabel,
                           attribute: .Leading,
                           relatedBy: .Equal,
                           toItem: chatView,
                           attribute: .Leading,
                           multiplier: 1.0,
                           constant: 5.0).active = true
        
        NSLayoutConstraint(item: usernameLabel,
                           attribute: .Trailing,
                           relatedBy: .Equal,
                           toItem: contentView,
                           attribute: .TrailingMargin,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: usernameLabel,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: contentView,
                           attribute: .Top,
                           multiplier: 1.0,
                           constant: 0.0).active = true
        
        NSLayoutConstraint(item: chatView,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: usernameLabel,
                           attribute: .Bottom,
                           multiplier: 1.0,
                           constant: 2.0).active = true
        
        spacingConstraint = NSLayoutConstraint(item: chatView,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: contentView,
                           attribute: .Bottom,
                           multiplier: 1.0,
                           constant: -7.0)
        spacingConstraint!.active = true
        
        NSLayoutConstraint(item: chatView,
                           attribute: .Width,
                           relatedBy: .LessThanOrEqual,
                           toItem: contentView,
                           attribute: .Width,
                           multiplier: 0.75,
                           constant: 0.0).active = true
        
        let otherleft = NSLayoutConstraint(item: chatView,
                                      attribute: .Leading,
                                      relatedBy: .Equal,
                                      toItem: contentView,
                                      attribute: .LeadingMargin,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let myright = NSLayoutConstraint(item: chatView,
                                      attribute: .Trailing,
                                      relatedBy: .Equal,
                                      toItem: contentView,
                                      attribute: .TrailingMargin,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        myMessageConstraints.append(myright)
        
        otherMessageConstraints.append(otherleft)
        
    }

}
