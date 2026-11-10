//
//  KeyboardModel.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation
import UIKit

var counter = 0

struct KbPage
{
    static let M_Chn: Int = 0               // 拼音26
    static let M_Abc: Int = 1
    
    static let M_123_CN: Int = 2
    static let M_Sym_CN: Int = 3
    static let M_123_EN: Int = 4
    static let M_Sym_EN: Int = 5
    
    static let M_SK9: Int = 17              // 笔画 9
    static let M_En9: Int = 18              // 智能英文 9
    static let M_En26:Int = 19              // 智能英文26
    static let M_Abc9:Int = 20
    static let M_HW:  Int = 21
    static let M_123: Int = 22
}

func IsEnglishKB(_ page: Int) -> Bool
{
    if page == KbPage.M_Abc || page == KbPage.M_Abc9 || page == KbPage.M_En26 || page == KbPage.M_En9
    {
        return true
    }
    else
    {
        return false
    }
}

func IsNeedEngine(_ page: Int) -> Bool
{
    switch page
    {
    case KbPage.M_Chn, KbPage.M_SK9, KbPage.M_En26, KbPage.M_En9, KbPage.M_HW:
        return true
    
    default:
        return false
    }
}

func IsNeedCoinciding(_ page: Int) -> Bool
{
    switch page
    {
    case KbPage.M_SK9, KbPage.M_En9, KbPage.M_Abc9, KbPage.M_123:
        return true
        
    default:
        return false
    }
}

func IsNeedComp(_ page: Int) -> Bool
{
    switch page
    {
    case KbPage.M_En9, KbPage.M_En26, KbPage.M_Abc9, KbPage.M_Abc, KbPage.M_HW:
        return false
        
    default:
        return true
    }
}


class Keyboard
{
    var pages: [Page]
    
    init()
    {
        self.pages = []
    }
    
    deinit
    {
        self.End()
    }
    
    func End()
    {
        self.pages.removeAll(keepingCapacity: false)
    }
    
    // 没有 pop
    func addKey9(_ key: Key, row: Int, width: CGFloat, page: Int)
    {
        self.privAddKey(key, row: row, width: width, page: page, pop: false)
    }

    // 有 pop
    func addKey(_ key: Key, row: Int, width: CGFloat, page: Int)
    {
        self.privAddKey(key, row: row, width: width, page: page, pop: true)
    }
    
    func privAddKey(_ key: Key, row: Int, width: CGFloat, page: Int, pop: Bool)
    {
        key.showPop = pop
        key.widthRatio = width
        if self.pages.count <= page
        {
            for _ in self.pages.count...page
            {
                self.pages.append(Page())
            }
        }
        
        self.pages[page].addKey(key, row: row)
    }
}

class Page
{
    var rows: [[Key]]
    
    init()
    {
        self.rows = []
    }
    
    deinit
    {
        self.rows.removeAll(keepingCapacity: false)
    }
    
    func addKey(_ key: Key, row: Int)
    {
        if self.rows.count <= row
        {
            for _ in self.rows.count...row
            {
                self.rows.append([])
            }
        }

        self.rows[row].append(key)
    }
}

class Key: Hashable
{
    enum KeyType
    {
        case Character
        case SpecialCharacter
        case Shift
        case Backspace
        case Separate           // 分隔符
        case KeyboardChange
        case Period             // 标点
        case Space
        case Return
        case Mode2Eng
        case Mode2T9_123
        case Mode2PopupSymb
        case Mode2123_CN        // 26 键数字 + 中文符号
        case Mode2123_EN
        case Mode2Chn
        case Mode2Sym_CN        // 26 键中文符号
        case Mode2Sym_EN
        case Mode2SmartEN
        case Mode2CommonEN
        case ModeRet_Chn    // 返回中文状态
        case ModeRet_Eng    // 返回英文状态
        case ModeRet_Auto   // 返回
        case Hidden         // 不显示的按钮
        
