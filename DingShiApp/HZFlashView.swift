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
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        let h = r.height/3*2
        self.imageView = UIImageView(frame: CGRect(x: 10, y: (r.height-h)/2, width: r.size.width - 20, height: h))
        self.imageView.isUserInteractionEnabled = false
        self.imageView.backgroundColor = UIColor.clear//greenColor().withAlphaComponent(0.5)
        self.addSubview(self.imageView)
        
        self.close = UIButton()
        self.close.setTitle(Lang("     关 闭     "), for: .normal)
        self.close.setTitleColor(UIColor.white, for: .normal)
        self.close.addTarget(self, action: Selector("onClose"), for: UIControl.Event.touchUpInside)
        self.close.sizeToFit()
        self.close.frame.origin.x = (self.frame.width - self.close.frame.width) / 2
        self.close.frame.origin.y = self.frame.height - self.close.frame.height * 3
        self.close.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.close.layer.cornerRadius = 5
        self.addSubview(self.close)
        
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
            ocUtils.drawWordPath(word as String, Lang("楷体_GB2312_v2"), self.imageView, self.currentSKAry, -1)
            self.currentSKIndex = -1;
            self.nextTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: Selector("showNext"), userInfo: nil, repeats: true)
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
        if self.currentSKAry != nil
        {
            self.currentSKIndex += 1
            if (self.currentSKIndex >= self.currentSKAry!.count)
            {
                self.currentSKIndex = -1;
            }
            ocUtils.drawWordPath(self.currentWord, Lang("楷体_GB2312_v2"), self.imageView, self.currentSKAry, self.currentSKIndex)
            if (UserDefaults(suiteName: "group.DWIME_DS")?.bool(forKey: "playWav") ?? true) && self.currentSKIndex >= 0 && self.currentSKIndex < self.currentSKAry!.count
            {
                let sk = self.currentSKAry![self.currentSKIndex].uppercased()
                let strokeSound: [String: String] = ["D": "dianv", "H": "hengx", "S": "shuq", "P": "piev", "N": "naq", "Z": "zhex"]
                if let py = strokeSound[String(sk.prefix(1))] { playWav(py) }
            }
        }
        else
        {
            self.nextTimer?.invalidate();
            self.nextTimer = nil
        }
        MyLog("showNext = \(self.currentSKIndex)")
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