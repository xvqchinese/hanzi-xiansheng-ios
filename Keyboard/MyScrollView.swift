//
//  BannerView.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

// this banner sits in the empty space on top of the keyboard
class MyScrollView: UIScrollView {
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool
    {
        return true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        for object in self.subviews
        {
            if (object is RefreshHeaderView) || (object is RefreshFooterView)
            {
                (object as! UIView).frame.size.width = self.bounds.width
            }
        }
    }
    
}
