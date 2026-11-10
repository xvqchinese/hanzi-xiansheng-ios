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
static let M_Chn: Int = 0               // 新方
static let M_Eng: Int = 1
static let M_123_CN: Int = 2
static let M_Sym_CN: Int = 3
static let M_123_EN: Int = 4
static let M_Sym_EN: Int = 5

static let M_XFPY: Int  = 6             // 拼音
static let M_XFBH: Int  = 7             // 笔画
static let M_XFWb: Int  = 8             // 五笔
static let M_XFSM: Int  = 9             // 数码
static let M_XF5B: Int  = 10            // 5笔
static let M_XFQP: Int  = 11            // 全拼
static let M_XFCJ: Int  = 12            // 仓颉
static let M_XFXB: Int  = 13            // 新部
static let M_XFBS: Int  = 14            // 部首
*/

class SelectKBView: UIView
{
    
    var py26Bt : UIButton!
//    var py9Bt : UIButton!
//    var wbBt : UIButton!
    var hwBt : UIButton!
    var skBt : UIButton!
    var en26Bt : UIButton!
    var en9Bt : UIButton!
//    var cjBt : UIButton!
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = KeyboardColor.mSelKbBColor
        
        self.py26Bt = self.createBt("智能拼音",    image: "ipy26", page: KbPage.M_Chn)
//        self.py9Bt = self.createBt("九营格拼音",   image: "ipy9", page: KbPage.M_PY9)
        self.en26Bt = self.createBt("英文全键盘",  image: "ien26", page: KbPage.M_En26)
        self.en9Bt = self.createBt("英文九营格",   image: "ien9",page: KbPage.M_En9)
//        self.wbBt = self.createBt("五笔字形",     image: "iwb26",page: KbPage.M_XFWB)
        self.skBt = self.createBt("笔画",        image: "isk",page: KbPage.M_SK9)
        self.hwBt = self.createBt("手写",        image: "ihw",page: KbPage.M_HW)
//        self.cjBt = self.createBt("仓颉",        image: "icj26",page: KbPage.M_XFCJ)

        self.addSubview(self.py26Bt)
//        self.addSubview(self.py9Bt)
//        self.addSubview(self.wbBt)
        self.addSubview(self.hwBt)
//        self.addSubview(self.cjBt)
        self.addSubview(self.skBt)
        self.addSubview(self.en26Bt)
        self.addSubview(self.en9Bt)

        self.py26Bt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
//        self.py9Bt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
//        self.wbBt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
//        self.cjBt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
        self.hwBt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
        self.en26Bt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
        self.en9Bt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
        self.skBt.addTarget(self.superview?.superclass, action: Selector("doSelectKB:"), for: .touchUpInside)
    }
    
    deinit
    {
        MyLog("SelectKBView --->> deinit")

        self.py26Bt = nil
//        self.py9Bt = nil
//        self.wbBt = nil
        self.hwBt = nil
//        self.cjBt = nil
        
        self.skBt = nil
        self.en26Bt = nil
        self.en9Bt = nil
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ superclass: KeyboardViewController)
    {
        let curIm = superclass.currentPage
    
        for bt in [self.py26Bt, /*self.py9Bt, self.wbBt, self.cjBt, */self.hwBt, self.en26Bt, self.en9Bt, self.skBt]
        {
            if bt?.tag == curIm
            {
                //bt.isHighlighted = true
                bt?.backgroundColor = KeyboardColor.mCellColor_hi // UIColor.blue.withAlphaComponent(0.25)
            }
            else
            {
                //bt.isHighlighted = false
                bt?.backgroundColor = UIColor.clear
            }
        }
        if curIm == KbPage.M_Abc
        {
            //self.en26Bt.isHighlighted = true
            self.en26Bt.backgroundColor = KeyboardColor.mCellColor_hi   // UIColor.blue.withAlphaComponent(0.25)
        }
        else if curIm == KbPage.M_Abc9
        {
            //self.en9Bt.isHighlighted = true
            self.en9Bt.backgroundColor = KeyboardColor.mCellColor_hi    // UIColor.blue.withAlphaComponent(0.25)
        }
        
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
    
    func createBt(_ name: String, image: String, page: Int) -> UIButton
    {
        let tempBt : UIButton = UIButton()

        tempBt.setImage(UIImage(named:image+".png"), for: .normal)
        tempBt.setImage(UIImage(named:image+".png"), for: .selected)
        tempBt.setImage(UIImage(named:image+".png"), for: .highlighted)
        
        tempBt.setBackgroundImage(Globals.images["av"], for: .highlighted)
        
        //tempBt.backgroundColor = UIColor.blue
        tempBt.layer.cornerRadius = 5.0

        /**
        tempBt.setTitle("", for: .normal)
        tempBt.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 12)
        tempBt.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tempBt.titleLabel?.textAlignment = .center
        tempBt.titleLabel?.shadowColor = UIColor.white
        tempBt.titleLabel?.shadowOffset = CGSize(width: 2, height: 2)
        tempBt.setTitleColor(UIColor.black, for: .normal)
        tempBt.setTitleColor(UIColor.white, for: .highlighted)
        */
        tempBt.contentMode = .scaleAspectFit
        tempBt.tag = page

        /**
        var tempBt : UIImageView = UIImageView()
        tempBt.set
        tempBt.setBackgroundImage(UIImage(named:image+".png"), for: .normal)
        tempBt.setBackgroundImage(UIImage(named:image+".png"), for: .selected)
        tempBt.setBackgroundImage(UIImage(named:image+".png"), for: .highlighted)
        tempBt.contentMode = .scaleAspectFit
        tempBt.tag = page*/

        return tempBt
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()

        let height: CGFloat = 80.0
        let width: CGFloat = 80.0
        let beginY = self.frame.height * 0.1
        let padding:CGFloat = (self.frame.width - width * 3) / 4
        let vGap:CGFloat = 10
        
        //self.cjBt.frame     = CGRect(x: width*1 + padding + hGap * 1, y: beginY, width: height, height: height)
        //self.wbBt.frame     = CGRect(x: width*2 + padding + hGap * 2, y: beginY, width: height, height: height)
        //self.py9Bt.frame    = CGRect(x: width*0 + padding, y: beginY+height + vGap, width: height, height: height)
        
        self.py26Bt.frame   = CGRect(x: width*0.0 + padding, y: beginY, width: height, height: height)
        self.hwBt.frame     = CGRect(x: width*1.0 + padding + padding * 1, y: beginY, width: height, height: height)
        self.skBt.frame     = CGRect(x: width*2.0 + padding + padding * 2, y: beginY, width: height, height: height)

        self.en26Bt.frame   = CGRect(x: width*0.0 + padding, y: beginY+height + vGap, width: height, height: height)
        self.en9Bt.frame    = CGRect(x: width*2.0 + padding + padding * 2, y: beginY+height + vGap, width: height, height: height)
    }
    
}
