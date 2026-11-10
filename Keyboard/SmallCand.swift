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

class SmallCand: BannerView
{
    var compBar: UIView = UIView()
    var compLabel: UILabel = UILabel()
    var candBar: MyScrollView = MyScrollView()
    var moreBt : UIButton = UIButton()
    var cands: [UIButton]
    var handler: AnyObject
    var candFontSize: CGFloat = 0
    var font: UIFont! = nil
    
    init(frame: CGRect, handler: AnyObject)
    {
        self.cands = []
        self.handler = handler
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.4)
        self.font = UIFont(name: "Arial", size: (frame.height/2.5))
        
        self.candBar.backgroundColor = self.backgroundColor
        self.addSubview(self.candBar)

        self.compBar.backgroundColor = self.backgroundColor
        self.addSubview(self.compBar)
        
        self.compLabel.font = self.compLabel.font.withSize(frame.height/3.3)
        self.compLabel.textAlignment = .left
        self.compLabel.adjustsFontSizeToFitWidth = true
        self.compLabel.isUserInteractionEnabled = false
        self.compLabel.sizeToFit()
        self.compBar.addSubview(self.compLabel)
        
        self.moreBt.setImage(Globals.images["mr"], for: .normal)
        self.moreBt.setImage(Globals.images["mrp"], for: .selected)
        self.moreBt.setImage(Globals.images["mrp"], for: .highlighted)
        self.moreBt.sizeToFit()
        self.moreBt.addTarget(self.handler, action: Selector("doBigCand"), for: .touchUpInside)
        self.moreBt.backgroundColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.9)
        self.addSubview(self.moreBt)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        self.End()
    }
    
    override func layoutSubviews()
    {
        MyLog("------->> cand bar ->> layoutSubviews")
        
        super.layoutSubviews()
        
        self.moreBt.frame.size.height = self.frame.height
        self.moreBt.frame.size.width = self.frame.width / 11
        self.moreBt.center.y = self.center.y
        self.moreBt.frame.origin.x = self.frame.width - self.moreBt.frame.width
        
        self.compBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/3.3) // - (self.moreBt.frame.width)

        let compHeight = self.compBar.isHidden ? 0 : self.compBar.frame.height
        self.candBar.frame = CGRect(x: 0, y: 0 + compHeight, width: self.frame.width, height: self.frame.height - compHeight) // - (self.moreBt.isHidden ? 0 : self.moreBt.frame.width)

        var contentSize : CGFloat = 0
        var originX : CGFloat = 0
        for cand in self.cands
        {
            cand.frame = CGRect(x: originX, y: 0, width: cand.frame.width, height: self.candBar.frame.height)
            contentSize += cand.frame.width + 1
            originX     += cand.frame.width + 1
        }
        self.candBar.contentSize = CGSize(width: contentSize, height: 0)
    }

    func createCand(_ name: String, idx: Int) -> UIButton
    {
        let tempBt : UIButton = UIButton()
        
        tempBt.setTitle(" \(name) ", for: .normal)
        tempBt.titleLabel?.font = self.font
        tempBt.setTitleColor(UIColor.black, for: .normal)
        tempBt.setTitleColor(UIColor.white, for: .highlighted)
        tempBt.setBackgroundImage(Globals.images["av"], for: .highlighted)
        tempBt.tag = idx
        tempBt.sizeToFit();
        tempBt.addTarget(self.handler, action: Selector("doSelectCand:"), for: .touchUpInside)
        //tempBt.backgroundColor = UIColor.yellow

        self.candBar.addSubview(tempBt)
        return tempBt
    }
    
    func show()
    {
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    func showing() -> Bool
    {
        return (self.isHidden == false)
    }
    
    func updateHwCands(_ str: NSString)
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: true)
        
        var i : Int = 0
        while(i < str.length)
        {
            let hz = str.substring(with: NSRange(location: i, length: 1))
            self.cands.append(self.createCand(hz, idx: i))
            i += 1
        }

        self.setNeedsLayout()
        self.candBar.contentOffset = CGPoint.zero
        self.compBar.isHidden  = true
        self.moreBt.isHidden = true
    }
    
    func updateCands(_ engine: EngineService)
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: true)
        
        var i: Int32 = 0
        let count: Int32 = engine.CandCount()
        for i = 0; i < 50 && i < count; i += 1
        {
            self.cands.append(self.createCand(engine.GetCand(i) as String, idx: Int(i)))
        }

        self.candBar.contentOffset = CGPoint.zero
        self.moreBt.isHidden = false
        self.setNeedsLayout()
    }
    
    func updateComp(_ compStr: NSString, page: Int)
    {
        if !IsNeedComp(page)
        {
            if !self.compBar.isHidden
            {
                self.compBar.isHidden  = true
                self.setNeedsLayout()
            }
        }
        else
        {
            if self.compBar.isHidden
            {
                self.compBar.isHidden  = false
                //self.setNeedsUpdateConstraints()
                self.setNeedsLayout()
            }
            self.compLabel.text = " \(compStr)"
            self.compLabel.sizeToFit()
        }
    }
    
    func Reset()
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: true)
        //self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
        self.candBar.contentOffset = CGPoint.zero
        self.compLabel.text = ""
    }
    
    func End()
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.font = nil
        self.cands.removeAll(keepingCapacity: false)
        self.candBar.removeFromSuperview()
        self.moreBt.removeFromSuperview()
        self.compBar.removeFromSuperview()
        self.compLabel.removeFromSuperview()
    }
}
