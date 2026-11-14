//
//  BigCandView2.swift
//  DWKeyboard
//
//  Created by mac on 14-12-1.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import Foundation
import UIKit


class BigCandView2: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    var symbPage: UIScrollView?
    var closeBt : UIButton!
    var cellBackColor: UIColor!
    var handler: AnyObject!
    
    var candCache: [NSString]!
    var hzLabel: UILabel?
    var enLabel: UILabel?
    var delegate: KeyboardCandProtocol?
    var rowHeight: CGFloat = 0
    var isQueryCand: Bool = false
    var isSymbolCand: Bool = false
    
    var symb_EnBtn: UIButton?
    var symb_CNBtn: UIButton?
    var symb_MathBtn: UIButton?
    var symb_NetBtn: UIButton?
    var symb_GrapBtn: UIButton?
    var symb_OtherBtn: UIButton?
    var widthAry: [Int] = []
    var monospacedChr: Bool = false

    init(handler: AnyObject)
    {
        self.candCache = []
        self.handler = handler

        super.init(frame: CGRect.zero)
        self.cellBackColor = KeyboardColor.mCellColor       //UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.5) //UIColor.yellow
        self.backgroundColor = KeyboardColor.mCandBColor    //UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        
        self.layout.minimumInteritemSpacing = 1
        self.layout.minimumLineSpacing = 1
        self.layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        self.layout.scrollDirection = UICollectionView.ScrollDirection.vertical

        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        self.addSubview(self.collectionView)

        self.closeBt = createMyButton(Lang("  返 回  "))
        self.closeBt.addTarget(self.handler, action: Selector("doCloseBigCand"), for: .touchUpInside)
        self.addSubview(self.closeBt)
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
        self.cellBackColor = nil
        self.candCache?.removeAll(keepingCapacity: false)
        self.candCache = nil
        self.hzLabel = nil
        self.enLabel = nil
        self.delegate = nil
        
        self.symbPage = nil
        self.symb_CNBtn = nil
        self.symb_EnBtn = nil
        self.symb_GrapBtn = nil
        self.symb_MathBtn = nil
        self.symb_OtherBtn = nil
        self.symb_NetBtn = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        MyLog("----->>> BigCand2 --->> numberOfItemsInSection")
        
        return self.candCache.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func createCandLabel() -> UILabel
    {
        let cand = UILabel()
        cand.font = UIFont.systemFont(ofSize: self.rowHeight * 0.45)
        cand.textColor = KeyboardColor.mCandTxtColor
        cand.backgroundColor = UIColor.clear
        cand.textAlignment = .center
        return cand
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : UICollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell?
        
        var label : UILabel? = cell!.contentView.viewWithTag(1000001) as! UILabel?
        if label == nil
        {
            label = createCandLabel()
            cell!.backgroundColor = self.cellBackColor
            cell!.contentView.addSubview(label!)
            label!.tag = 1000001
        }
        let txt = self.candCache[indexPath.row] as String
        label!.text = txt
        label!.adjustsFontSizeToFitWidth = true
        label!.minimumScaleFactor = 0.3
        label!.lineBreakMode = NSLineBreakMode.byClipping
        label!.textAlignment = .center
        // 字号按格子宽度和字数算，长词自动缩小，绝不出省略号
        let base = self.rowHeight * 0.45
        let fit = cell!.frame.width / CGFloat(max(txt.count, 1))
        label!.font = UIFont.systemFont(ofSize: min(base, fit))
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
        collectionView.cellForItem(at:indexPath)?.backgroundColor = KeyboardColor.mCellColor_hi // UIColor.gray.withAlphaComponent(0.3)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        collectionView.cellForItem(at:indexPath)?.backgroundColor = self.cellBackColor
    }
    
    // 计算 item 的宽度，会自动分配多余的空间
    private func caluCandWidths()
    {
        if (self.rowHeight > 0)
        {
            if (self.hzLabel == nil)
            {
                self.hzLabel = self.createCandLabel()
                self.hzLabel!.text = "我"
                self.hzLabel!.sizeToFit()
            }
            if (self.enLabel == nil)
            {
                self.enLabel = self.createCandLabel()
            }
        }

        if self.widthAry.count == 0 && self.rowHeight > 0
        {
            MyLog("caluCandWidths >> rowHeight \(self.rowHeight)")

            // 第一趟计算宽度
            for cand in self.candCache
            {
                if UInt32(cand.character(at: 0)) > 255
                {
                    // 中文
                    let len = cand.length + 1
                    let width = Int(min(max(self.hzLabel!.frame.width * CGFloat(len), self.rowHeight), self.collectionView.frame.width))
                    self.widthAry.append(width)
                }
                else
                {
                    // 英文
                    self.enLabel!.text = cand as String
                    self.enLabel!.sizeToFit()
                    let one = self.enLabel!.frame.width + self.enLabel!.font.lineHeight
                    let width = Int(min(max(one, self.rowHeight), self.collectionView.frame.width))
                    self.widthAry.append(width)
                }
            }
            
            // 第二趟计算，把多余的平均分配
            let gap = Int(self.layout.minimumInteritemSpacing)
            let maxWidth = Int(self.collectionView.frame.width - self.layout.sectionInset.left - self.layout.sectionInset.right)
            var begin : Int = 0
            var rowWidth: Int = 0;
            var numOfRow: Int = 0;
            for i in 0..<self.widthAry.count
            {
                let gapTemp = (i == begin) ? 0 : gap
                if ((rowWidth + self.widthAry[i] + gapTemp) < maxWidth)
                {
                    rowWidth += (self.widthAry[i] + gapTemp)
                    numOfRow += 1
                }
                else
                {
                    let padding = (maxWidth - rowWidth) / Int(numOfRow)
                    for n in 0..<(numOfRow)
                    {
                        self.widthAry[begin + n] += padding
                    }
                    self.widthAry[begin + numOfRow - 1] += Int((maxWidth - rowWidth) - (padding * numOfRow)) // 余数全给最后一个
                    rowWidth = self.widthAry[i];
                    begin = i;
                    numOfRow = 1;
                }
            }
        }
    }

    // 定义每个UICollectionView 的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // 4 行 × 6 列固定网格
        return CGSize(width: max(1, collectionView.frame.width / 6), height: self.rowHeight)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if self.isQueryCand || self.isSymbolCand
        {
            self.delegate?.didSelectSmile_String(self.candCache[indexPath.row] as String)
        }
        else
        {
            self.delegate?.didSelectCand(indexPath.row, str: self.candCache[indexPath.row] as String)
        }
    }

    // 从引擎获取数据，并显示
    func updateCands(_ im: Int, engine: EngineService)
    {
        self.monospacedChr = !IsEnglishKB(im)
        self.isQueryCand = false;
        self.isSymbolCand = false;
        
        // 缓冲结果
        RunTimeBegin()
        if true
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
        RunTimeEnd("BigCand --->>> cacheCand")
        
        RunTimeBegin()
        self.collectionView.reloadData()
        self.collectionView.contentOffset = CGPoint.zero
        RunTimeEnd("BigCand --->>> reloadData")
    }
    
    // 从数组里获取数据，并显示
    func updateCandByStringList(_ contents: String, separated: String)
    {
        self.isQueryCand = true;
        self.isSymbolCand = false
        
        self.setSymbol(contents, separated: separated)
    }
    
    // 符号窗
    func updateForSymbol(_ im: Int)
    {
        self.isSymbolCand = true
        self.isQueryCand = false
        
        // 符号分页
        self.symbPage = UIScrollView()
        self.addSubview(self.symbPage!)
        
        self.symb_EnBtn = createMyButton(Lang("  英 文  "))
        self.symb_CNBtn = createMyButton(Lang("  中 文  "))
        self.symb_MathBtn = createMyButton(Lang("  数 学  "))
        self.symb_NetBtn = createMyButton(Lang("  网 络  "))
        self.symb_GrapBtn = createMyButton(Lang("  图 形  "))
        self.symb_OtherBtn = createMyButton(Lang("  其 它  "))

        self.symb_EnBtn!.layer.cornerRadius = 0
        self.symb_CNBtn!.layer.cornerRadius = 0
        self.symb_MathBtn!.layer.cornerRadius = 0
        self.symb_NetBtn!.layer.cornerRadius = 0
        self.symb_GrapBtn!.layer.cornerRadius = 0
        self.symb_OtherBtn!.layer.cornerRadius = 0

        self.symb_CNBtn!.addTarget(self, action: Selector("onSymb_Cn"), for: .touchUpInside)
        self.symb_EnBtn!.addTarget(self, action: Selector("onSymb_En"), for: .touchUpInside)
        self.symb_MathBtn!.addTarget(self, action: Selector("onSymb_Math"), for: .touchUpInside)
        self.symb_NetBtn!.addTarget(self, action: Selector("onSymb_Net"), for: .touchUpInside)
        self.symb_GrapBtn!.addTarget(self, action: Selector("onSymb_Grap"), for: .touchUpInside)
        self.symb_OtherBtn!.addTarget(self, action: Selector("onSymb_Other"), for: .touchUpInside)
        
        self.symbPage?.addSubview(self.symb_CNBtn!)
        self.symbPage?.addSubview(self.symb_EnBtn!)
        self.symbPage?.addSubview(self.symb_MathBtn!)
        self.symbPage?.addSubview(self.symb_NetBtn!)
        self.symbPage?.addSubview(self.symb_GrapBtn!)
        self.symbPage?.addSubview(self.symb_OtherBtn!)
        
        if IsEnglishKB(im)
        {
            self.onSymb_En()
        }
        else
        {
            self.onSymb_Cn()
        }
    }
    
    // 设置一个页面的符号
    private func setSymbol(_ contents: String, separated: String)
    {
        self.candCache.removeAll()
        self.widthAry.removeAll()
        
        if separated.count == 0
        {
            for chr in contents
            {
                self.candCache.append(String(chr) as NSString)
            }
        }
        else
        {
            let ary = contents.components(separatedBy: separated)
            for item in ary
            {
                self.candCache.append(item as NSString)
            }
        }
        self.collectionView.reloadData()
        self.collectionView.contentOffset = CGPoint.zero
    }
    
    // 符号专用
    private func setDown_symbBtn(_ btn: UIButton)
    {
        self.symb_CNBtn!.isSelected = false
        self.symb_EnBtn!.isSelected = false
        self.symb_MathBtn!.isSelected = false
        self.symb_NetBtn!.isSelected = false
        self.symb_GrapBtn!.isSelected = false
        self.symb_OtherBtn!.isSelected = false
        btn.isSelected = true
    }

    // 以下：符号专用
    @objc func onSymb_Cn()
    {
        self.setDown_symbBtn(self.symb_CNBtn!)
        self.setSymbol("，。、！？：；`﹑.•＂^…‘’“”〝〞~\\∕|¦‖()﹛﹜〈〉﹝﹞「」‹›〖〗[]{}《》〔〕『』«»【】—", separated: "");
    }
    @objc func onSymb_En()
    {
        self.setDown_symbBtn(self.symb_EnBtn!)
        self.setSymbol(",.;:?!@#$%^&*()-+_=\\/|{}[]\"\'<>±", separated: "");
    }
    @objc func onSymb_Math()
    {
        self.setDown_symbBtn(self.symb_MathBtn!)
        self.setSymbol("﹙﹚﹛﹜[]＋－×÷﹢﹣±／＜＞﹤﹥·∶∴∵∷⊙∫∮∝∞∧∨º¹²³½¾¼≠≤≥≈≡≒∥＝≦≧≌∽≮≯∑∏∪∩∈⊿⌒√∟㏒㏑￠∠⊥％‰℅°℃℉′″〒¤○μ㎎㎏㎜㎝㎞㎡㏄㏎㏑㏒mlmol＄￡￥㏕♂♀", separated: "");
    }
    @objc func onSymb_Net()
    {
        self.setDown_symbBtn(self.symb_NetBtn!)
        self.setSymbol("@ www. http:// @qq.com .com .cn .net .wap - _ .org .中国 https:// @163.com @sohu.com @126.com @gmail.com @sina.com", separated: " ");
    }
    @objc func onSymb_Grap()
    {
        self.setDown_symbBtn(self.symb_GrapBtn!)
        self.setSymbol("△▽○◇□☆▷◁♤♡♢♧☼☏•▲▼●◆■★☻▪•*☉⊙⊕Θ◎¤✪の⊿☜☞‥…▁▂▃▄▅▆▇█▉▊▋▌▍▎▏", separated: "");
    }
    @objc func onSymb_Other()
    {
        self.setDown_symbBtn(self.symb_OtherBtn!)
        self.setSymbol("āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜüńňêɑɡθʃtʃdʒʒðŋ", separated: "");
    }
    // 以上：符号专用

    override func layoutSubviews()
    {
        MyLog("----->>> BigCand2 --->> layoutSubviews")
        super.layoutSubviews()
        
        let padding : CGFloat = 10
        let btnAreHeight = self.frame.height / 6
        
        if (true)
        {
            self.closeBt.frame.size.height = btnAreHeight - padding
            if self.isSymbolCand
            {
                self.closeBt.frame.origin.x = 2   // 左对齐
            }
            else
            {
                self.closeBt.frame.origin.x = self.frame.width/2 - self.closeBt.frame.width/2   // 居中
            }
            self.closeBt.frame.origin.y = (self.frame.height - self.closeBt.frame.height) - (padding/2);
        }

        // 符号专用
        if (self.isSymbolCand)
        {
            let x = self.closeBt.frame.origin.x + self.closeBt.frame.width + 5
            let y = self.closeBt.frame.origin.y
            self.symbPage!.frame = CGRect(x: x, y: y, width: self.frame.width - x, height: btnAreHeight - padding)
            
            let h = self.symbPage!.frame.height
            var sx:CGFloat = 0;
            self.symb_EnBtn!.frame      = CGRect(x: sx, y: 0, width: self.symb_EnBtn!.frame.width, height: h);    sx += self.symb_EnBtn!.frame.width + 1
            self.symb_CNBtn!.frame      = CGRect(x: sx, y: 0, width: self.symb_CNBtn!.frame.width, height: h);    sx += self.symb_CNBtn!.frame.width + 1
            self.symb_MathBtn!.frame    = CGRect(x: sx, y: 0, width: self.symb_MathBtn!.frame.width, height: h);  sx += self.symb_MathBtn!.frame.width + 1
            self.symb_NetBtn!.frame     = CGRect(x: sx, y: 0, width: self.symb_NetBtn!.frame.width, height: h);   sx += self.symb_NetBtn!.frame.width + 1
            self.symb_GrapBtn!.frame    = CGRect(x: sx, y: 0, width: self.symb_NetBtn!.frame.width, height: h);   sx += self.symb_GrapBtn!.frame.width + 1
            self.symb_OtherBtn!.frame   = CGRect(x: sx, y: 0, width: self.symb_OtherBtn!.frame.width, height: h); sx += self.symb_OtherBtn!.frame.width + 1
            
            self.symbPage?.contentSize  = CGSize(width: sx, height: 0)
        }
        
        self.rowHeight = (self.frame.height - btnAreHeight) / 4
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - btnAreHeight)
        MyLog("rowHeight \(self.rowHeight)")
    }
    
    func show()
    {
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    func Reset()
    {
        self.candCache.removeAll(keepingCapacity: false)
        self.widthAry.removeAll()
    }
}
