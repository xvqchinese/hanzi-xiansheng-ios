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

// this banner sits in the empty space on top of the keyboard
class MyCandView: UIButton {
}


class PhrsView: UIView
{
    var pageDaily: UIButton = UIButton()
    var pageHoliday: UIButton = UIButton()
    var close: UIButton = UIButton()
    var list: MyScrollView = MyScrollView()
    var cands: [MyCandView]!
    
    var handler: AnyObject!
    var backColor: UIColor!
    
    var hint: UILabel?
    var kind: String = ""
    
    init(handler: AnyObject)
    {
        super.init(frame: CGRect.zero)
        
        self.cands = []
        self.backColor = UIColor.gray.withAlphaComponent(0.05)
        
        // page
        self.pageDaily.setTitle(Lang("日常短语"), for: .normal)
        self.pageDaily.setTitleColor(UIColor.black, for: .normal)
        self.pageDaily.setTitleColor(UIColor.white, for: .highlighted)
        self.pageDaily.setBackgroundImage(Globals.images["av"], for: .highlighted)
        self.pageDaily.backgroundColor = UIColor.gray.withAlphaComponent(0.55)
        self.pageDaily.sizeToFit()
        self.pageDaily.addTarget(self, action: Selector("pageChange:"), for: .touchUpInside)
        
        self.pageHoliday.setTitle(Lang("节日祝福"), for: .normal)
        self.pageHoliday.setTitleColor(UIColor.black, for: .normal)
        self.pageHoliday.setTitleColor(UIColor.white, for: .highlighted)
        self.pageHoliday.setBackgroundImage(Globals.images["av"], for: .highlighted)
        self.pageHoliday.backgroundColor = UIColor.gray.withAlphaComponent(0.55)
        self.pageHoliday.sizeToFit()
        self.pageHoliday.addTarget(self, action: Selector("pageChange:"), for: .touchUpInside)
        
        // 设置
        self.close.setTitle(Lang("  返回  "), for: .normal)
        self.close.setTitleColor(UIColor.black, for: .normal)
        self.close.setTitleColor(UIColor.white, for: .highlighted)
        self.close.backgroundColor = UIColor.gray.withAlphaComponent(0.55)
        self.close.setBackgroundImage(Globals.images["av"], for: .highlighted)
        self.close.sizeToFit()
        self.close.addTarget(self.superview?.superclass, action: Selector("doPhrase"), for: .touchUpInside)
        
        self.setupRefresh()
        
        self.addSubview(self.pageDaily)
        self.addSubview(self.pageHoliday)
        self.addSubview(self.close)
        self.addSubview(self.list)

        self.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.layer.zPosition = 200
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func End()
    {
        self.Reset()
        self.handler = nil
        self.backColor = nil
        self.cands?.removeAll(keepingCapacity: false)
        self.cands = nil
        self.hint?.removeFromSuperview()
        self.hint = nil
    }
    
    deinit
    {
        MyLog("PhrsView --->> deinit")
        
        self.End()
    }
    
    func show()
    {
        self.pageChange(self.pageDaily)
        self.isHidden = false
    }
    
    func hide()
    {
        self.Reset()
        self.isHidden = true
    }

    func showing() -> Bool
    {
        return (self.isHidden == false)
    }
    
    @objc func pageChange(_ sender: UIButton)
    {
        self.Reset()
        if sender == self.pageDaily
        {
            self.kind = String("daily")
            self.prv_Load(self.kind)
            self.pageHoliday.isHighlighted = false
            self.pageHoliday.setBackgroundImage(nil, for: .normal)
            self.pageHoliday.setTitleColor(UIColor.black, for: .normal)
        }
        else
        {
            self.kind = String("holiday")
            self.prv_Load(self.kind)
            self.pageDaily.isHighlighted = false
            self.pageDaily.setBackgroundImage(nil, for: .normal)
            self.pageDaily.setTitleColor(UIColor.black, for: .normal)
        }
        
        sender.setBackgroundImage(Globals.images["av"], for: .normal)
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.isHighlighted = true
        self.setNeedsLayout()
    }
    
    private func prv_Load(_ file: String)
    {
        let fileURL = fileUrlFromGroup("\(file).txt")
        if (loadStringFileFromGroup("\(file).txt") == nil)
        {
            // 没有，先复制到共享内存
            let mb = Bundle.main
            let orgPath = (mb.resourcePath! as NSString).appendingPathComponent("\(file).txt")
            let orgTxt = try? String(contentsOfFile: orgPath, encoding: String.Encoding.utf8)
            do {
                try orgTxt?.write(to: fileURL as URL, atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            }
        }
        
        var txtData: Data? = try? Data(contentsOf: fileURL as URL)
        if txtData != nil
        {
            let content: NSString = String(data: txtData!, encoding: String.Encoding.utf8)! as NSString
            txtData = nil
            
            let ary = content.components(separatedBy: "#`#")
            for item in ary
            {
                if (item as NSString).length > 0
                {
                    self.cands.append(self.createItem(item as NSString as String, idx: 0))
                }
            }
        }
        else
        {
            if !Globals.accessOpen && self.hint == nil
            {
                self.hint = UILabel()
                self.hint!.text = Lang("此功能需要“完全访问“权限，请进入设置开启！")
                self.hint?.textColor = UIColor.gray
                self.hint?.font = UIFont.systemFont(ofSize: 14)
                self.hint?.sizeToFit()
                self.addSubview(self.hint!)
            }
        }
    }

    private func createItem(_ str: String, idx: Int) -> MyCandView
    {
        let tempBt : MyCandView = MyCandView()
        
        /*
        tempBt.text = str
        tempBt.sizeToFit()
        tempBt.textAlignment = .left
        tempBt.numberOfLines = 0
        tempBt.backgroundColor = self.backColor*/

        tempBt.tag = idx
        tempBt.setTitle(str, for: .normal)
        tempBt.setTitleColor(UIColor.black, for: .normal)
        tempBt.setTitleColor(UIColor.white, for: .highlighted)
        tempBt.setBackgroundImage(Globals.images["av"], for: .highlighted)
        tempBt.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tempBt.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        tempBt.addTarget(self.handler, action: Selector("doSelectPhr:"), for: .touchUpInside)
        tempBt.sizeToFit()
        tempBt.titleLabel?.numberOfLines = 0
        tempBt.backgroundColor = self.backColor
        
        self.list.addSubview(tempBt)
        return tempBt
    }
    
    private func setupRefresh()
    {
        self.list.addHeaderWithCallback({
            
            if Globals.accessOpen
            {
                let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/phrases.php?kind=\(self.kind)")
                let data: Data! = try? Data(contentsOf: url!)
                //var str:NSString? = String(contentsOf: url, encoding: String.Encoding.utf8, error: nil)
                if data != nil
                {
                    let fileURL = fileUrlFromGroup("\(self.kind).txt")
                    try? data?.write(to: fileURL as URL, options: [])
                    self.Reset()
                    self.prv_Load(self.kind)
                    self.setNeedsLayout()
                }
            }
            self.list.headerEndRefreshing()

        })
    }
    
    private func Reset()
    {
        if self.cands != nil
        {
            for cand in self.cands
            {
                cand.removeFromSuperview()
            }
            self.cands.removeAll(keepingCapacity: true)
            self.list.contentOffset = CGPoint.zero
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let padding: CGFloat = 2
        
        self.close.frame.origin.x = padding
        self.close.frame.origin.y = self.frame.height - self.pageDaily.frame.height - padding
        
        let w = (self.frame.width - self.close.frame.width - padding * 2) / 2

        self.pageDaily.frame.origin.x = self.close.frame.origin.x + self.close.frame.width + 1
        self.pageDaily.frame.origin.y = self.frame.height - self.pageDaily.frame.height - padding
        self.pageDaily.frame.size.width = w
        
        self.pageHoliday.frame.origin.x = self.pageDaily.frame.origin.x + self.pageDaily.frame.width + 1
        self.pageHoliday.frame.origin.y = self.frame.height - self.pageDaily.frame.height - padding
        self.pageHoliday.frame.size.width = w - padding
        
        self.list.frame = CGRect(x: padding, y: padding, width: self.frame.width - padding*2, height: self.frame.height - self.close.frame.height - padding)
        
        self.hint?.center = self.center

        let minHeight: CGFloat = self.list.frame.height / 6
        var contentSize : CGFloat = 0
        if self.cands != nil && self.cands.count > 0
        {
            let gap: CGFloat = self.cands[0].titleLabel!.font.lineHeight
            for cand in self.cands
            {
                cand.frame.size.width = self.list.frame.width
                cand.titleLabel!.sizeToFit()
                cand.frame.size.height = cand.titleLabel!.frame.height + gap
            }
            
            var originY : CGFloat = 0
            for cand in self.cands
            {
                if cand.frame.height < minHeight
                {
                    cand.frame.size.height = minHeight
                }
                
                cand.frame = CGRect(x: 0, y: originY, width: self.list.frame.width, height: cand.frame.height)
                contentSize += cand.frame.height + 1
                originY     += cand.frame.height + 1
            }
        }
        self.list.contentSize = CGSize(width: 0, height: max(contentSize, self.list.frame.height+1))
    }
}
