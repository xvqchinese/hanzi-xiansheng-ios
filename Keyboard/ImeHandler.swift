//
//  ImeHandler.swift
//  TastyImitationKeyboard
//
//  Created by mac on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation
import MapKit

extension KeyboardViewController
{   
    func modeChangeCommonEng()
    {
        if self.currentPage == KbPage.M_En26
        {
            self.currentPage = KbPage.M_Abc
        }
        else
        {
            self.currentPage = KbPage.M_Abc9
        }
    }
    
    func modeChangeSmartEng()
    {
        if self.currentPage == KbPage.M_Abc
        {
            self.currentPage = KbPage.M_En26
        }
        else
        {
            self.currentPage = KbPage.M_En9
        }
    }
    
    func modeChange2T9_123()
    {
        self.lastPage = self.currentPage
        self.currentPage = KbPage.M_123
    }
    
    // 弹出符号窗口
    func modeChangePopupSymb()
    {
        self.hideKeyboard()
        self.mBannerCand?.hide()
        self.createBigCand()
        
        self.mBigCandPanel?.Reset()
        self.mBigCandPanel?.updateForSymbol(self.currentPage)
        self.mBigCandPanel?.show()
    }
    
    func modeChange2123_EN()
    {
        self.currentPage = KbPage.M_123_EN
    }
    func modeChange2123_CN()
    {
        self.currentPage = KbPage.M_123_CN
    }
    func modeChange2Eng()
    {
        //self.currentPage = KbPage.M_Abc
        self.currentPage = Globals.prefs.integer(forKey: "defaultEnIM")//KbPage.M_Abc
    }
    func modeChange2Sym_CN()
    {
        self.currentPage = KbPage.M_Sym_CN
    }
    func modeChange2Sym_EN()
    {
        self.currentPage = KbPage.M_Sym_EN
    }
    func modeChange2Chn()
    {
        self.currentPage = Globals.prefs.integer(forKey: "defaultCnIM")//KbPage.M_Chn
    }
    func modeReturnChn()
    {
        self.currentPage = Globals.prefs.integer(forKey: "defaultCnIM")//KbPage.M_Chn
    }
    func modeReturnEng()
    {
        self.currentPage = Globals.prefs.integer(forKey: "defaultEnIM")//KbPage.M_Abc
    }
    
    func modeReturnAuto()
    {
        self.currentPage = self.lastPage
    }
    
    private func showSetting()
    {
        if self.mSettingPanel == nil
        {
            self.mSettingPanel = self.view_setting()
            self.view.addSubview(self.mSettingPanel!)
        }
        if self.mSettingPanel != nil
        {
            self.mSettingPanel!.show()
        }
    }

    func closeSetting()
    {
        if self.mSettingPanel != nil
        {
            self.mSettingPanel!.hide()
            self.mSettingPanel!.removeFromSuperview()
            self.mSettingPanel!.End()
            self.mSettingPanel = nil
        }
    }
    
    func doSetting()
    {
        if (self.mSettingPanel != nil && self.mSettingPanel!.showing())
        {
            // 隐藏设置
            self.closeSetting()
            self.showKeyboard()
        }
        else
        {
            // 显示设置
            self.showSetting()
            self.hideKeyboard()
            self.closeSelectKB()
        }
    }
    
    private func showPhrase()
    {
        if self.mPhrsPanel == nil
        {
            self.mPhrsPanel = self.view_phrs()
            self.view.addSubview(self.mPhrsPanel!)
        }
        if self.mPhrsPanel != nil
        {
            self.mPhrsPanel!.show()
        }
    }
    
    func closePhrase()
    {
        if self.mPhrsPanel != nil
        {
            self.mPhrsPanel!.hide()
            self.mPhrsPanel!.removeFromSuperview()
            self.mPhrsPanel!.End()
            self.mPhrsPanel = nil
        }
    }
    
    // 显示常用短语
    func doPhrase()
    {
        if self.mPhrsPanel != nil && self.mPhrsPanel!.showing()
        {
            self.closePhrase()
            //self.showKeyboard()
        }
        else
        {
            self.showPhrase()
            self.closeSetting()
            self.closeSelectKB()
            //self.hideKeyboard()
        }
    }
    
