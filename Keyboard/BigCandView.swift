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

class CandItem: UIButton
{
    /*
    var title: String
    init(title: String, frame: CGRect)
    {
        self.title = title
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.title.draw(in: self.bounds, withAttributes: nil)
    }**/
}

class BigCandView: UIView
{
    var cands: [CandItem]
    var pageHistory: [Int32]
    var candCache: [NSString]
    
    var handler: AnyObject!
    var candList: MyScrollView!
    var closeBt : UIButton!
    var nextBt : UIButton!
    var prefBt : UIButton!
    var moreBt : CandItem?          // MyScrollView 方式
    var backColor: UIColor!
    var font: UIFont!

    var contentSize: Int = 0        // MyScrollView 方式
    var curCount: Int = 0           // MyScrollView 方式
    var moreShowing: Bool = false   // MyScrollView 方式
    var oldBounds: CGRect?

    init(handler: AnyObject)
    {
        self.cands = []
        self.pageHistory = []
        self.candCache = []

        self.handler = handler
        self.candList = MyScrollView()
        self.closeBt = UIButton()
        self.nextBt = UIButton()
        self.prefBt = UIButton()
        self.font = UIFont(name: "ChalkboardSE", size: 20)
        
        super.init(frame: CGRect.zero)
        
        self.backColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5) //UIColor.yellow
        self.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        
        self.candList.clipsToBounds = true
        self.candList.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        self.setupRefresh()
        self.addSubview(self.candList)
        
        self.closeBt.setTitle("  返 回  ", for: .normal)
        self.closeBt.setTitleColor(UIColor.black, for: .normal)
        self.closeBt.setTitleColor(UIColor.blue, for: .highlighted)
        self.closeBt.sizeToFit()
        self.closeBt.addTarget(self.handler, action: Selector("doCloseBigCand"), for: .touchUpInside)
        self.addSubview(self.closeBt)

        self.nextBt.setTitle("  下一页  ", for: .normal)
        self.nextBt.setTitleColor(UIColor.black, for: .normal)
        self.nextBt.setTitleColor(UIColor.blue, for: .highlighted)
        self.nextBt.setTitleColor(UIColor.gray, for: .disabled)
        self.nextBt.sizeToFit()
        self.nextBt.addTarget(self.handler, action: Selector("doNextPage"), for: .touchUpInside)
        //self.nextBt.backgroundColor = UIColor.white
        //self.nextBt.layer.cornerRadius = 5.0
        self.addSubview(self.nextBt)

