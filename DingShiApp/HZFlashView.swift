//
//  HZFlash.swift
//  DWKeyboard
//
//  Created by Aliang on 16/7/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class HZFlashView: UIView
{
    var close: UIButton!
    var imageView: UIImageView!
    //var skSequence:[String]!
    var nextTimer: Timer?
    var currentSKAry:[String]?
    var currentSKIndex: Int = 0;
    var currentWord: String!
    var dbgLabel: UILabel!
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let r = UIScreen.main.bounds
        self.frame.origin.x = r.origin.x
        self.frame.origin.y = r.origin.y
        self.frame.size.width = r.width
        self.frame.size.height = r.height
        self.backgroundColor = UIColor.black.withAlphaComponent(0.93)

        // 照安卓：正方形取屏幕短边的 70%
        let side = min(r.size.width, r.size.height) * 0.70
        self.imageView = UIImageView(frame: CGRect(x: (r.size.width - side)/2, y: (r.size.height - side)/2 + 10, width: side, height: side))
        self.imageView.isUserInteractionEnabled = false
        self.imageView.backgroundColor = UIColor.clear//greenColor().withAlphaComponent(0.5)
        self.addSubview(self.imageView)
        
        self.close = UIButton()
        self.close.setTitle(Lang("     返 回     "), for: .normal)
        self.close.setTitleColor(UIColor.black, for: .normal)
        self.close.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.close.addTarget(self, action: Selector("onClose"), for: UIControl.Event.touchUpInside)
        self.close.frame = CGRect(x: 24, y: self.frame.height - 96, width: self.frame.width - 48, height: 48)
        self.close.backgroundColor = UIColor(white: 0.92, alpha: 1)
        self.close.layer.cornerRadius = 6
        self.addSubview(self.close)

        let soundSw = UISwitch()
        let cue = UILabel()
        cue.text = Lang("有声")
        cue.textColor = UIColor.white
        cue.font = UIFont.systemFont(ofSize: 16)
        cue.sizeToFit()
        soundSw.frame.origin.x = self.frame.width - soundSw.frame.width - 16
        soundSw.frame.origin.y = self.frame.origin.y + 8
        cue.frame.origin.x = soundSw.frame.origin.x - cue.frame.width - 6
        cue.center.y = soundSw.center.y
        soundSw.isOn = UserDefaults(suiteName: "group.DWIME_DS")?.object(forKey: "skSound") == nil ? true : (UserDefaults(suiteName: "group.DWIME_DS")?.bool(forKey: "skSound") ?? true)
        soundSw.addTarget(self, action: Selector("onSoundSwitch:"), for: .valueChanged)
        self.addSubview(cue)
        self.addSubview(soundSw)

        let title = UILabel()
        title.text = Lang("笔顺动画")
        title.textColor = UIColor.white
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.sizeToFit()
        title.frame.origin = CGPoint(x: 24, y: 56)
        self.addSubview(title)

        dbgLabel = UILabel()
        dbgLabel.font = UIFont.systemFont(ofSize: 11)
        dbgLabel.textColor = UIColor.red
        dbgLabel.numberOfLines = 2
        dbgLabel.frame = CGRect(x: 24, y: 92, width: r.size.width - 48, height: 30)
        dbgLabel.text = "调试：等待笔画"
        self.addSubview(dbgLabel)
        
        //self.skSequence = getStringListByTxt("sk")
        //MyLog("\(self.skSequence)")
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setWord(word:NSString)
    {
        var index:Int32 = 0;
        var sk:NSString = "";
        
        while(true)
        {
            let item: NSString? = ocUtils.getHZFlashSkary(index) as NSString?
            index += 1
            if item == nil
            {
                break
            }
            if word.character(at: 0) == item!.character(at: 0)
            {
                sk = item!.substring(from: 1) as NSString
                break;
            }
        }

        if sk != ""
        {
            self.currentWord = word as String
            self.currentSKAry = sk.components(separatedBy: ",")
            self.currentSKIndex = 0;
            self.showNext()
            self.nextTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("showNext"), userInfo: nil, repeats: true)
        }
        else
        {
            self.currentSKAry = nil
            self.nextTimer?.invalidate();
            self.nextTimer = nil
        }
    }
    
    @objc func showNext()
    {
        guard let ary = self.currentSKAry, !ary.isEmpty else
        {
            self.nextTimer?.invalidate(); self.nextTimer = nil
            return
        }
        if (self.currentSKIndex >= ary.count) { self.currentSKIndex = 0 }
        ocUtils.drawWordPath(self.currentWord, Lang("楷体_GB2312_v2"), self.imageView, ary, self.currentSKIndex)
        // 安卓行为：笔画一到就发声，不需要任何开关
        let sk = ary[self.currentSKIndex].uppercased()
        // 先按“鼎氏笔画字母”取本笔读音（最准：来源服务器 dict_sk 全量表）
        var tune: String? = nil
        if let letters = ocUtils.skLetters(for: self.currentWord ?? ""),
           letters.count == ary.count,
           self.currentSKIndex < letters.count
        {
            let l = String(Array(letters)[self.currentSKIndex]).lowercased()
            let m: [String: String] = ["h": "hengx", "s": "shuq", "p": "piev", "d": "dianv", "n": "naq", "z": "zhex"]
            tune = m[l]
        }
        // 兜底：按笔画编号（1横 2竖 3撇 4点 5捺 6折）
        if tune == nil
        {
            let m2: [String: String] = ["1": "hengx", "2": "shuq", "3": "piev", "4": "dianv", "5": "naq", "6": "zhex", "H": "hengx", "S": "shuq", "P": "piev", "D": "dianv", "N": "naq", "Z": "zhex"]
            tune = m2[String(sk.prefix(1))]
        }
        if let py = tune
        {
            let rep = playWavReport(py)
            dbgLabel.text = "\(self.currentWord ?? "") 第\(self.currentSKIndex + 1)笔 \(sk) → \(rep)"
        }
        else
        {
            dbgLabel.text = "第\(self.currentSKIndex + 1)笔 \(sk) 无读音码"
        }
        self.currentSKIndex += 1
        if (self.currentSKIndex >= ary.count) { self.currentSKIndex = 0 }
    }
    
    @objc func onSoundSwitch(_ sender: UISwitch)
    {
        UserDefaults(suiteName: "group.DWIME_DS")?.set(sender.isOn, forKey: "skSound")
    }

    func show()
    {
        let window  = UIApplication.shared.keyWindow;
        window!.addSubview(self)
    }
    
    @objc func onClose()
    {
        self.currentSKAry?.removeAll()
        self.currentSKAry = nil
        self.nextTimer?.invalidate()
        self.nextTimer = nil
        self.removeFromSuperview()
    }
}