        func __specialButton() -> Bool
        {
            switch self
            {
            case Key.KeyType.Shift:
                return true
            case Key.KeyType.Backspace:
                return true
            case Key.KeyType.KeyboardChange:
                return true
            case Key.KeyType.Mode2Eng,Key.KeyType.Mode2123_CN,Key.KeyType.Mode2123_EN,Key.KeyType.Mode2Chn,Key.KeyType.Mode2Sym_CN,Key.KeyType.Mode2Sym_EN,Key.KeyType.Separate,Key.KeyType.ModeRet_Chn,Key.KeyType.ModeRet_Eng,Key.KeyType.Mode2SmartEN,Key.KeyType.Mode2CommonEN:
                return true
            case Key.KeyType.Return:
                return true
            default:
                return false
            }
        }
    }
    
    var type: KeyType
    var widthRatio: CGFloat
    var uppercaseKeyCap: String?
    var lowercaseKeyCap: String?
    var uppercaseOutput: String?
    var lowercaseOutput: String?
    var keyCode: NSString?
    var showPop: Bool
    
    var hasOutput: Bool
    {
        get
        {
            return (self.uppercaseOutput != nil) || (self.lowercaseOutput != nil) || (self.type == .Separate)
        }
    }
    
    // TODO: this is kind of a hack
    var hashValue: Int
    
    init(_ type: KeyType)
    {
        self.type = type
        self.hashValue = counter
        self.widthRatio = 0.0
        self.showPop = true
        counter += 1
    }
    
    convenience init(_ key: Key)
    {
        self.init(key.type)
        
        self.uppercaseKeyCap = key.uppercaseKeyCap
        self.lowercaseKeyCap = key.lowercaseKeyCap
        self.uppercaseOutput = key.uppercaseOutput
        self.lowercaseOutput = key.lowercaseOutput
    }
    
    deinit
    {
        self.uppercaseKeyCap = nil
        self.uppercaseOutput = nil
        self.lowercaseKeyCap = nil
        self.lowercaseOutput = nil
        self.keyCode = nil
    }
    
    func specialButton() -> Bool
    {
        return (self.type.__specialButton() || self.keyCode == nil) && self.type != .Space
    }
    
    func setLetter(_ code: String, letter: String)
    {
        self.keyCode = code.lowercased() as NSString
        self.lowercaseOutput = letter.lowercased()
        self.uppercaseOutput = letter.uppercased()
        self.lowercaseKeyCap = self.lowercaseOutput
        self.uppercaseKeyCap = self.uppercaseOutput
    }

    func setLetter(_ letter: String)
    {
        self.lowercaseOutput = letter.lowercased()
        self.uppercaseOutput = letter.uppercased()
        self.lowercaseKeyCap = self.lowercaseOutput
        self.uppercaseKeyCap = self.uppercaseOutput
        self.keyCode = self.lowercaseOutput as NSString?
    }
    
    func outputForCase(_ uppercase: Bool) -> String
    {
        if uppercase
        {
            if self.uppercaseOutput != nil
            {
                return self.uppercaseOutput!
            }
            else if self.lowercaseOutput != nil
            {
                return self.lowercaseOutput!
            }
            else
            {
                return ""
            }
        }
        else
        {
            if self.lowercaseOutput != nil
            {
                return self.lowercaseOutput!
            }
            else if self.uppercaseOutput != nil
            {
                return self.uppercaseOutput!
            }
            else
            {
                return ""
            }
        }
    }
    
    func keyCapForCase(_ uppercase: Bool) -> String
    {
        if uppercase
        {
            if self.uppercaseKeyCap != nil
            {
                return self.uppercaseKeyCap!
            }
            else if self.lowercaseKeyCap != nil
            {
                return self.lowercaseKeyCap!
            }
            else
            {
                return ""
            }
        }
        else
        {
            if self.lowercaseKeyCap != nil
            {
                return self.lowercaseKeyCap!
            }
            else if self.uppercaseKeyCap != nil
            {
                return self.uppercaseKeyCap!
            }
            else
            {
                return ""
            }
        }
    }
}