        self.prefBt.setTitle("  上一页  ", for: .normal)
        self.prefBt.setTitleColor(UIColor.black, for: .normal)
        self.prefBt.setTitleColor(UIColor.blue, for: .highlighted)
        self.prefBt.setTitleColor(UIColor.gray, for: .disabled)
        self.prefBt.sizeToFit()
        self.prefBt.addTarget(self.handler, action: Selector("doPrefPage"), for: .touchUpInside)
        //self.prefBt.backgroundColor = UIColor.white
        //self.prefBt.layer.cornerRadius = 5.0
        self.addSubview(self.prefBt)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        self.End()
    }
    
    override func layoutSubviews()
    {
        MyLog("----->>> BigCand --->> layoutSubviews")
        super.layoutSubviews()

        if (self.oldBounds == nil || self.oldBounds! != self.bounds)
        {
            self.closeBt.frame.size.height = self.frame.height / 6
            self.closeBt.frame.origin.x = self.frame.width - self.closeBt.frame.width
            self.closeBt.frame.origin.y = self.frame.height - self.closeBt.frame.height
        
            self.prefBt.frame.size.height = self.frame.height / 6
            self.prefBt.frame.origin.x = self.center.x - self.prefBt.frame.width - self.prefBt.bounds.height/2
            self.prefBt.frame.origin.y = self.frame.height - self.prefBt.frame.height

            self.nextBt.frame.size.height = self.frame.height / 6
            self.nextBt.frame.origin.x = self.center.x + self.nextBt.bounds.height/2
            self.nextBt.frame.origin.y = self.frame.height - self.nextBt.frame.height

            self.candList.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - self.closeBt.frame.height)
            
            self.oldBounds = self.bounds
        }

        // 排版候选
        var contentSize : CGFloat = 0
        var originX : CGFloat = 0
        var originY : CGFloat = 0
        var rowObjs: [CandItem] = []
        let rowHeight: CGFloat = (self.frame.height - self.closeBt.frame.height - 4) / 5

        for cand in self.cands
        {
            if cand.superview != self.candList || cand.tag == -1
            {
                break
            }
            cand.frame.size.height = rowHeight
            
            if ((cand.frame.width + originX) > self.candList.frame.width) ||    // 满一行
               (rowObjs.count >= 10)       // 满10个
            {
                // 把剩余的位置平均分配给一行里所有候选
                if true
                {
                    var tempX : CGFloat = 0
                    let leftX = self.candList.frame.width - originX
                    for one in rowObjs
                    {
                        one.frame.origin.x = tempX
                        one.frame.size.width += (leftX / CGFloat(rowObjs.count))
                        tempX += one.frame.width + 1
                    }
                    rowObjs.removeAll(keepingCapacity: true)
                }
                
                // 换行
                originX = 0
                originY += rowHeight + 1
                contentSize += rowHeight + 1
            }
            
            cand.frame.origin.x = originX
            cand.frame.origin.y = originY
            originX += cand.frame.width + 1
            rowObjs.append(cand)
        }
        if rowObjs.count > 0
        {
            // 最后一行重排
            var tempX : CGFloat = 0
            let leftX = self.candList.frame.width - originX
            for one in rowObjs
            {
                one.frame.origin.x = tempX
                one.frame.size.width += (leftX / CGFloat(rowObjs.count))
                tempX += one.frame.width + 1
            }
            rowObjs.removeAll(keepingCapacity: false)
        }

        if (self.moreShowing)
        {
            originY += rowHeight + 1
            contentSize += rowHeight + 1
            self.moreBt?.frame.origin.x = 0
            self.moreBt?.frame.origin.y = originY
            self.moreBt?.frame.size.width = self.candList.frame.width
            self.moreBt?.frame.size.height = rowHeight
        }

        self.candList.contentSize = CGSize.zero//CGSize(width: 0, height: max(contentSize + rowHeight, self.frame.height))
        MyLog("----->>> BigCand --->> layoutSubviews End")
    }
    
    func show()
    {
        self.prefBt.isEnabled = false
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    func setupRefresh()
    {
        /**
        self.candList.addHeaderWithCallback({
            let delayInSeconds:Int64 = 1000000000 * 2
            var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //self.scrollView!.contentSize = self.view.frame.size
                self.candList.headerEndRefreshing()
            })
        })
        ***/
        /*
        self.candList.addFooterWithCallback(
            {                
                let delayInSeconds:Int64 =  500000000//1000000000
                var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
                dispatch_after(popTime, dispatch_get_main_queue(), {

                    self.loadMore()
                    self.candList.footerEndRefreshing()
                })
            })
        */
    }
    
    /*
    func createCand(_ name: String, idx: Int) -> CandItem
    {
        var tempBt : CandItem = CandItem()
        
        tempBt.setTitle(" \(name) ", for: .normal)
        tempBt.titleLabel?.font = self.font
        tempBt.setTitleColor(UIColor.black, for: .normal)
        tempBt.setTitleColor(UIColor.white, for: .highlighted)
        tempBt.setBackgroundImage(Globals.activeImg, for: .highlighted)
        tempBt.tag = idx

        if idx == -1
        {
            tempBt.addTarget(self.handler, action: Selector("doLoadMore"), for: .touchUpInside)
        }
        else
        {
            tempBt.addTarget(self.handler, action: Selector("doSelectCand:"), for: .touchUpInside)
        }
        tempBt.backgroundColor = self.backColor
        //tempBt.isUserInteractionEnabled = false
        
        self.candList.addSubview(tempBt)
        return tempBt
    }*/

    func createCand2(_ idx: Int) -> CandItem
    {
        let tempBt : CandItem = CandItem()
        
        tempBt.titleLabel?.font = self.font
        tempBt.setTitleColor(UIColor.black, for: .normal)
        tempBt.setTitleColor(UIColor.white, for: .highlighted)
        tempBt.setBackgroundImage(Globals.images["av"], for: .highlighted)
        tempBt.addTarget(self.handler, action: Selector("doSelectCand:"), for: .touchUpInside)
        tempBt.backgroundColor = self.backColor

        return tempBt
    }

    // 加载一页内容
    private func loadOnePage(_ begin: Int32)
    {
        MyLog("----->>> BigCand --->> loadOnePage")
        
        let count : Int32 = Int32(self.candCache.count)
        var i: Int32 = begin
        var oi: Int = 0

        if begin < count
        {
            while i < count && oi < self.cands.count
            {
                let item = self.cands[oi]
                item.tag = Int(i)
                item.setTitle("  \(self.getCandFromCache(Int(i)))  ", for: .normal)
                item.sizeToFit()
                self.candList.addSubview(item)
                i += 1
                oi += 1
            }
        }

        self.nextBt.isEnabled = false
        self.prefBt.isEnabled = false

        //self.setNeedsLayout()
        self.layoutSubviews()
        
        // 计算 “上一页“， “下一页“ 是否可用
        for cand in self.cands
        {
            if cand.frame.origin.y > self.candList.frame.height && cand.superview == self.candList
            {
                self.nextBt.isEnabled = true
                break
            }
        }
        self.prefBt.isEnabled = self.pageHistory.count > 0

        MyLog("----->>> BigCand --->> loadOnePage End")
    }
    
    
    // 上一页
    func prefPage()
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.loadOnePage(self.pageHistory.removeLast())
    }

    // 下一页
    func nextPage()
    {
        var currentIdx: Int32 = -1
        var nextIdx: Int32 = -1
        
        for cand in self.cands
        {
            if currentIdx == -1
            {
                currentIdx = Int32(cand.tag)
            }
            if nextIdx == -1 && cand.frame.origin.y > self.candList.frame.height
            {
                nextIdx = Int32(cand.tag - 1)
            }
            cand.removeFromSuperview()
        }

        self.pageHistory.append(currentIdx)
        self.loadOnePage(nextIdx)
    }
    
    // 缓冲结果
    private func cacheCand(_ engine: EngineService)
    {
        let count : Int32 = engine.CandCount()
        var i: Int32 = 0
        
        assert(self.candCache.count == 0, "这里要为0")
        if count > 0
        {
            for i in 0..<count
            {
                self.candCache.append(engine.GetCand(i))
            }
        }
    }
    
    private func getCandFromCache(_ i: Int) -> NSString
    {
        return self.candCache[i]
    }

    // 第一页
    func updateCands(_ engine: EngineService)
    {
        assert(self.cands.count == 0, "这里正常是为 0")
        if self.cands.count == 0
        {
            for i in 0...99     // 这里限制数量
            {
                self.cands.append(self.createCand2(i))
            }
        }
        self.cacheCand(engine)
        self.loadOnePage(0)
    }
    
    /*
    func updateCands_old(_ engine: EngineService)
    {
        self.cacheCand(engine)
        
        if true
        {
            var count : Int = self.candCache.count
            var i: Int = 0
        
            // 开始只加载100个记录，目的是加速显示
            if count > 0
            {
                assert(self.cands.count == 0, "这里正常是为 0")
        
                for i = 0; i < count && i < 100; i += 1
                {
                    self.cands.append(self.createCand(self.getCandFromCache(i), idx: i))
                }
                if i < count
                {
                    self.moreShowing = true
                    self.moreBt = self.createCand("...", idx: Int(-1))
                    self.cands.append(self.moreBt!)
                }
                self.curCount = Int(i)
                self.setNeedsLayout()
            }
        }
    }*/
    /*
    func loadMore()
    {
            // 每多加载一次就读取500个记录
            var i: Int = self.curCount
            var end: Int = self.curCount + 500
            var count : Int = self.candCache.count
        
            self.cands.removeLast()
            for i; i < count && i < end; i += 1
            {
                self.cands.append(self.createCand(self.getCandFromCache(i) , idx: Int(i)))
            }
        
            if (i < count)
            {
                // 还有
                self.cands.append(self.moreBt!)
            }
            else
            {
                self.moreBt!.removeFromSuperview();
            }
        
            self.curCount = Int(i)
            self.setNeedsLayout()
    }*/
    
    func Reset()
    {
        self.moreShowing = false
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: true)
        self.pageHistory.removeAll(keepingCapacity: false)
        self.candCache.removeAll(keepingCapacity: false)
        self.setNeedsLayout()
        self.candList.contentOffset = CGPoint.zero
    }
    
    func End()
    {
        for cand in self.cands
        {
            cand.removeFromSuperview()
        }
        self.cands.removeAll(keepingCapacity: false)
        self.pageHistory.removeAll(keepingCapacity: false)
        self.candCache.removeAll(keepingCapacity: false)
        self.candList?.contentOffset = CGPoint.zero

        self.candList?.removeFromSuperview()
        self.candList = nil
        self.moreBt?.removeFromSuperview()
        self.moreBt = nil
        self.closeBt?.removeFromSuperview()
        self.closeBt = nil
        self.nextBt?.removeFromSuperview()
        self.nextBt = nil
        self.prefBt?.removeFromSuperview()
        self.prefBt = nil
        
        self.handler = nil
        self.oldBounds = nil
        self.backgroundColor = nil
    }
}
