//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/

class MySwitch: UIView
{
    var label: UILabel = UILabel()
    var _switch: UISwitch = UISwitch()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String)
    {
        super.init(frame: CGRect.zero)
        
        //self.backgroundColor = UIColor.yellow
        self.label.text = title
        self.label.sizeToFit()
        self.label.textColor = KeyboardColor.mButtonTxtColor
        
        self.addSubview(self.label)
        self.addSubview(self._switch)
    }
    
    deinit
    {
        // release obj ...
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()

        self.label.frame.origin.x = 10
        self.label.frame.origin.y = (self.frame.height - self.label.frame.height) / 2

        self._switch.frame.origin.x = self.frame.width - self._switch.frame.width - 10
        self._switch.frame.origin.y = (self.frame.height - self._switch.frame.height) / 2
    }
    
    func on() -> Bool
    {
        return self._switch.isOn
    }
    
    func set(_ on: Bool)
    {
        self._switch.setOn(on, animated: false)
    }
}
