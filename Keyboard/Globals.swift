//
//  Globals.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-10-29.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation
import UIKit

struct Globals
{
    //static var vibrate: Bool = false
    static var cnOutConv: Int = 0       // 0 不转，1繁体，2英文
    static var enOutConv: Int = 0       // 0 不转，1中文
    static var playWav: Bool = false
    static var sound: Bool = false
    static var accessOpen: Bool = false
    static var singleHand: Bool = false
    static var gprefs : UserDefaults = UserDefaults(suiteName: "group.DWIME_DS") ?? UserDefaults.standard 
    static var prefs : UserDefaults = UserDefaults.standard
    static var images: [String:UIImage] = [:]
    static var keyboard: Keyboard! = nil
    static var kbHeight: CGFloat!
    static var hwBrush: Bool = false
    static var hwTimeOut: Int = 800
    static var pyStyle: Int = 0

    static var iconColor = UIColor.clear
    static var iconColor_hi = UIColor.clear
    
    
    static func Update()
    {
        //Globals.vibrate = Globals.prefs.bool(forKey: "vibrate")
        // 语音两项设置写在 App Group，键盘优先读共享设置
        let shared = UserDefaults(suiteName: "group.DWIME_DS")
        Globals.sound = shared?.bool(forKey: "keySound") ?? Globals.prefs.bool(forKey: "sound")
        Globals.playWav = shared?.bool(forKey: "playWav") ?? Globals.prefs.bool(forKey: "playWav")
        Globals.singleHand = Globals.prefs.bool(forKey: "singleHand")
 
        // 全局的
        Globals.cnOutConv = Globals.gprefs.integer(forKey: "cnOutConv")
        Globals.enOutConv = Globals.gprefs.integer(forKey: "enOutConv")
        Globals.kbHeight = CGFloat(Globals.gprefs.float(forKey: "kbheight"))
        Globals.hwBrush = Globals.gprefs.bool(forKey: "hwBrush")
        Globals.hwTimeOut = Globals.gprefs.integer(forKey: "hwTimeOut")
        Globals.pyStyle = Globals.gprefs.integer(forKey: "pyStyle")
    }
    
    static func Load()
    {
        Globals.prefs.register(defaults: [
            "vibrate"       : false,
            "sound"         : true,
            "playWav"       : true,
            "singleHand"    : false,
            "defaultEnIM"   : KbPage.M_Abc,
            "defaultCnIM"   : KbPage.M_Chn,
            ])
        // 全局的
        Globals.gprefs.register(defaults: [
            "kbheight" : 0.35,           // 键盘高度
            "cnOutConv"  : 0,
            "enOutConv" : 0,
            "hwBrush" : true,
            "hwTimeOut" : 800,
            "pyStyle":0,        // 0 ds, 1 标准
            ])
        // 以上：设置默认值
        
        Globals.Update()
        
        Globals.accessOpen = accessOpen_check();
        
        // 加载全局数据
        if Globals.keyboard == nil
        {
            Globals.keyboard = defaultKeyboard_xfm()
        }
        
        // image res
        if Globals.images.count == 0 ||
            Globals.iconColor != KeyboardColor.mIconColor ||
            Globals.iconColor_hi != KeyboardColor.mIconColor_hi
        {
            Globals.images.removeAll()
            Globals.iconColor = KeyboardColor.mIconColor
            Globals.iconColor_hi = KeyboardColor.mIconColor_hi
            
            Globals.images["av"]  = UIImage(named:"cand_active.png")
            Globals.images["bokc"] = UIImage(named: "book_closed.png")
            Globals.images["boko"] = UIImage(named: "book_open.png")
            
            Globals.images["mr"]  = loadColorIcon("cands_buttonTomore.png", color: Globals.iconColor)            // UIImage(named:"cands_buttonTomore.png")
            Globals.images["mrp"] = loadColorIcon("cands_buttonTomore_press.png", color: Globals.iconColor_hi)   // UIImage(named:"cands_buttonTomore_press.png")
            
            Globals.images["phr"]  = loadColorIcon("phrase.png", color: Globals.iconColor)                       // UIImage(named:"phrase.png")
            Globals.images["phrp"] = loadColorIcon("phrase_press.png", color: Globals.iconColor_hi)              // UIImage(named:"phrase_press.png")
            
            Globals.images["car"]  = loadColorIcon("candcaret.png", color: Globals.iconColor)                    // UIImage(named:"candcaret.png")
            Globals.images["carp"] = loadColorIcon("candcaret_press.png", color: Globals.iconColor_hi)           // UIImage(named:"candcaret_press.png")
            
            //Globals.images["set"]  = loadColorIcon("toolbar_icon_setting.png", color: Globals.iconColor)         // UIImage(named:"toolbar_icon_setting.png")
            //Globals.images["setp"] = loadColorIcon("toolbar_icon_setting_press.png",color: Globals.iconColor_hi) // UIImage(named:"toolbar_icon_setting_press.png")
            Globals.images["set"]  = UIImage(named:"toolbar_icon_logo.png")
            Globals.images["setp"] = UIImage(named:"toolbar_icon_logo_press.png")
            
            Globals.images["kbd"]  = loadColorIcon("toolbar_icon_swKB.png", color: Globals.iconColor)            // UIImage(named:"toolbar_icon_swKB.png")
            Globals.images["kbdp"] = loadColorIcon("toolbar_icon_swKB_press.png", color: Globals.iconColor_hi)   // UIImage(named:"toolbar_icon_swKB_press.png")
            
            Globals.images["hid"]  = loadColorIcon("toolbar_icon_hide.png", color: Globals.iconColor)            // UIImage(named:"toolbar_icon_hide.png")
            Globals.images["hidp"] = loadColorIcon("toolbar_icon_hide_press.png", color: Globals.iconColor_hi)   // UIImage(named:"toolbar_icon_hide_press.png")
            
            Globals.images["sml"]  = loadColorIcon("smile.png", color: Globals.iconColor)                        // UIImage(named: "smile.png")
            Globals.images["smlp"] = loadColorIcon("smile_press.png", color: Globals.iconColor_hi)               // UIImage(named: "smile_press.png")
        }
        /*
        if Globals.mForwardingView == nil
        {
            Globals.mForwardingView = ForwardingView(frame: CGRect.zero)
        }
        
        if Globals.layout == nil
        {
            RunTimeBegin()
            Globals.layout = KeyboardLayout(model: Globals.keyboard, superview: Globals.mForwardingView)
            RunTimeEnd("init layout")
        }*/
    }

    static func End()
    {
        //Globals.images.removeAll(keepingCapacity: false)
    }
}