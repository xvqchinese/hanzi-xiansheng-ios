//
//  ErrorView.swift
//  DWKeyboard
//
//  Created by Aliang on 16/7/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

import Foundation
import UIKit

class ErrorView: UIView
{
    var errorLabel: UILabel!

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.errorLabel = UILabel()
        self.errorLabel.textColor = UIColor.white
        self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.layer.cornerRadius = self.frame.height/4
        self.addSubview(self.errorLabel)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    func setErrorMsg(msg:String)
    {
        self.errorLabel.text = msg
        self.errorLabel.sizeToFit()
        self.errorLabel.frame.origin.x = (self.frame.width - self.errorLabel.frame.width)/2
        self.errorLabel.frame.origin.y = (self.frame.height - self.errorLabel.frame.height)/2
    }
}