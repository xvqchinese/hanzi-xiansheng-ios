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

class CoincidingView: UIView
{
    var candList: MyScrollView = MyScrollView()
    var cands: [UIButton]
    var contentSize: Int = 0
    var handler: AnyObject!
    
    init(handler: AnyObject)
    {
        self.cands = []
        self.handler = handler
        super.init(frame: CGRect.zero)
        
        self.layer.cornerRadius = 3.0
        self.layer.zPosition = 0x101
        self.backgroundColor = KeyboardColor.mCoincidingBColor // UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        
        self.candList.backgroundColor = UIColor.clear    //UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        self.candList.layer.cornerRadius = self.layer.cornerRadius
        self.addSubview(self.candList)
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
        super.layoutSubviews()
        
        self.candList.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        // 排版候选
        var contentSize : CGFloat = 0
        var originY : CGFloat = 0
        for cand in self.cands
        {
            cand.frame.origin.x = 0
            cand.frame.origin.y = originY
            cand.frame.size.width = self.frame.width
            cand.frame.size.height = ((self.frame.height - 3) / 4)

            originY += cand.frame.height + 1
            contentSize += cand.frame.height + 1
        }
        self.candList.contentSize = CGSize(width: 0, height: contentSize)
    }
    
    func show(_ im: Int)
    {
        self.Reset()
        self.setSymbol(im, reset: false)
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
        self.Reset()
    }
    
    func createCand(_ name: String, idx: Int)
    {
        let tempBt : UIButton = UIButton()
        
        tempBt.setTitle(name, for: .normal)
        //tempBt.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 20)
        tempBt.setTitleColor(KeyboardColor.mButtonTxtColor, for: .normal)
        tempBt.setTitleColor(KeyboardColor.mButtonTxtColor_hi, for: .highlighted)
        tempBt.setBackgroundImage(Globals.images["av"], for: .highlighted)
        tempBt.tag = idx
        //tempBt.layer.cornerRadius = self.layer.cornerRadius
        tempBt.sizeToFit();
        tempBt.addTarget(self.handler, action: Selector("doSelectCoinciding:"), for: .touchUpInside)
        tempBt.backgroundColor = KeyboardColor.mCellColor   // UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5) //UIColor.yellow
        
        self.candList.addSubview(tempBt)
        self.cands.append(tempBt)
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
        self.candList.contentOffset = CGPoint.zero
    }
    
    func setSymbol(_ im: Int, reset: Bool)
    {
        if reset
        {
            Reset()
        }
        
        if im == KbPage.M_SK9
        {
            self.createCand("，", idx: -1)
            self.createCand("。", idx: -1)
            self.createCand("？", idx: -1)
            self.createCand("！", idx: -1)
            self.createCand("；", idx: -1)
            self.createCand("：", idx: -1)
            self.createCand(".", idx: -1)
            self.createCand("@", idx: -1)
        }
        else if im == KbPage.M_Abc9 || im == KbPage.M_En9
        {
            self.createCand(",", idx: -1)
            self.createCand(".", idx: -1)
            self.createCand("?", idx: -1)
            self.createCand("!", idx: -1)
            self.createCand(";", idx: -1)
            self.createCand(":", idx: -1)
            self.createCand("@", idx: -1)
            self.createCand("#", idx: -1)
            self.createCand("$", idx: -1)
        }
        else if im == KbPage.M_123
        {
            self.createCand("/", idx: -1)
            self.createCand("+", idx: -1)
            self.createCand("-", idx: -1)
            self.createCand(":", idx: -1)
            self.createCand("=", idx: -1)
            self.createCand("@", idx: -1)
            self.createCand("#", idx: -1)
            self.createCand("$", idx: -1)
        }
    }
    
    func updateSyllable(_ engine: EngineService)
    {
        var i: Int = 0
        let count :Int = engine.syllableNum()
     
        Reset()
        
        for i in 0..<count
        {
            self.createCand(engine.syllableStr(i) as String, idx: i)
        }
    }
    
    func End()
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: false)
        self.handler = nil
        self.candList.removeFromSuperview()
    }
}
