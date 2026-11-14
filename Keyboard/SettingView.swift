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

@objcMembers class SettingView: UIView
{
    //var pageSets: UIButton = UIButton()
    //var pageNews: UIButton = UIButton()
    //var pagePhrs: UIButton = UIButton()
    
    var more: UIButton!
    var kbBig: UIButton!
    var kbMid: UIButton!
    var kbSml: UIButton!
    var close: UIButton!
    var gps: UIButton!
    var singleHand: UIButton!
    
    var soundBt : MySwitch!
    var playWavBt : MySwitch!
    
    var setsList: UIScrollView = UIScrollView()
    //var newsList: UIScrollView = UIScrollView()
    //var phrsList: UIView = UIView()
    var hint: UILabel!

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)

        // 设置
        self.soundBt = MySwitch(title: Lang("按键声音"))
        self.playWavBt = MySwitch(title: Lang("中文发音"))
        //self.vibrateBt = MySwitch(title: Lang("按键振动"))
        
        self.more = createMyButton(Lang("  设置  "))
        self.gps = createMyButton(Lang("  定位  "))
        self.singleHand = createMyButton(Globals.singleHand ? Lang("  取消单手  ") : Lang("  单手模式  "))
        self.close = createMyButton(Lang("  返回  "))
        self.kbBig = createMyButton(Lang("  大  "))
        self.kbMid = createMyButton(Lang("  中  "))
        self.kbSml = createMyButton(Lang("  小  "))
        self.kbBig.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.kbMid.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.kbSml.titleLabel?.font = UIFont.systemFont(ofSize: 15)

        if Globals.accessOpen
        {
            self.addSubview(self.setsList)
            self.setsList.addSubview(self.playWavBt)
            self.setsList.addSubview(self.soundBt)
            self.setsList.addSubview(self.gps)
            self.setsList.addSubview(self.singleHand)
            self.setsList.addSubview(self.more)
            self.setsList.addSubview(self.kbBig)
            self.setsList.addSubview(self.kbMid)
            self.setsList.addSubview(self.kbSml)
        }
        else
        {
            self.hint = UILabel()
            self.hint!.textColor = KeyboardColor.mButtonTxtColor
            self.hint!.text = Lang("请打开“完成访问”使用更多功能！")
            self.hint!.sizeToFit()
            self.hint!.layer.zPosition = 100
            self.addSubview(self.hint!)
        }
        self.addSubview(self.close)
        
        self.more.addTarget(self, action: Selector("doMoreSetting"), for: .touchUpInside)
        self.close.addTarget(self.superview?.superclass, action: Selector("doSetting"), for: .touchUpInside)
        self.gps.addTarget(self.superview?.superclass, action: Selector("doLocaltion"), for: .touchUpInside)
        self.singleHand.addTarget(self, action: Selector("doSingleHand"), for: .touchUpInside)
        self.kbBig.addTarget(self, action: Selector("doKbHeight:"), for: .touchUpInside)
        self.kbMid.addTarget(self, action: Selector("doKbHeight:"), for: .touchUpInside)
        self.kbSml.addTarget(self, action: Selector("doKbHeight:"), for: .touchUpInside)
        
        self.backgroundColor = KeyboardColor.mSettingBColor //UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.prv_Load()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func End()
    {
        self.soundBt?.removeFromSuperview()
        self.soundBt = nil
        
        self.playWavBt?.removeFromSuperview()
        self.playWavBt = nil
        
        self.hint?.removeFromSuperview()
        self.close?.removeFromSuperview()
        self.more?.removeFromSuperview()
        self.gps?.removeFromSuperview()
        self.singleHand?.removeFromSuperview()
        self.setsList.removeFromSuperview()
        
        self.close =  nil
        self.more = nil
        self.gps = nil
        self.hint = nil
        self.singleHand = nil
        self.kbBig = nil
        self.kbMid = nil
        self.kbSml = nil
    }
    
    deinit
    {
        MyLog("SettingView --->> deinit")
        self.End()
    }
    
    @objc func doSingleHand()
    {
        Globals.prefs.set(!Globals.singleHand, forKey: "singleHand")
        Globals.Update()
        self.singleHand.setTitle(Globals.singleHand ? Lang("  取消单手  ") : Lang("  单手模式  "), for: .normal)
        NotificationCenter.default.post(name: Notification.Name("DWRelayout"), object: nil)
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
    }
    
    func show()
    {
        self.prv_Load()
        self.isHidden = false
    }
    
    func hide()
    {
        self.prv_Save()
        Globals.Update()
        self.isHidden = true
    }
    func showing() -> Bool
    {
        return (self.isHidden == false)
    }
    
    private func prv_Load()
    {
        self.soundBt.set(Globals.prefs.bool(forKey: "sound"))
        self.playWavBt.set(Globals.prefs.bool(forKey: "playWav"))
    }

    private func prv_Save()
    {
        Globals.prefs.set(self.soundBt.on(), forKey: "sound")
        Globals.prefs.set(self.playWavBt.on(), forKey: "playWav")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.setsList.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.setsList.contentSize = CGSize(width: 0, height: 300)
        
        if true
        {
            self.gps.frame.origin.x = 10
            self.gps.frame.origin.y = 10
            self.gps.frame.size.height = self.gps.frame.size.width

            self.singleHand.frame.origin.x = self.gps.frame.origin.x + self.gps.frame.size.width + 10
            self.singleHand.frame.origin.y = 10
            self.singleHand.frame.size.height = self.more.frame.size.width

            self.more.frame.origin.x = self.singleHand.frame.origin.x + self.singleHand.frame.size.width + 10
            self.more.frame.origin.y = 10
            self.more.frame.size.height = self.more.frame.size.width
            
            let y = self.gps.frame.origin.y + self.gps.frame.size.height + 10
            self.soundBt.frame = CGRect(x: 0, y: y, width: self.frame.width, height: 40)
            self.playWavBt.frame = CGRect(x: 0, y: y+40, width: self.frame.width, height: 40)

            let by = y + 42 + 40
            let bw = min(self.frame.width/3 - 8, 110)
            self.kbBig.frame = CGRect(x: 8, y: by, width: bw, height: 36)
            self.kbMid.frame = CGRect(x: 8 + bw + 8, y: by, width: bw, height: 36)
            self.kbSml.frame = CGRect(x: 8 + (bw + 8)*2, y: by, width: bw, height: 36)
        }

        if self.hint != nil
        {
            self.hint!.frame.origin.x = (self.frame.width - self.hint!.frame.width) / 2
            self.hint!.frame.origin.y = (self.frame.height - self.hint!.frame.height) / 2
        }
        
        self.close.frame.origin.x = self.frame.width/2 - self.close.frame.width/2   // 居中
        self.close.frame.origin.y = self.frame.height - self.close.frame.height*1.2
    }

 
    @objc func doKbHeight(_ sender: UIButton)
    {
        var v: CGFloat = 1.0
        if sender == self.kbBig { v = 1.55 }
        else if sender == self.kbSml { v = 0.75 }
        let gp = UserDefaults(suiteName: "group.DWIME_DS") ?? UserDefaults.standard
        gp.set(CGFloat(v), forKey: "kbheight")
        gp.synchronize()
        Globals.Update()
        NotificationCenter.default.post(name: Notification.Name("DWKbResize"), object: nil)
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
    }

    @objc func doMoreSetting()
    {
        let url: URL? = URL(string: "DWIME.DingShiApp.ext://open-config-app")
        openURL(self, url: url! as NSURL);
    }
}