    func doSelectPhr(_ sender: UIButton)
    {
        self.out(sender.titleLabel!.text!, sendCand: true)
        self.doPhrase()
    }
    
    // 移动光标
    func doCaret()
    {
        //caretMoveL()
    }
    
    func caretMoveR()
    {
        if let proxy = self.textDocumentProxy as UITextDocumentProxy?
        {
            proxy.adjustTextPosition(byCharacterOffset: 1)
        }
    }
    
    func caretMoveL()
    {
        if let proxy = self.textDocumentProxy as UITextDocumentProxy?
        {
            proxy.adjustTextPosition(byCharacterOffset: -1)
        }
    }
    
    
    private func showSelectKB()
    {
        if self.mSelectKB == nil
        {
            self.mSelectKB = self.view_selectKB()
            self.view.addSubview(self.mSelectKB!)
        }
        if (self.mSelectKB != nil)
        {
            self.mSelectKB!.show(self)
        }
    }
    func closeSelectKB()
    {
        if (self.mSelectKB != nil)
        {
            self.mSelectKB!.hide()
            self.mSelectKB!.removeFromSuperview()
            self.mSelectKB = nil
        }
    }
    
    func doSwitch()
    {
        if (self.mSelectKB != nil && self.mSelectKB!.showing())
        {
            self.closeSelectKB()
            self.showKeyboard()
        }
        else
        {
            self.showSelectKB()
            self.hideKeyboard()
            self.closeSetting()
        }
    }
    
    func doSelectKB(_ sender: UIView)
    {
        let defEn = Globals.prefs.integer(forKey: "defaultEnIM")
        doSwitch()
        if sender.tag == KbPage.M_En9 && (defEn == KbPage.M_Abc9 || defEn == KbPage.M_Abc)
        {
            self.currentPage = KbPage.M_Abc9
        }
        else if sender.tag == KbPage.M_En26 && (defEn == KbPage.M_Abc9 || defEn == KbPage.M_Abc)
        {
            self.currentPage = KbPage.M_Abc
        }
        else
        {
            self.currentPage = sender.tag
        }
    }
    
    private func showSmile()
    {
        if self.mSmilePanel == nil
        {
            self.mSmilePanel = self.view_smile()
            self.mSmilePanel?.delegate = self
            self.view.addSubview(self.mSmilePanel!)
        }
        if self.mSmilePanel != nil
        {
            self.mSmilePanel!.show()
        }
    }
    
    func closeSmile()
    {
        if self.mSmilePanel != nil
        {
            self.mSmilePanel!.hide()
            self.mSmilePanel!.removeFromSuperview()
            self.mSmilePanel!.End()
            self.mSmilePanel = nil
        }
    }
    
    
    // 显示表情
    func doSmile()
    {
        if self.mSmilePanel != nil && self.mSmilePanel!.showing()
        {
            self.closeSmile()
            self.showKeyboard()
        }
        else
        {
            self.showSmile()
            self.closeSetting()
            self.closeSelectKB()
            self.hideKeyboard()
        }
    }
    