func ==(lhs: Key, rhs: Key) -> Bool
{
    return lhs.hashValue == rhs.hashValue
}

private func MakeKey(_ type: Key.KeyType, letter: String, code: String) -> Key
{
    let keyModel = Key(type)
    keyModel.setLetter(code, letter: letter)
    return keyModel
}

private func GenSpace(_ label: String) -> Key
{
    let keyModelSpace = Key(.Space)
    keyModelSpace.uppercaseKeyCap = label//"space"
    keyModelSpace.uppercaseOutput = " "
    keyModelSpace.lowercaseOutput = " "
    
    return keyModelSpace
}

func defaultKeyboard_xfm() -> Keyboard
{
    let defaultKeyboard = Keyboard()

    let keyModel123_CN = Key(.Mode2123_CN)
        keyModel123_CN.uppercaseKeyCap = ".!12"

    let keyModel_T9123 = Key(.Mode2T9_123)
        keyModel_T9123.uppercaseKeyCap = "123"
    
    let keyModel_PopupSymb = Key(.Mode2PopupSymb)
        keyModel_PopupSymb.uppercaseKeyCap = Lang("符")

    let keyModel_PopupSymb2 = Key(.Mode2PopupSymb)
        keyModel_PopupSymb2.uppercaseKeyCap = Lang("更多")
    
    let keyModel123_EN = Key(.Mode2123_EN)
        keyModel123_EN.uppercaseKeyCap = ".!12"

    let keyModel2Sym_CN = Key(.Mode2Sym_CN)
        keyModel2Sym_CN.uppercaseKeyCap = "#+="

    let keyModel2Sym_EN = Key(.Mode2Sym_EN)
        keyModel2Sym_EN.uppercaseKeyCap = "#+="
    
    let keyModel2Eng = Key(.Mode2Eng)
        keyModel2Eng.uppercaseKeyCap = "\(Lang("中文"))`ABC"

    let keyModel2Chn = Key(.Mode2Chn)
        keyModel2Chn.uppercaseKeyCap = "ABC`\(Lang("中文"))"
    
    let keyModelRetChn = Key(.ModeRet_Chn)
        keyModelRetChn.uppercaseKeyCap = Lang("返回")
    
    let keyModelRetEng = Key(.ModeRet_Eng)
        keyModelRetEng.uppercaseKeyCap = Lang("返回")
    
    let keyModelRetAuto = Key(.ModeRet_Auto)
    keyModelRetAuto.uppercaseKeyCap = Lang("返回")
    
    let keyModelNext = Key(.KeyboardChange)

    let keyModelReturn = Key(.Return)
        keyModelReturn.uppercaseKeyCap = "return"
        keyModelReturn.uppercaseOutput = "\n"
        keyModelReturn.lowercaseOutput = "\n"

    let keySeparate = Key(.Separate)
        keySeparate.uppercaseKeyCap = Lang("分隔")
    let keyModelBack = Key(.Backspace)
    let keyShift = Key(.Shift)
    
    let keyBd2 = MakeKey(.Character, letter: "，", code: "")
    
    let key2Smart = Key(.Mode2SmartEN)
    let key2Common = Key(.Mode2CommonEN)

    let keyNull = Key(.Hidden)

    
    // ------------------------------------------------------------------------
    // Chn 智能拼音 26
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_Chn
        
        //  第一行 ˋˇˊ
        for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] // `ˋ
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 0, width: 0.1, page: myPage)
        }
        // 第二行
        for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, width: 0.1, page: myPage)
        }
        // 第三行
        defaultKeyboard.addKey(Key(keyBd2), row: 2, width: 0.15, page: myPage)
        for key in ["Z", "X", "C", "V", "B", "N", "M"] // ˇ ˊ
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 2, width: 0.10, page: myPage)
        }
        defaultKeyboard.addKey(Key(keyModelBack), row: 2, width: 0.15, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey(Key(keyModel_PopupSymb), row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey(Key(keyModelNext),       row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey(Key(keyModel_T9123),     row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey(GenSpace(Lang("鼎氏拼音")),     row: 3, width: 0.28, page: myPage)
        defaultKeyboard.addKey(Key(keyModel2Eng),       row: 3, width: 0.16, page: myPage)
        defaultKeyboard.addKey(Key(keyModelReturn),     row: 3, width: 0.2, page: myPage)
    }

    // ------------------------------------------------------------------------
    //static let M_HW:             // HW
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_HW
        // 第一行
        defaultKeyboard.addKey9(Key(keyNull), row: 0, width: 0.88, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelBack), row: 0, width: 0.12, page: myPage)
        
        // 第二行
        defaultKeyboard.addKey9(Key(keyNull), row: 1, width: 0.88, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "，", code: ""), row: 1, width: 0.12, page: myPage)
        
        // 第三行
        defaultKeyboard.addKey9(Key(keyNull), row: 2, width: 0.88, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "。", code: ""), row: 2, width: 0.12, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey9(Key(keyNull), row: 3, width: 0.88, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "？", code: ""), row: 3, width: 0.12, page: myPage)
        
        // 第五行
        defaultKeyboard.addKey9(Key(keyModel_PopupSymb), row: 4, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelNext),       row: 4, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel_T9123),     row: 4, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(GenSpace(Lang("手写")),        row: 4, width: 0.28, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel2Eng),       row: 4, width: 0.16, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelReturn),     row: 4, width: 0.2, page: myPage)
    }
    
    // ------------------------------------------------------------------------
    //static let M_SK9: Int  = 6             // 笔画9
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_SK9
        //  第一行
        defaultKeyboard.addKey9(Key(keyNull),                                              row: 0, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: Lang("通配")/*"通配`阝"*/, code: "7"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "H"/*"一`扌"*/,     code: "1"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "S"/*"丨`氵"*/,     code: "2"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelBack),                                         row: 0, width: 0.2, page: myPage)
        
        // 第二行
        defaultKeyboard.addKey9(Key(keyNull),                                              row: 1, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: Lang("组词")/*"组词`忄"*/, code: "8"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "P"/*"丿`纟"*/, code: "3"),     row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "N"/*"乀`宀"*/, code: "5"),     row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "，", code: ""),                row: 1, width: 0.2, page: myPage)
        
        // 第三行
        defaultKeyboard.addKey9(Key(keyNull),                                           row: 2, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "！",    code: ""),         row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "D"/*"丶`钅"*/, code: "4"),  row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "Z"/*"フ`木"*/, code: "6"),  row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "。"/*"；`犭"*/, code: "9"), row: 2, width: 0.2, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey9(Key(keyModel_PopupSymb), row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelNext),       row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel_T9123),     row: 3, width: 0.12, page: myPage)
        defaultKeyboard.addKey9(GenSpace(Lang("鼎氏笔画")),     row: 3, width: 0.28, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel2Eng),       row: 3, width: 0.16, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelReturn),     row: 3, width: 0.2, page: myPage)
    }

    // ------------------------------------------------------------------------
    //static let M_Abc9             // Abc 9
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_Abc9
        //  第一行
        defaultKeyboard.addKey9(Key(keyNull), row: 0, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "@`1",   code: "1"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "ABC`2", code: "2"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "DEF`3", code: "3"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelBack), row: 0, width: 0.2, page: myPage)

        // 第二行
        defaultKeyboard.addKey9(Key(keyNull), row: 1, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "GHI`4", code: "4"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "JKL`5", code: "5"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "MNO`6", code: "6"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "0", code: "0"), row: 1, width: 0.2, page: myPage)

        // 第三行
        defaultKeyboard.addKey9(Key(keyNull), row: 2, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "PQRS`7", code: "7"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "TUV`8",  code: "8"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "WXYZ`9", code: "9"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyShift), row: 2, width: 0.2, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey9(Key(keyModel123_EN), row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelNext),   row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(Key(key2Smart),       row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey9(GenSpace(Lang("字母")),     row: 3, width: 0.30, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel2Chn),   row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelReturn), row: 3, width: 0.2, page: myPage)
    }

    // ------------------------------------------------------------------------
    // Abc 26
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_Abc
        //  第一行
        for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 0, width: 0.1, page: myPage)
        }
        // 第二行
        for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, width: 0.1, page: myPage)
        }
        // 第三行
        defaultKeyboard.addKey(Key(keyShift), row: 2, width: 0.15, page: myPage)
        for key in ["Z", "X", "C", "V", "B", "N", "M"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 2, width: 0.1, page: myPage)
        }
        defaultKeyboard.addKey(Key(keyModelBack), row: 2, width: 0.15, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey(Key(keyModel123_EN), row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey(Key(keyModelNext),   row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(Key(key2Smart),      row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(GenSpace(Lang("字母")),     row: 3, width: 0.30, page: myPage)
        defaultKeyboard.addKey(Key(keyModel2Chn),   row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey(Key(keyModelReturn), row: 3, width: 0.2, page: myPage)
    }

    // ------------------------------------------------------------------------
    //static let M_EN9             // Eng 9
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_En9
        //  第一行
        defaultKeyboard.addKey9(Key(keyNull), row: 0, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "@`1",   code: "1"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "ABC`2", code: "2"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "DEF`3", code: "3"), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelBack), row: 0, width: 0.2, page: myPage)
        // 第二行
        defaultKeyboard.addKey9(Key(keyNull), row: 1, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "GHI`4", code: "4"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "JKL`5", code: "5"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "MNO`6", code: "6"), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "0", code: "0"), row: 1, width: 0.2, page: myPage)
        
        // 第三行
        defaultKeyboard.addKey9(Key(keyNull), row: 2, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "PQRS`7", code: "7"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "TUV`8",  code: "8"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "WXYZ`9", code: "9"), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyShift), row: 2, width: 0.2, page: myPage)

        // 第四行
        defaultKeyboard.addKey9(Key(keyModel123_EN), row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelNext),   row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(Key(key2Common),      row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey9(GenSpace(Lang("单词")),    row: 3, width: 0.30, page: myPage)
        defaultKeyboard.addKey9(Key(keyModel2Chn),   row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelReturn), row: 3, width: 0.2, page: myPage)
    }
    
    // ------------------------------------------------------------------------
    // Eng 26
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_En26
        //  第一行
        for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 0, width: 0.1, page: myPage)
        }
        // 第二行
        for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, width: 0.1, page: myPage)
        }
        // 第三行
        defaultKeyboard.addKey(Key(keyShift), row: 2, width: 0.15, page: myPage)
        for key in ["Z", "X", "C", "V", "B", "N", "M"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 2, width: 0.1, page: myPage)
        }
        defaultKeyboard.addKey(Key(keyModelBack), row: 2, width: 0.15, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey(Key(keyModel123_EN), row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey(Key(keyModelNext),   row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(Key(key2Common),     row: 3, width: 0.10, page: myPage)
        defaultKeyboard.addKey(GenSpace(Lang("单词")),    row: 3, width: 0.30, page: myPage)
        defaultKeyboard.addKey(Key(keyModel2Chn),   row: 3, width: 0.15, page: myPage)
        defaultKeyboard.addKey(Key(keyModelReturn), row: 3, width: 0.2, page: myPage)
    }

    // ------------------------------------------------------------------------
    // 123 EN
    // ------------------------------------------------------------------------
    if true
    {
        for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 0, width: 0.1, page: KbPage.M_123_EN)
        }
        
        for key in ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, width: 0.1, page: KbPage.M_123_EN)
        }
        // 三行
        defaultKeyboard.addKey(Key(keyModel2Sym_EN), row: 2, width: 0.15, page: KbPage.M_123_EN)
        for key in [".", ",", "?", "!", "'"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 2, width: 0.14, page: KbPage.M_123_EN)
        }
        defaultKeyboard.addKey(Key(keyModelBack),   row: 2, width: 0.15, page: KbPage.M_123_EN)
        
        // 四行
        defaultKeyboard.addKey(Key(keyModelRetEng),         row: 3, width: 0.15, page: KbPage.M_123_EN)
        defaultKeyboard.addKey(Key(keyModel_PopupSymb2),    row: 3, width: 0.15, page: KbPage.M_123_EN)
        defaultKeyboard.addKey(GenSpace("space"),           row: 3, width: 0.4, page: KbPage.M_123_EN)
        defaultKeyboard.addKey(Key(keyModelReturn),         row: 3, width: 0.3, page: KbPage.M_123_EN)
    }
    
    // ------------------------------------------------------------------------
    // Symb EN
    // ------------------------------------------------------------------------
    if true
    {
        for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 0, width: 0.1, page: KbPage.M_Sym_EN)
        }
    
        for key in ["_", "\\", "|", "~", "<", ">", "€", "£", "Y", "•"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 1, width: 0.1, page: KbPage.M_Sym_EN)
        }
        // 三行
        defaultKeyboard.addKey(Key(keyModel123_EN), row: 2, width: 0.15, page: KbPage.M_Sym_EN)
        for key in [".", ",", "?", "!", "'"]
        {
            let keyModel = Key(.Character)
            keyModel.setLetter(key)
            defaultKeyboard.addKey(keyModel, row: 2, width: 0.14, page: KbPage.M_Sym_EN)
        }
        defaultKeyboard.addKey(Key(keyModelBack),   row: 2, width: 0.15, page: KbPage.M_Sym_EN)
        // 四行
        defaultKeyboard.addKey(Key(keyModelRetEng),        row: 3, width: 0.15, page: KbPage.M_Sym_EN)
        defaultKeyboard.addKey(Key(keyModel_PopupSymb2),   row: 3, width: 0.15, page: KbPage.M_Sym_EN)
        defaultKeyboard.addKey(GenSpace("space"),          row: 3, width: 0.4, page: KbPage.M_Sym_EN)
        defaultKeyboard.addKey(Key(keyModelReturn),        row: 3, width: 0.3, page: KbPage.M_Sym_EN)
    }

    // ------------------------------------------------------------------------
    //static let M_123
    // ------------------------------------------------------------------------
    if true
    {
        let myPage: Int = KbPage.M_123
        //  第一行
        defaultKeyboard.addKey9(Key(keyNull),                               row: 0, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "1", code: ""), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "2", code: ""), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "3", code: ""), row: 0, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelBack),                          row: 0, width: 0.2, page: myPage)
        
        // 第二行
        defaultKeyboard.addKey9(Key(keyNull),                               row: 1, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "4", code: ""), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "5", code: ""), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "6", code: ""), row: 1, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: ".", code: ""), row: 1, width: 0.2, page: myPage)
        
        // 第三行
        defaultKeyboard.addKey9(Key(keyNull),                               row: 2, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "7", code: ""), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "8", code: ""), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "9", code: ""), row: 2, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "%", code: ""), row: 2, width: 0.2, page: myPage)
        
        // 第四行
        defaultKeyboard.addKey(Key(keyModel_PopupSymb),                     row: 3, width: 0.152, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelRetAuto),                       row: 3, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(MakeKey(.Character, letter: "0", code: ""), row: 3, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(GenSpace(Lang("空格")),                            row: 3, width: 0.216, page: myPage)
        defaultKeyboard.addKey9(Key(keyModelReturn),                        row: 3, width: 0.2, page: myPage)
    }
    
    return defaultKeyboard
}
