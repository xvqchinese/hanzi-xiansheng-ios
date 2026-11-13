//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
set the name of your subclass in the Info.plist file.
*/


extension KeyboardViewController
{
    func MyKeyPressed(_ key: Key, repeatCount: Int, isSwipeDown: Bool) -> Bool
    {
        var ret: Bool = false
        
        if IsNeedEngine(self.currentPage)
        {
            if (key.type == Key.KeyType.Space)
            {
                // 空格
                if (self.engine.hasInput())
                {
                    if self.engine.CandCount() > 0
                    {
                        self.selectCand(0, str: nil)
                    }
                    else
                    {
                        self.out(self.engine.inputStr() as String, sendCand: false)
                        self.engine.Reset()
                        self.closeCand()
                    }
                }
                else
                {
                    self.out(" ", sendCand: false)
                }
            }
            else if (key.type == Key.KeyType.Return)
            {
                // 回车
                if (self.engine.hasInput())
                {
                    if self.currentPage != KbPage.M_SK9
                    {
                        self.out(self.engine.inputStr() as String, sendCand: false)
                    }
                    self.engine.Reset()
                    self.closeCand()
                }
                else
                {
                    self.out("\n", sendCand: false)
                }
            }
            else if (key.type == Key.KeyType.Character && (key.keyCode == nil || key.keyCode?.length == 0))
            {
                // 直接上屏
                self.outMulti(key.outputForCase(false), idx: 0)
            }
            else
            {
                if self.currentPage == KbPage.M_HW
                {
                    // 手写，退格
                    if key.type == Key.KeyType.Backspace && (self.mForwardingView.hasInput() || self.isSmallCandShowing())
                    {
                        self.mHwQuery?.text = ""
                        self.mForwardingView.reset()
                        self.engine.Reset()
                        updateCandComp()
                        return true
                    }
                }
                else
                {
                    if self.currentPage == KbPage.M_SK9 && !isSwipeDown
                    {
                        if /*key.keyCode == "8" || */key.keyCode == "9"
                        {
                            self.outMulti(key.lowercaseOutput!, idx: 0)
                            return true;
                        }
                    }
                    if key.type == Key.KeyType.Backspace
                    {
                        if self.engine.hasInput()
                        {
                            self.engine.DeleteKey()
                            self.updateCandComp()
                            return true
                        }
                        self.deleteBackward()
                        return true
                    }
                    if self.currentPage == KbPage.M_SK9, Globals.playWav, Globals.accessOpen, let kc = key.keyCode, kc.length == 1
                    {
                        let strokeSound: [String: String] = ["d": "dianv", "h": "hengx", "s": "shuq", "p": "piev", "n": "naq", "z": "zhex"]
                        if let py = strokeSound[String(kc).lowercased()] { playWav(py) }
                    }
                    // 转入引擎
                    ret = self.engine.SendKey(key, uppercase: self.shiftState.uppercase(), isSwipeDown: isSwipeDown)
                    if ret
                    {
                        if self.engine.canUpscreen()
                        {
                            self.out(self.engine.UpscreenStr() as String, sendCand: false)
                        }
                        self.updateCandComp()
                    }
                }
            }
    
        }   // if IsNeedEngine end
            
        else if (self.currentPage == KbPage.M_Abc9)
        {
            if key.keyCode == nil
            {
                return false
            }
            
            let k : NSString = key.keyCode!
            let v : Int32 = Int32(k.character(at: 0))
            var str: String?
            switch v
            {
            case 48: str = "0"
            case 49: str = "1`@`,`.`!"
            case 50: str = "a`b`c`2"
            case 51: str = "d`e`f`3"
            case 52: str = "g`h`i`4"
            case 53: str = "j`k`l`5"
            case 54: str = "m`n`o`6"
            case 55: str = "p`q`r`s`7"
            case 56: str = "t`u`v`8"
            case 57: str = "w`x`y`z`9"
            default:
                return true
            }
            if repeatCount > 0
            {
                self.deleteBackward()
            }
            self.outMulti(self.shiftState.uppercase() ? (str!.uppercased()) : (str!), idx: repeatCount)
        }
        else
        {
            self.outMulti(key.outputForCase(self.shiftState.uppercase()), idx: 0)
        }
        
        return ret
    }
    
