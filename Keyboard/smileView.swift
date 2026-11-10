//
//  BigCandView2.swift
//  CJKeyboard
//
//  Created by mac on 14-12-1.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation
import UIKit


class SmileView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    var closeBt : UIButton!
    var handler: AnyObject!
    var oldBounds: CGRect?
    
    var candSmile: [NSString]!
    //var hzLabel: UILabel?
    //var enLabel: UILabel?
    var delegate: KeyboardCandProtocol?
    var rowHeight: CGFloat = 0

    init(handler: AnyObject)
    {
        self.candSmile = []
        let mb = Bundle.main
        let orgPath = (mb.resourcePath! as NSString).appendingPathComponent("bq.txt")
        let content = try? String(contentsOfFile: orgPath, encoding: String.Encoding.utf8)
        let ary = content!.components(separatedBy: ";")
        for item in ary
        {
            if (item as NSString).length > 0
            {
                self.candSmile.append(item as NSString)
            }
        }

        
        self.handler = handler

        super.init(frame: CGRect.zero)
        
        self.layout.minimumInteritemSpacing = 1
        self.layout.minimumLineSpacing = 1
        self.layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        self.layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.backgroundColor = UIColor.clear // UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)

        self.closeBt = createMyButton(Lang("  返 回  "))
        self.closeBt.addTarget(self.superview?.superclass, action: Selector("doSmile"), for: .touchUpInside)
        self.addSubview(self.closeBt)
        
        self.addSubview(self.collectionView)
        self.backgroundColor = KeyboardColor.mSmileBColor   // UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.layer.zPosition = 200
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        self.End()
    }
    
    func End()
    {
        self.collectionView?.removeFromSuperview()
        self.collectionView = nil
        self.closeBt?.removeFromSuperview()
        self.closeBt = nil
        self.handler = nil
        self.oldBounds = nil
        self.candSmile?.removeAll(keepingCapacity: false)
        self.candSmile = nil
        //self.hzLabel = nil
        //self.enLabel = nil
        self.delegate = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        MyLog("----->>> Smile --->> numberOfItemsInSection")
        
        return self.candSmile.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func createCandLabel() -> UILabel
    {
        let cand = UILabel()
        cand.font = UIFont.systemFont(ofSize: self.rowHeight * 0.7)
        //cand.font = UIFont.systemFont(ofSize: self.frame.width/10)
        cand.textColor = KeyboardColor.mCandTxtColor
        cand.backgroundColor = UIColor.clear
        cand.textAlignment = .center
        return cand
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : UICollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell?
        
        let label : UILabel? = cell!.contentView.viewWithTag(1000001) as! UILabel?
        
        let text = self.candSmile[indexPath.row]
        
        if label == nil
        {
            let label = createCandLabel()
            cell!.backgroundColor = KeyboardColor.mCellColor
            cell!.contentView.addSubview(label)
            label.tag = 1000001
            label.text = text as String
            label.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
            label.sizeToFit()
            label.frame.origin.y = (cell!.frame.height - label.frame.height) / 2
            label.frame.size.width = cell!.frame.width
            //label.backgroundColor = UIColor.yellow
            MyLog("cell new = " + String(indexPath.row))
        }
        else
        {
            label?.text = text as String
            label?.sizeToFit()
            label?.frame.size.width = cell!.frame.width
            MyLog("cell = " + String(indexPath.row))
        }

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        collectionView.cellForItem(at:indexPath)?.backgroundColor = KeyboardColor.mCellColor_hi // UIColor.gray.withAlphaComponent(0.3)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        collectionView.cellForItem(at:indexPath)?.backgroundColor = KeyboardColor.mCellColor
    }
    

    // 定义每个UICollectionView 的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            /**
            if self.hzLabel == nil
            {
                self.hzLabel = self.createCandLabel()
                self.hzLabel!.text = "👿"
                self.hzLabel!.sizeToFit()
            }
            let len = 1.2
            let width = min(max(self.hzLabel!.frame.width * CGFloat(len), self.rowHeight), self.collectionView.frame.width)
            */
        
            let width = Int((self.frame.width - 5)/6)
            
            return CGSize(width: CGFloat(width), height: self.rowHeight)
    }

    // 返回这个UICollectionView是否可以被选择
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.delegate?.didSelectSmile_String(self.candSmile[indexPath.row] as String)
    }

    
    override func layoutSubviews()
    {
        MyLog("----->>> BigCand2 --->> layoutSubviews")
        super.layoutSubviews()
        
        if (self.oldBounds == nil || self.oldBounds! != self.bounds)
        {
            let btnAreHeight = self.frame.height / 6 + 10
            self.closeBt.frame.size.height = btnAreHeight - 10
            self.closeBt.frame.origin.x = self.frame.width/2 - self.closeBt.frame.width/2
            self.closeBt.frame.origin.y = self.frame.height - self.closeBt.frame.height - ((btnAreHeight - self.closeBt.frame.height)/2)
            
            self.collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - btnAreHeight)
            
            self.rowHeight = (self.frame.height - btnAreHeight - 4) / 3
            if ((self.frame.width / self.rowHeight) < 6)
            {
                self.rowHeight = (self.frame.height - btnAreHeight - 5) / 4
            }
            self.oldBounds = self.bounds
        }
    }
    
    func show()
    {
        self.isHidden = false

        // 修改 “返回“ 按钮的 label
        //let lastIM = Globals.prefs.integer(forKey: "defaultCnIM")
        self.closeBt.setTitle(Lang("  返 回  "), for: .normal)
        self.closeBt.titleLabel!.font = UIFont(name: "ChalkboardSE", size: 18)
        self.closeBt.sizeToFit()
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    func showing() -> Bool
    {
        return (self.isHidden == false)
    }
}
