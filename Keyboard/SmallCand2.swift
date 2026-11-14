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

class SmallCand2: BannerView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    var compLabel: UILabel = UILabel()
    var moreBt : UIButton = UIButton()
    
    var handler: AnyObject
    var font: UIFont! = nil
    var candCache: [NSString]!

    var hzLabel: UILabel?
    var enLabel: UILabel?
    var delegate: KeyboardCandProtocol?
    
    var longPress: UILongPressGestureRecognizer!
    
    init(frame: CGRect, handler: AnyObject)
    {
        self.candCache = []
        self.handler = handler
        super.init(frame: frame)
        
        self.backgroundColor = KeyboardColor.mCandBColor    // UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.4)
        self.font = UIFont(name: "Arial", size: (frame.height/2.2))
        
        self.layout = UICollectionViewFlowLayout()
        self.layout.minimumInteritemSpacing = 1
        self.layout.minimumLineSpacing = 1
        self.layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        self.layout.scrollDirection = UICollectionView.ScrollDirection.horizontal

        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.backgroundColor = self.backgroundColor
        self.addSubview(self.collectionView)
        
        self.compLabel.font = self.compLabel.font.withSize(frame.height/3.5)
        self.compLabel.textAlignment = .left
        self.compLabel.isUserInteractionEnabled = false
        self.compLabel.backgroundColor = self.backgroundColor
        self.compLabel.textColor = KeyboardColor.mCandTxtColor
        self.addSubview(self.compLabel)
        
        self.moreBt.setImage(Globals.images["mr"], for: .normal)
        self.moreBt.setImage(Globals.images["mrp"], for: .selected)
        self.moreBt.setImage(Globals.images["mrp"], for: .highlighted)
        self.moreBt.sizeToFit()
        self.moreBt.addTarget(self.handler, action: Selector("doBigCand"), for: .touchUpInside)
        self.moreBt.backgroundColor = KeyboardColor.mCandDownBColor // UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.9)
        self.addSubview(self.moreBt)
        
        self.longPress = UILongPressGestureRecognizer(target: self, action: Selector("onLongPress:"))
        self.longPress.minimumPressDuration = 1.0
        self.collectionView.addGestureRecognizer(self.longPress)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        self.End()
    }
    
    func createCandLabel() -> UILabel
    {
        let statusLabel = UILabel()
        statusLabel.font = self.font;//UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = KeyboardColor.mCandTxtColor // UIColor.black
        statusLabel.backgroundColor = UIColor.clear
        statusLabel.textAlignment = .center
        return statusLabel
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        MyLog("----->>> SmallCand2 --->> numberOfItemsInSection")
        
        return self.candCache.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : UICollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell?
        
        var label : UILabel? = cell!.contentView.viewWithTag(1000001) as! UILabel?
        if label == nil
        {
            label = createCandLabel()
            cell!.backgroundColor = UIColor.clear
            cell!.contentView.addSubview(label!)
            label!.tag = 1000001
        }
        // 每次统一字号，避免同一排里有大有小
        label!.font = self.font
        label!.textColor = KeyboardColor.mCandTxtColor
        label!.textAlignment = .left
        label!.adjustsFontSizeToFitWidth = true
        label!.minimumScaleFactor = 0.5
        label!.lineBreakMode = NSLineBreakMode.byClipping
        label!.text = self.candCache[indexPath.row] as String
        label!.sizeToFit()
        label!.frame.origin.y = (cell!.frame.height - label!.frame.height) / 2
        label!.frame.size.width = cell!.frame.width
        
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        collectionView.cellForItem(at:indexPath)?.backgroundColor = KeyboardColor.mCellColor_hi
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        collectionView.cellForItem(at:indexPath)?.backgroundColor = UIColor.clear
    }
    
    // 定义每个UICollectionView 的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // 按词的长度给格子宽度，长词（四个字）也能完整显示，左右可滑动翻页
        let txt = (self.candCache[indexPath.row] as String)
        let f = self.font ?? UIFont.systemFont(ofSize: 18)
        let need = (txt as NSString).size(withAttributes: [NSAttributedString.Key.font: f]).width + 18
        let usable = collectionView.frame.width
        let minW = max(44, usable / 6)
        return CGSize(width: min(max(need, minW), usable - 30), height: collectionView.frame.height)
    }
    // 返回这个UICollectionView是否可以被选择
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.delegate?.didSelectCand(indexPath.row, str: self.candCache[indexPath.row] as String)
    }

    override func layoutSubviews()
    {
        MyLog("------->> SmallCand2 ->> layoutSubviews")
        
        super.layoutSubviews()
        
        self.moreBt.frame.size.height = self.frame.height
        self.moreBt.frame.size.width = self.frame.width / 11
        self.moreBt.center.y = self.center.y
        self.moreBt.frame.origin.x = self.frame.width - self.moreBt.frame.width
        
        // 候选字号按格宽与条高取小，保证一屏 6 个放得下
        let cellW = (self.frame.width - self.moreBt.frame.width) / 6
        let fsize = min(self.frame.height * 0.52, cellW * 0.92)
        self.font = UIFont(name: "Arial", size: max(10, fsize))
        self.collectionView.reloadData()
        self.compLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/3.3)
        
        let compHeight = self.compLabel.isHidden ? 0 : self.compLabel.frame.height
        self.moreBt.frame.size.width = max(28, self.frame.width / 8)
        self.moreBt.frame.origin.x = self.frame.width - self.moreBt.frame.width
        self.collectionView.frame = CGRect(x: 0, y: 0 + compHeight, width: self.frame.width - self.moreBt.frame.width, height: self.frame.height - compHeight)
    }
    
    func show()
    {
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
    
    func updateHwCands(_ str: NSString)
    {
        var i : Int = 0
        self.candCache.removeAll(keepingCapacity: false)
        while(i < str.length)
        {
            let hz = str.substring(with: NSRange(location: i, length: 1))
            i += 1
            self.candCache.append(hz as NSString)
        }
        
        self.collectionView.reloadData()
        self.collectionView.contentOffset = CGPoint.zero
        self.compLabel.isHidden  = true
        self.moreBt.isHidden = true
    }
    
    func updateCands(_ engine: EngineService)
    {
        var i: Int32 = 0
        let count: Int32 = engine.CandCount()
        self.candCache.removeAll(keepingCapacity: false)
        var shownIdx = Set<String>()
        for i in 0..<min(50, count)
        {
            let c = engine.GetCand(i)
            let key = c as String
            if shownIdx.contains(key) { continue }
            shownIdx.insert(key)
            self.candCache.append(c)
        }
        
        self.collectionView.reloadData()
        self.collectionView.contentOffset = CGPoint.zero
        self.moreBt.isHidden = false
    }
    
    func dsPy2StdPy(_ compStrIn: NSString) -> NSString
    {
        var newComp = "";
        var tune = 0;
        
        let pyAry = compStrIn.components(separatedBy: "\'")
        for py in pyAry
        {
            var r1 = (py as NSString).range(of: "aa")
            if r1.location == NSNotFound
            {
                r1 = (py as NSString).range(of: "ee")
            }
            if r1.location == NSNotFound
            {
                r1 = (py as NSString).range(of: "ii")
            }
            if r1.location == NSNotFound
            {
                r1 = (py as NSString).range(of: "oo")
            }
            if r1.location == NSNotFound
            {
                r1 = (py as NSString).range(of: "uu")
            }
            
            if r1.location != NSNotFound
            {
                // 0 声
                tune = 0
                var newPy = py;
                newPy = newPy.replacingOccurrences(of: "aa", with: "a")
                newPy = newPy.replacingOccurrences(of: "ee", with: "e")
                newPy = newPy.replacingOccurrences(of: "ii", with: "i")
                newPy = newPy.replacingOccurrences(of: "oo", with: "o")
                newPy = newPy.replacingOccurrences(of: "uu", with: "u")
                
                // 形成新的 comp
                if newComp.count > 0
                {
                    newComp += "\'";
                }
                newComp += newPy;
            }
            else
            {
                var newPy = py;
                let last = (py as NSString).character(at: py.count - 1)
                if last == 0x71     // q
                {
                    tune = 4;
                    newPy = (py as NSString).substring(to: py.count - 1);  // 去掉最后一个音标
                }
                else if last == 0x76    // v
                {
                    tune = 3;
                    newPy = (py as NSString).substring(to: py.count - 1);  // 去掉最后一个音标
                }
                else if last == 0x78    // x
                {
                    tune = 2;
                    newPy = (py as NSString).substring(to: py.count - 1);  // 去掉最后一个音标
                }
                else
                {
                    tune = 1
                }
                
                // 替换成音标准标
                var r1 = (py as NSString).range(of: "a")
                if r1.location != NSNotFound
                {
                    let tt:NSString = "āáǎà";
                    newPy = newPy.replacingOccurrences(of: "a", with: tt.substring(with: NSRange(location: tune-1, length: 1)))
                }
                else
                {
                    r1 = (py as NSString).range(of: "e")
                    if r1.location != NSNotFound
                    {
                        let tt:NSString = "ēéěè";
                        newPy = newPy.replacingOccurrences(of: "e", with: tt.substring(with: NSRange(location: tune-1, length: 1)))
                    }
                    else
                    {
                        r1 = (py as NSString).range(of: "i")
                        if r1.location != NSNotFound
                        {
                            let tt:NSString = "īíǐì";
                            newPy = newPy.replacingOccurrences(of: "i", with: tt.substring(with: NSRange(location: tune-1, length: 1)))
                        }
                        else
                        {
                            r1 = (py as NSString).range(of: "o")
                            if r1.location != NSNotFound
                            {
                                let tt:NSString = "ōóǒò";
                                newPy = newPy.replacingOccurrences(of: "o", with: tt.substring(with: NSRange(location: tune-1, length: 1)))
                            }
                            else
                            {
                                r1 = (py as NSString).range(of: "u")
                                if r1.location != NSNotFound
                                {
                                    let tt:NSString = "ūúǔù";
                                    newPy = newPy.replacingOccurrences(of: "u", with: tt.substring(with: NSRange(location: tune-1, length: 1)))
                                }
                            }
                        }
                    }
                }
                
                
                // 形成新的 comp
                if newComp.count > 0
                {
                    newComp += "\'";
                }
                newComp += newPy;
            }
        }
        return newComp as NSString;
    }
    
    func updateComp(_ compStr: NSString, page: Int)
    {
        if !IsNeedComp(page)
        {
            if !self.compLabel.isHidden
            {
                self.compLabel.isHidden  = true
                self.setNeedsLayout()
            }
        }
        else
        {
            if self.compLabel.isHidden
            {
                self.compLabel.isHidden  = false
                self.setNeedsLayout()
            }
            var str = NSMutableAttributedString(string: " \(compStr)")
            if page == KbPage.M_Chn
            {
                if Globals.pyStyle == 0
                {
                    // ds style, 声调着颜色
                    var pos = 0
                    let pyAry = compStr.components(separatedBy: "\'")
                    for py in pyAry
                    {
                        var r1 = (py as NSString).range(of: "aa")
                        if r1.location == NSNotFound
                        {
                            r1 = (py as NSString).range(of: "ee")
                        }
                        if r1.location == NSNotFound
                        {
                            r1 = (py as NSString).range(of: "ii")
                        }
                        if r1.location == NSNotFound
                        {
                            r1 = (py as NSString).range(of: "oo")
                        }
                        if r1.location == NSNotFound
                        {
                            r1 = (py as NSString).range(of: "uu")
                        }
                        
                        if r1.location != NSNotFound
                        {
                            str.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: pos + r1.location+2, length: 1))
                        }
                        else if py.count > 1
                        {
                            let last = (py as NSString).character(at: py.count - 1)
                            if last == 0x71 || last == 0x76 || last == 0x78
                            {
                                str.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: pos + py.count, length: 1))
                            }
                        }
                        pos += py.count;
                        pos += 1;// 分隔符
                    }
                }
                else
                {
                    // 转成标准拼音
                    let newComp = self.dsPy2StdPy(compStr)
                    str = NSMutableAttributedString(string: " \(newComp)")
                    
                    // 声母着颜色
                    var pos = 0
                    let pyAry = newComp.components(separatedBy: "\'")
                    let tunes = "aāáǎàeēéěèiīíǐìoōóǒòuūúǔù";
                    for py in pyAry
                    {
                        for tt in tunes
                        {
                            let r1 = (py as NSString).range(of: "\(tt)")
                            if r1.location != NSNotFound
                            {
                                str.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: pos + r1.location+1, length: 1))
                                break
                            }
                        }
                        pos += py.count;
                        pos += 1;// 分隔符
                    }
                }
            }
            self.compLabel.sizeToFit()
            self.compLabel.attributedText = str
            self.compLabel.sizeToFit()
        }
    }
    
    @objc func onLongPress(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        let pointTouch = gestureRecognizer.location(in: self.collectionView)

        if gestureRecognizer.state == UIGestureRecognizer.State.began
        {
            if let indexPath = self.collectionView.indexPathForItem(at: pointTouch)
            {
                let cand = self.candCache[indexPath.row];
                let encoded = escape(cand as String)
                let url: URL? = URL(string: "DWIME.DingShiApp.ext://gotodict/?key=\(encoded)")
                openURL(self, url: url! as NSURL);
            }
        }
    }

    
    func Reset()
    {
        self.candCache.removeAll(keepingCapacity: true)
        self.collectionView.contentOffset = CGPoint.zero
        self.collectionView.reloadData()
        self.compLabel.text = ""
    }
    
    func End()
    {
        self.font = nil
        self.layout = nil
        self.hzLabel = nil
        self.enLabel = nil
        self.delegate = nil
        self.longPress = nil
        
        self.candCache?.removeAll(keepingCapacity: false)
        self.candCache = nil
        
        self.collectionView?.removeFromSuperview()
        self.collectionView = nil
        self.moreBt.removeFromSuperview()
        self.compLabel.removeFromSuperview()
    }
}
