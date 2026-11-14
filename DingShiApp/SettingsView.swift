//
//  Daily.swift
//  MMKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit


class SettingsView: QuickDialogController
{
    var edit: UITextView?
    
    override init(root: QRootElement!)
    {
        super.init(root: root)
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func shouldDelete(_ element: QElement) -> Bool
    {
        MyLog("shouldDeleteElement")
        return true
    }

    override func viewDidLoad()
    {
        self.edit = UITextView(frame: CGRect(x: 1, y: 1, width: self.view.frame.size.width, height: 30))
        self.edit?.layer.zPosition = 100;
        self.view.addSubview(self.edit!)
    }
    
    func onKbHeight(sender: QSelectItemElement)
    {
        let gprefs = getGlobalPrefs()
        
        switch(sender.index)
        {
        case 0: gprefs.set(CGFloat(1.15), forKey: "kbheight")
        case 1: gprefs.set(CGFloat(0.85), forKey: "kbheight")
        case 2: gprefs.set(CGFloat(1.0), forKey: "kbheight")
        default:break
        }
        self.edit?.becomeFirstResponder()
        MyLog("onKbHeight = \(sender.index)")
    }
}

func settingsCreateRoot() -> QRootElement
{
    let gprefs = getGlobalPrefs()
    var selectedIndex = 0;

    let root = QRootElement()
    root!.controllerName = "SettingsView";
    root!.title = Lang("settings_title");
    root!.grouped = true;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 汉字输出
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let cnConv = gprefs.integer(forKey: "cnOutConv")
        let cnConvSection: QRadioSection! = QRadioSection(items: [Lang("不转换"), Lang("繁体"), Lang("英文")], selectedIndexes: [cnConv], title: Lang("中文输出转换"))
        cnConvSection.onSelected =
            {
                gprefs.set(cnConvSection.selected, forKey: "cnOutConv")
        }
        root!.addSection(cnConvSection)
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 英文输出
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let enConv = gprefs.integer(forKey: "enOutConv")
        let enConvSection: QRadioSection! = QRadioSection(items: [Lang("不转换"), Lang("中文")], selectedIndexes: [enConv], title: Lang("英文输出转换"))
        enConvSection.onSelected =
            {
                gprefs.set(enConvSection.selected, forKey: "enOutConv")
        }
        root!.addSection(enConvSection)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 键盘高度
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let kbHeight = gprefs.float(forKey: "kbheight")
        if kbHeight >= 1.10 { selectedIndex = 0 }
        else if kbHeight >= 0.95 { selectedIndex = 1 }
        else { selectedIndex = 2 }
        // kbHeight
        let kbHeightSection: QRadioSection! = QRadioSection(items: [Lang("大"), Lang("中"), Lang("小")], selectedIndexes: [selectedIndex], title: Lang("键盘高度"))
        
        if let large : QSelectItemElement = kbHeightSection.elements[0] as? QSelectItemElement
        {
            large.controllerAction = "onKbHeight:"
        }
        if let medium : QSelectItemElement = kbHeightSection.elements[1] as? QSelectItemElement
        {
            medium.controllerAction = "onKbHeight:"
        }
        if let small : QSelectItemElement = kbHeightSection.elements[2] as? QSelectItemElement
        {
            small.controllerAction = "onKbHeight:"
        }
        root!.addSection(kbHeightSection)
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 语音
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let shared = UserDefaults(suiteName: "group.DWIME_DS")
        let weEl = QBooleanElement(title: Lang("上屏朗读"), boolValue: shared?.bool(forKey: "playWav") ?? true)!
        weEl.onSelected = { UserDefaults(suiteName: "group.DWIME_DS")?.set(weEl.boolValue, forKey: "playWav") }
        let kbEl = QBooleanElement(title: Lang("声音反馈"), boolValue: shared?.bool(forKey: "keySound") ?? true)!
        kbEl.onSelected = { UserDefaults(suiteName: "group.DWIME_DS")?.set(kbEl.boolValue, forKey: "keySound") }
        let vibEl = QBooleanElement(title: Lang("振动反馈"), boolValue: shared?.bool(forKey: "vibrate") ?? false)!
        vibEl.onSelected = { UserDefaults(suiteName: "group.DWIME_DS")?.set(vibEl.boolValue, forKey: "vibrate") }
        let assoEl = QBooleanElement(title: Lang("开启联想"), boolValue: shared?.bool(forKey: "association") ?? true)!
        assoEl.onSelected = { UserDefaults(suiteName: "group.DWIME_DS")?.set(assoEl.boolValue, forKey: "association") }
        let voiceSection = QSection(title: Lang("常规"))!
        voiceSection.addElement(weEl)
        voiceSection.addElement(kbEl)
        voiceSection.addElement(vibEl)
        voiceSection.addElement(assoEl)
        root!.addSection(voiceSection)
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 手写效果
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let hwBrush = gprefs.bool(forKey: "hwBrush")
        if (hwBrush)
        {
            selectedIndex = 1;
        }
        else
        {
            selectedIndex = 0;
        }
        let hwBrushSection: QRadioSection! = QRadioSection(items: [Lang("铅笔"), Lang("毛笔")], selectedIndexes: [selectedIndex], title: Lang("手写笔效果"))
        hwBrushSection.onSelected =
            {
                if hwBrushSection.selected == 0
                {
                    gprefs.set(false, forKey: "hwBrush")
                }
                if hwBrushSection.selected == 1
                {
                    gprefs.set(true, forKey: "hwBrush")
                }
        }
        root!.addSection(hwBrushSection)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 手写 timer
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let segmented: QSection! = QSection(title: Lang("手写识别超时设置"))
        segmented.footer = Lang("当手指抬起开始计时，达到超时即清除手写区，重新开始。")
        
        let oldTime = gprefs.integer(forKey: "hwTimeOut")
        var selectd = 0;
        switch oldTime
        {
        case 800 :selectd = 0; break;
        case 1000:selectd = 1; break;
        case 1500:selectd = 2; break;
        case 2000:selectd = 3; break;
        default: selectd = 0; break;
        }
        
        let segmentedElement: QSegmentedElement! = QSegmentedElement(items: ["0.8\(Lang("秒"))", "1\(Lang("秒"))", "1.5\(Lang("秒"))", "2\(Lang("秒"))"], selected: selectd)
        segmented.addElement(segmentedElement)
        segmentedElement.onSelected =
        {
            if segmentedElement.selected == 0
            {
                gprefs.set(800, forKey: "hwTimeOut")
            }
            else if segmentedElement.selected == 1
            {
                gprefs.set(1000, forKey: "hwTimeOut")
            }
            else if segmentedElement.selected == 2
            {
                gprefs.set(1500, forKey: "hwTimeOut")
            }
            else if segmentedElement.selected == 3
            {
                gprefs.set(2000, forKey: "hwTimeOut")
            }
        }
        root!.addSection(segmented)
    }

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 拼音风格
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (true)
    {
        let segmented: QSection! = QSection(title: Lang("拼音风格"))
        
        let oldStyle = gprefs.integer(forKey: "pyStyle")
        let segmentedElement: QSegmentedElement! = QSegmentedElement(items: ["dingv", "dǐng"], selected: oldStyle)
        segmented.addElement(segmentedElement)
        segmentedElement.onSelected =
        {
                gprefs.set(segmentedElement.selected, forKey: "pyStyle")
        }
        root!.addSection(segmented)
    }
    
    
    return root!
}