    func outMulti(_ str: String, idx: Int)
    {
        let temp: NSString = str as NSString
        
        if (temp.range(of: "`").length > 0)
        {
            let ary = temp.components(separatedBy: "`")
            self.out(ary[idx % ary.count] as NSString as String, sendCand: true) // 上符号前，先上第一个候选
        }
        else
        {
            self.out(temp as String, sendCand: true) // 上符号前，先上第一个候选
        }
    }

    // 输出到文本框
    func out(_ str: String, sendCand: Bool)
    {
        if str.isEmpty
        {
            return
        }
        
        if (sendCand && self.engine.hasInput())
        {
            // 上符号前，先上第一个候选
            self.selectCand(0, str: nil)
        }

        if let proxy = self.textDocumentProxy as UITextDocumentProxy?
        {
            proxy.insertText(str)
            
            if (str == "“”" ||
                str == "‘’" ||
                str == "()" ||
                str == "（）" ||
                str == "［］" ||
                str == "｛｝" ||
                str == "《》" ||
                str == "[]" ||
                str == "{}" ||
                str == "<>")
            {
                self.autoMoveFocusTimer?.invalidate()
                self.autoMoveFocusTimer = nil
                self.autoMoveFocusTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: Selector("autoMoveFocus"), userInfo: nil, repeats: false)
            }
        }
    }
    
    // 繁体转换，中英互译
    func outConv(_ str: String) -> String
    {
        if IsEnglishKB(self.currentPage)
        {
            if Globals.enOutConv == 1   // 输出中文
            {
                if let cnLs = self.engine.quertCnByEn(str)
                {
                    self.engine.Reset() // 防止联想
                    if !cnLs.contains("^")
                    {
                        // 只有一个结果，直接上屏
                        self.out(cnLs, sendCand: false)
                        return ""
                    }
                    self.hideKeyboard()
                    self.mBannerCand?.hide()
                    self.createBigCand()
                    
                    self.mBigCandPanel?.Reset()
                    self.mBigCandPanel?.updateCandByStringList(cnLs, separated: "^")
                    self.mBigCandPanel?.show()
                }
                return "";
            }
        }
        else
        {
            if Globals.cnOutConv == 1   // 繁体
            {
                return gbk2Big5(str as NSString)
            }
            else if Globals.cnOutConv == 2   // 输出英文
            {
                if let enLs = self.engine.quertEnByCn(str)
                {
                    self.engine.Reset() // 防止联想
                    if !enLs.contains("^")
                    {
                        // 只有一个结果，直接上屏
                        self.out(enLs, sendCand: false)
                        return ""
                    }
                    self.hideKeyboard()
                    self.mBannerCand?.hide()
                    self.createBigCand()
                    
                    self.mBigCandPanel?.Reset()
                    self.mBigCandPanel?.updateCandByStringList(enLs, separated: "^")
                    self.mBigCandPanel?.show()
                }
                return "";
            }
        }
        return str
    }
    
    func deleteBackward()
    {
        if let proxy = self.textDocumentProxy as UITextDocumentProxy?
        {
            proxy.deleteBackward()
        }
    }
    
    // 定时把光标向左移一个位置
    @objc func autoMoveFocus()
    {
        if let proxy = self.textDocumentProxy as UITextDocumentProxy?
        {
            proxy.adjustTextPosition(byCharacterOffset: -1)
        }
    }

    private func isSmallCandShowing() -> Bool
    {
        if self.mBannerCand != nil && self.mBannerCand!.isHidden == false
        {
            return true
        }
        return false
    }
    
    private func createSmallCand()
    {
        if self.mBannerCand == nil
        {
            self.mBannerCand = self.banner_cand()
            self.mBannerCand!.delegate = self
            self.view.addSubview(self.mBannerCand!)
        }
    }
    
    func closeSmallCand()
    {
        if self.mBannerCand != nil
        {
            self.mBannerCand!.hide()
            self.mBannerCand!.removeFromSuperview()
            self.mBannerCand!.End()
            self.mBannerCand = nil
        }
    }
    
    
    private func isBigCandShowing() -> Bool
    {
        if self.mBigCandPanel != nil && self.mBigCandPanel!.isHidden == false
        {
            return true
        }
        return false
    }
    
    func createBigCand()
    {
        if self.mBigCandPanel == nil
        {
            self.mBigCandPanel = self.view_bigCand()
            self.mBigCandPanel!.delegate = self
            self.view.addSubview(self.mBigCandPanel!)
        }
    }

    func closeBigCand()
    {
        if self.mBigCandPanel != nil
        {
            self.mBigCandPanel!.hide()
            self.mBigCandPanel!.removeFromSuperview()
            self.mBigCandPanel!.End()
            self.mBigCandPanel = nil
        }
    }
    
    // KeyboardCandProtocol
    func didSelectCand(_ index: Int, str: String?)
    {
        if self.currentPage == KbPage.M_HW
        {
            // 预先已上屏，所以这里要回退一个字符
            if self.mComposingText != nil
            {
                self.mComposingText = nil
                self.deleteBackward()
            }
            
            // 手写上屏
            let str1: NSString = str! as NSString
            let str2 = NSMutableString(format: str1.mutableCopy() as! NSMutableString)
            CFStringTrimWhitespace(str2)
            let outStr : NSString = str2.substring(from: self.hwAssociateKey == nil ? 0 : self.hwAssociateKey!.count) as NSString
            if (self.hwAssociateKey?.count ?? 0) > 0
            {
                // 联想调频
                self.engine.Select(Int32(index));
            }
            
            // 转换
            let conved = self.outConv(outStr as String)
            if conved.isEmpty
            {
                // 如果已显示转换结果，就不执行下面的代码
                self.updateCandComp()   // 使现在的候选条隐藏
                self.mForwardingView.reset()    // 手写笔画清除
                return
            }
            
            // 输出
            self.out(conved, sendCand: false)
            
            // 发音
            if Globals.playWav && Globals.accessOpen
            {
                playWav(self.getStringPinyin(outStr));
            }
            self.updateCandComp()
            self.mForwardingView.reset()
            self.engine.Reset()
            
            // 联想
            if self.engine.hwAssociate(outStr.substring(from: outStr.length-1) as NSString) > 0
            {
                self.hwAssociateKey = outStr.substring(from: outStr.length-1)
                if self.isBigCandShowing()
                {
                    self.doBigCand()
                }
                else
                {
                    self.updateCandComp()
                }
            }
            else
            {
                // 没有结果，隐藏候选栏
                self.closeCand()
                self.hwAssociateKey = nil
            }
        }
        else
        {
            // 拼音，笔画，英文，等等
            self.selectCand(index, str: nil)
        }
    }
    
    /**
    func doSelectCand(_ sender: UIButton)
    {
        self.didSelectCand(sender.tag, str: sender.titleLabel!.text)
    }***/

    func didSelectSmile_String(_ str: String?)
    {
        if (str != nil)
        {
            self.out(str!, sendCand: false)
        }

        if self.mBigCandPanel != nil && self.mBigCandPanel!.isQueryCand
        {
            // 反查结果，选择后直接关闭
            doCloseBigCand()
        }
    }
    
    private func selectCand(_ index: Int, str: String?)
    {
        let code = self.engine.GetCandCode(Int32(index))
        let cand = self.engine.GetCand(Int32(index))
        
        self.engine.Select(Int32(index))
        if self.engine.canUpscreen()
        {
            let conved = self.outConv(self.engine.UpscreenStr() as String)
            if conved.isEmpty
            {
                // 如果已显示反查结果，就不执行下面的代码
                self.updateCandComp()   // 使现在的候选条隐藏
                return
            }
            self.out(conved, sendCand: false)
        }
        
        // 发音
        if Globals.playWav && Globals.accessOpen
        {
            if (self.currentPage == KbPage.M_Chn)
            {
                // 拼音
                playWav(code as String);
            }
            else if (self.currentPage == KbPage.M_SK9)
            {
                // 笔画
                playWav(self.getStringPinyin(cand));
            }
        }
        
        if self.isBigCandShowing()
        {
            self.doBigCand()
        }
        else
        {
            self.updateCandComp()
        }
    }
    
    
    func doSelectCoinciding(_ sender: UIButton)
    {
        if sender.tag == -1
        {
            // 输出符号前，要上屏候选
            self.out(sender.titleLabel!.text!, sendCand: true)
        }
        else
        {
            self.engine.SendKey(EST.SPKEY_API_SYLLABLE, param: Int32(sender.tag))
            if self.engine.canUpscreen()
            {
                self.out(self.engine.UpscreenStr() as String, sendCand: false)
            }
            self.updateCandComp()
        }
    }
    
    
    // 显示音节
    func showCoinciding()
    {
        if self.mCoinciding == nil
        {
            self.mCoinciding = self.view_coinciding()
            self.view.addSubview(self.mCoinciding!)
        }
        if self.mCoinciding != nil
        {
            self.mCoinciding!.show(self.currentPage)
        }
    }
    
    // 隐藏音节
    func closeCoinciding()
    {
        if self.mCoinciding != nil
        {
            self.mCoinciding!.hide()
            self.mCoinciding!.removeFromSuperview()
            self.mCoinciding!.End()
            self.mCoinciding = nil
        }
    }
    
    // 更新小候选条
    func updateCandComp()
    {
        if self.engine.CandCount() == 0 && self.engine.hasInput() == false
        {
            // 没有结果，隐藏候选栏
            self.closeCand()
        }
        else
        {
            self.mBannerCmd.hide()
            self.createSmallCand()
            self.mBannerCand?.show()

            if self.engine.CandCount() > 0
            {
                // 有结果
                self.mBannerCand?.updateCands(self.engine)
            }
            else if self.engine.hasInput()
            {
                // 没有结果
                self.mBannerCand?.Reset()
            }

            if self.engine.hasInput()
            {
                // 有输入
                self.mBannerCand?.updateComp(self.engine.compStr(), page: self.currentPage)
            }

            if self.isSmallCandShowing() && !self.engine.hasInput()
            {
                // 无输入
                self.mBannerCand?.updateComp("", page: self.currentPage)
            }
        }

        if IsNeedCoinciding(self.currentPage)
        {
            // 更新音节
            if self.engine.syllableNum() > 0 && self.engine.hasInput()
            {
                self.mCoinciding?.updateSyllable(self.engine)
            }
            else
            {
                self.mCoinciding?.setSymbol(self.currentPage,reset: true)
            }
        }
    }
    
    //关闭小候选窗口
    func closeCand()
    {
        self.closeSmallCand()
        self.mBannerCmd.show()
    }
    
    // 显示大候选窗口
    func doBigCand()
    {
        if self.engine.CandCount() > 0
        {
            self.hideKeyboard()
            self.mBannerCand?.hide()
            self.createBigCand()

            self.mBigCandPanel?.Reset()
            self.mBigCandPanel?.updateCands(self.currentPage, engine: self.engine)
            self.mBigCandPanel?.show()
        }
        else
        {
            if (self.engine.CandCount() == 0 && self.engine.hasInput() == false) || self.engine.showIMWin() == false
            {
                // 没有结果，隐藏候选栏
                self.doCloseBigCand()
                self.closeCand()
            }
            else if self.engine.hasInput()
            {
                // 没有结果，有输入
                self.doCloseBigCand()
            }
        }
    }
    
    // 关闭大候选窗口
    func doCloseBigCand()
    {
        self.closeBigCand()
        self.showKeyboard()
        self.updateCandComp()
    }
    
    // 转繁体
    func gbk2Big5(_ str: NSString) ->String
    {
        var ret: String = "";
        if self.mBig5StringList == nil
        {
            self.mBig5StringList = getStringListByTxt("gb2b5")
        }
        if self.mBig5StringList != nil
        {
            for i in 0..<str.length
            {
                let hz: NSString = str.substring(with: NSRange(location: i, length: 1)) as NSString
                var ok: Bool = false
                for row in self.mBig5StringList!
                {
                    if row.count > 0 && (row as NSString).character(at: 0) == hz.character(at: 0)
                    {
                        ret += ((row as NSString).substring(from: 1))
                        ok = true
                        break
                    }
                }
                if (!ok)
                {
                    ret += (hz as String)
                }
            }
            return ret;
        }
        
        return (str as String)
    }
    
    // 汉字转拼音
    func getStringPinyin(_ str: NSString) ->String
    {
        var py: String = ""
        for i in 0..<str.length
        {
            let query = self.getHwQuery(str.substring(with: NSRange(location: i, length: 1)) as NSString)
            if query.count > 1
            {
                let pyAry = query.components(separatedBy: "\t");
                if (pyAry.count > 2)
                {
                    if py.count > 0
                    {
                        py += ","
                    }
                    py += pyAry[1];
                }
            }
        }
        return py;
    }

    // 搜索反查
    func getHwQuery(_ hz: NSString) -> String
    {
        if self.mHwQueryStringList == nil
        {
            self.mHwQueryStringList = getStringListByTxt("query")
        }

        if self.mHwQueryStringList != nil
        {
            let index: Int = ((Int)(hz.character(at: 0)) - 0x4e00)
            if index >= 0 && self.mHwQueryStringList!.count > index
            {
                var label = self.mHwQueryStringList![index]
                label = label.replacingOccurrences(of: "1", with: "h")
                label = label.replacingOccurrences(of: "2", with: "s")
                label = label.replacingOccurrences(of: "3", with: "p")
                label = label.replacingOccurrences(of: "4", with: "d")
                label = label.replacingOccurrences(of: "5", with: "n")
                label = label.replacingOccurrences(of: "6", with: "z")
                return label;
            }
        }
        return "";
    }
    
    // 手写反查
    func showHwQuery(_ hz: NSString)
    {
        if (self.mHwQuery == nil)
        {
            self.mHwQuery = UILabel();
            self.mHwQuery?.layer.zPosition = 300
            self.mHwQuery?.isUserInteractionEnabled = false
            self.mHwQuery?.textColor = KeyboardColor.mHwQueryTxtColor
            self.view.addSubview(self.mHwQuery!)
        }
        
        self.mHwQuery?.text = getHwQuery(hz as NSString)
        self.mHwQuery?.sizeToFit()
    }
    
    // 手写开始，第一笔
    func didHwBegin()
    {
        self.mComposingText = nil
    }

    // 手按下，开始一个笔画
    func didHwPenDown()
    {
        self.hwTimer?.invalidate()
    }
    
    // 手抬起，执行识别
    func didHwPenUp()
    {
        self.hwAssociateKey = nil
        
        self.mForwardingView.strokeAry.append(-1)
        self.mForwardingView.strokeAry.append(-1)

        self.mBannerCmd.hide()
        
        self.createSmallCand()
        let cand = self.engine.hwRecognize(self.mForwardingView.strokeAry);
        self.mBannerCand?.updateHwCands(cand)
        self.mBannerCand?.show()
        showHwQuery(cand.substring(with: NSRange(location: 0, length: 1)) as NSString);
        
        if true
        {
            let hz = cand.substring(with: NSRange(location: 0, length: 1))
            
            if self.mComposingText != nil
            {
                // 预先有上屏，就先回退一个符号
                self.deleteBackward()
            }
            if Globals.cnOutConv == 0   // 不转换
            {
                self.mComposingText = hz;
                self.out(self.mComposingText!, sendCand: false)
            }
            else if Globals.cnOutConv == 1   // 繁体
            {
                self.mComposingText = gbk2Big5(hz as NSString);
                self.out(self.mComposingText!, sendCand: false)
            }
            else
            {
                self.mComposingText = nil
            }
        }
        self.mForwardingView.strokeAry.removeLast() // 去除 -1
        self.mForwardingView.strokeAry.removeLast() // 去除 -1

        self.hwTimer?.invalidate()
        self.hwTimer = nil
        self.hwTimer = Timer.scheduledTimer(timeInterval: (TimeInterval(Globals.hwTimeOut)/1000.0), target: self, selector: Selector("didHwTimeup"), userInfo: nil, repeats: false)
    }

    // 手写超时，自动上屏或清屏
    @objc func didHwTimeup()
    {
        self.mForwardingView.reset()
    }
}


class Catboard: KeyboardViewController
{
    var lastKey: Key?
    var keyRepeat: Int = 0
    var keyInterval: TimeInterval = 0
  
    override func keyPressed(_ key: Key, isSwipeDown: Bool)
    {
        if self.lastKey == key && ((getSysTicks() - self.keyInterval) < 0.6)
        {
            self.keyRepeat += 1
        }
        else
        {
            self.keyRepeat = 0
        }
        self.MyKeyPressed(key, repeatCount: self.keyRepeat, isSwipeDown: isSwipeDown)
        self.lastKey = key
        self.keyInterval = getSysTicks()
    }

    deinit
    {
        MyLog("------->>Catboard --> deinit")
        
        self.lastKey = nil
    }
}

/*
func randomCat() -> String
{
    let cats = "🐱😺😸😹😽😻😿😾😼🙀"
    
    let numCats = countElements(cats)
    let randomCat = arc4random() % UInt32(numCats)
    
    let index = advance(cats.startIndex, Int(randomCat))
    let character = cats[index]
    
    return String(character)
}
**/