    // 定位成功
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let newLoca = locations.last
        {
            CLGeocoder().reverseGeocodeLocation(newLoca, completionHandler: { (pms, err) -> Void in
                if let placemark = pms?.last
                {
                    manager.stopUpdatingLocation()
                    if self.mLocation != nil
                    {
                        self.mLocation?.stopUpdatingLocation()
                        self.mLocation = nil
                        var txt: String = ""
                        
                        if placemark.administrativeArea != nil
                        {
                            txt += placemark.administrativeArea!
                        }
                        if placemark.locality != nil
                        {
                            txt += placemark.locality!
                        }
                        if placemark.subLocality != nil
                        {
                            txt += placemark.subLocality!
                        }
                        if placemark.thoroughfare != nil
                        {
                            txt += placemark.thoroughfare!
                        }
                        if placemark.subThoroughfare != nil
                        {
                            txt += placemark.subThoroughfare!
                        }
                        self.out(txt, sendCand: false)
                    }
                }
            })
        }
        
    }
    
    // 取当前位置文本
    func doLocaltion()
    {
        if self.mLocation == nil
        {
            self.mLocation = CLLocationManager()
            self.mLocation?.delegate = self
        }
        
        if self.mLocation != nil
        {
            if self.mLocation!.responds(to: Selector("requestAlwaysAuthorization"))
            {
                self.mLocation!.requestAlwaysAuthorization()
            }
            self.mLocation!.desiredAccuracy = kCLLocationAccuracyBest
            self.mLocation!.startUpdatingLocation()
        }
    }
    
    //
    func doSettingTest()
    {
        let appinfo: NSDictionary = (Bundle.main.infoDictionary ?? [:]) as NSDictionary
        let Identifier: NSString = appinfo.object(forKey: "CFBundleIdentifier") as! NSString
        NSLog("Identifier = \(Identifier)")
        
        /**
        self.engine.SendKey(EST.SPKEY_O, param: 0)
        let count = self.engine.CandCount()
        var i : Int32 = 0
        
        for i = 0; i < count; i += 1
        {
            self.engine.GetCand(i)
        }
        &***/
        
        
        // 下载
        //var data: Data! = try? Data(contentsOf: URL(fileURLWithPath: "http://www.baidu.com")!)
    
        // 本地
        //let mb = Bundle.main
        //let mainPath = mb.resourcePath?.appendingPathComponent("xfpy.data")
        //let assePath = mb.resourcePath?.appendingPathComponent("xfsk.data")
        /*
        var dataAsse: Data = NSData.dataWithContentsOfFile(assePath!, options: NSDataReadingOptions.DataReadingMappedAlways, error: nil)
        var dataMain: Data = NSData.dataWithContentsOfFile(mainPath!, options: NSDataReadingOptions.DataReadingMappedAlways, error: nil)
        */
        //UIApplication.
        
        //UIKeyInput.
        
        //self.inputView.backgroundColor = UIColor.clear
        //self.view.backgroundColor = UIColor.clear
        //self.view.superview?.backgroundColor = UIColor.clear
        //self.mForwardingView.backgroundColor = UIColor.clear
        
        //self.keyboardHeight = self.keyboardHeight - 10
        
        if let textDocumentProxy = self.textDocumentProxy as UIKeyInput?
        {
            let fm: FileManager = FileManager.default
            let containerURL = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")
            let fileURL = (containerURL ?? fm.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("eLog.txt")
            
            let tt = "logs, test !"
            
            do {
                try tt.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            }
            
            let ss: NSString = try! String(contentsOf: fileURL, encoding: String.Encoding.utf8) as NSString
            textDocumentProxy.insertText(ss as String)
            
            //let ret = engine.InitEngine(dataMain, asse: dataAsse, kbType: EST.KBT_QWERTY, imMode: EST.IDouble.piNYIN, lang: EST.SL_Chinese)
            
            //engine.SendKey(EST.SPKEY_W)
            //engine.SendKey(EST.SPKEY_O)
            //textDocumentProxy.insertText(String(count))
            //engine.Select(0)
            //textDocumentProxy.insertText(assePath!)
            //textDocumentProxy.insertText(String(data: data, encoding: NSASCIIStringEncoding))
            //textDocumentProxy.insertText(String(dataAsse.length))
            //textDocumentProxy.insertText("\n")
            //textDocumentProxy.insertText(String(dataMain.length))
            //textDocumentProxy.insertText("\n")
            //textDocumentProxy.insertText(String(engine.CandCount()))
            //textDocumentProxy.insertText(engine.GetCand(0))
            //textDocumentProxy.insertText("\n")
            
            /*
            var ss : String = "a"
            let bb: NSString = ss
            textDocumentProxy.insertText(String(bb.character(at: 0)))*/
            
            //textDocumentProxy.insertText(String(data.bytes.memory))
            //textDocumentProxy.insertText(paths[0].appendingPathComponent("asse.data"))
            //textDocumentProxy.insertText(path!)
        }
        
        /*
        let alert = UIAlertView()
        alert.title = "读文件"
        alert.delegate = self
        alert.message = "OK"
        alert.addButtonWithTitle("OK")
        alert.show()
        */
        //UIApplication.shared.openURL(NSURL.URLWithString("ldime://open_setting"))
    }
}
