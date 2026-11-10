//
//  KeyboardColor.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-10-29.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardColor
{
    static var mKbBackgroundColor: UIColor!   // ForwardingView 的背景
    static var mSettingBColor: UIColor!
    static var mSelKbBColor: UIColor!
    static var mSmileBColor: UIColor!

    static var mCommandBColor: UIColor!     // 图标栏
    static var mCandBColor: UIColor!        // 候选
    static var mCandDownBColor: UIColor!    // 候选栏，下拉按钮
    static var mCellColor: UIColor!         // 大候选，表情图，方格颜色
    static var mCellColor_hi: UIColor!      // 大候选，表情图，方格颜色 hi
    
    static var mHwBColor: UIColor!          // 手写
    static var mCoincidingBColor: UIColor!  // 音节
    
    static var mKeyColor: UIColor!           // common key 颜色
    static var mKeyColor_hi: UIColor!        // common key 颜色 hi
    static var mFunKeyColor: UIColor!        // fun key 颜色
    static var mFunKeyColor_hi: UIColor!     // fun key 颜色 hi
    static var mKeyShadowColor: UIColor!     // key 3d 效果
    static var mKeyTxtColor: UIColor!        // common key 字体颜色
    static var mSmallTxtColor: UIColor!      // 小字颜色
    static var mFunKeyTxtColor: UIColor!     // func key 字体颜色
    static var mFunKeyGraColor: UIColor!     // func key 图形颜色
    
    static var mCandTxtColor: UIColor!
    static var mIconColor: UIColor!             // 图标颜色
    static var mIconColor_hi: UIColor!             // 图标颜色
    
    static var mButtonTxtColor: UIColor!
    static var mButtonTxtColor_hi: UIColor!
    static var mButtonBColor: UIColor!
    static var mButtonBColor_hi: UIColor!
    
    static var mHwQueryTxtColor: UIColor!      // 手写反查
    static var mHwStrokeColor: UIColor!     // 手写笔画颜色
    
    static func Load()
    {
        // 先设置为默认的颜色，防止后面没有设置或漏设置
        LoadDefault()
        
        /***
          文件内容示例：bkbcolor=0xff998877|setbcolor=0xff778899
         ***/
        if let content = loadStringFileFromGroup("colorProfile")
        {
            let colorAry = content.components(separatedBy: "&")
            
            for one in colorAry
            {
                if one.count > 0
                {
                    let param = one.components(separatedBy: "=")
                    if param.count == 2
                    {
                        let varName = param[0];   // 变量名
                        let color = param[1];   // 颜色值
                        
                        if color.count > 0
                        {
                            switch(varName)
                            {
                            case "KbBColor":            KeyboardColor.mKbBackgroundColor = string2Color(color); break;
                            case "SettingBColor":       KeyboardColor.mSettingBColor    = string2Color(color); break;
                            case "SelKbBColor":         KeyboardColor.mSelKbBColor      = string2Color(color); break;
                            case "SmileBColor":         KeyboardColor.mSmileBColor      = string2Color(color); break;
                                
                            case "CoincidingBColor":    KeyboardColor.mCoincidingBColor = string2Color(color); break;
                            case "HwBColor":            KeyboardColor.mHwBColor         = string2Color(color); break;
                                
                            case "CommandBColor":       KeyboardColor.mCommandBColor    = string2Color(color); break;
                            case "CandBColor":          KeyboardColor.mCandBColor       = string2Color(color); break;
                            case "CandDownBColor":      KeyboardColor.mCandDownBColor   = string2Color(color); break;
                            case "CellColor":           KeyboardColor.mCellColor        = string2Color(color); break;
                            case "CellColor_hi":        KeyboardColor.mCellColor_hi     = string2Color(color); break;
                                
                            case "KeyColor":            KeyboardColor.mKeyColor         = string2Color(color); break;
                            case "KeyColor_hi":         KeyboardColor.mKeyColor_hi      = string2Color(color); break;
                            case "FunKeyColor":         KeyboardColor.mFunKeyColor      = string2Color(color); break;
                            case "FunKeyColor_hi":      KeyboardColor.mFunKeyColor_hi   = string2Color(color); break;
                            case "KeyShadowColor":      KeyboardColor.mKeyShadowColor   = string2Color(color); break;
                            case "KeyTxtColor":         KeyboardColor.mKeyTxtColor      = string2Color(color); break;
                            case "SmallTxtColor":       KeyboardColor.mSmallTxtColor    = string2Color(color); break;
                            case "FunKeyTxtColor":      KeyboardColor.mFunKeyTxtColor   = string2Color(color); break;
                            case "FunKeyGraColor":      KeyboardColor.mFunKeyGraColor   = string2Color(color); break;
                                
                            case "CandTxtColor":        KeyboardColor.mCandTxtColor     = string2Color(color); break;
                            case "IconColor":           KeyboardColor.mIconColor        = string2Color(color); break;
                            case "IconColor_hi":        KeyboardColor.mIconColor_hi     = string2Color(color); break;
    
                            case "ButtonBColor":        KeyboardColor.mButtonBColor     = string2Color(color); break;
                            case "ButtonBColor_hi":     KeyboardColor.mButtonBColor_hi  = string2Color(color); break;
                            case "ButtonTxtColor":      KeyboardColor.mButtonTxtColor   = string2Color(color); break;
                            case "ButtonTxtColor_hi":   KeyboardColor.mButtonTxtColor_hi = string2Color(color); break;
                            case "HwQueryTxtColor":     KeyboardColor.mHwQueryTxtColor  = string2Color(color); break;
                            case "HwStrokeColor":       KeyboardColor.mHwStrokeColor    = string2Color(color); break;

                            default:
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    private static func LoadDefault()
    {
        KeyboardColor.mKbBackgroundColor    = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        KeyboardColor.mSettingBColor        = KeyboardColor.mKbBackgroundColor
        KeyboardColor.mSelKbBColor          = KeyboardColor.mKbBackgroundColor
        KeyboardColor.mSmileBColor          = KeyboardColor.mKbBackgroundColor
        
        KeyboardColor.mCoincidingBColor     = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        KeyboardColor.mHwBColor             = UIColor.clear

        KeyboardColor.mCommandBColor        = UIColor(red: 210/255, green: 214/255, blue: 219/255, alpha: 1)
        KeyboardColor.mCandBColor           = UIColor(red: 210/255, green: 214/255, blue: 219/255, alpha: 1)
        KeyboardColor.mCandDownBColor       = UIColor.gray.withAlphaComponent(0.80)
        KeyboardColor.mCellColor            = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5)
        KeyboardColor.mCellColor_hi         = UIColor.gray.withAlphaComponent(0.5)
        
        KeyboardColor.mKeyColor             = UIColor.white
        KeyboardColor.mKeyColor_hi          = UIColor.gray.withAlphaComponent(0.5)
        KeyboardColor.mFunKeyColor          = UIColor.gray.withAlphaComponent(0.80)
        KeyboardColor.mFunKeyColor_hi       = UIColor.white.withAlphaComponent(0.5)
        KeyboardColor.mKeyShadowColor       = UIColor.gray
        KeyboardColor.mKeyTxtColor          = UIColor.black
        KeyboardColor.mSmallTxtColor        = UIColor.black
        KeyboardColor.mFunKeyTxtColor       = UIColor.black
        KeyboardColor.mFunKeyGraColor       = UIColor.white

        KeyboardColor.mCandTxtColor         = UIColor.black
        KeyboardColor.mIconColor            = UIColor.clear
        KeyboardColor.mIconColor_hi         = UIColor.clear
        
        KeyboardColor.mButtonBColor         = UIColor.white
        KeyboardColor.mButtonBColor_hi      = UIColor.gray.withAlphaComponent(0.5)
        KeyboardColor.mButtonTxtColor       = UIColor.black
        KeyboardColor.mButtonTxtColor_hi    = UIColor.brown
        
        KeyboardColor.mHwQueryTxtColor      = UIColor.gray;
        KeyboardColor.mHwStrokeColor        = UIColor(red: 0, green: 0, blue: 0, alpha: 1) // 要用 rgb 空间表示，不然在画线的时候无法分解 rgb
    }

    static func End()
    {
    }
    
}





