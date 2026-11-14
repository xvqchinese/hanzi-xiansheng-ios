//
//  TranRootView.swift
//  DWKeyboard
//
//  Created by Aliang on 16/6/23.
//  Copyright © 2016年 Apple. All rights reserved.
//

import Foundation
import UIKit


class TranRootController: UIViewController, SINavigationMenuDelegate, UITextViewDelegate, BDRecognizerViewDelegate, BDRecognizerOutDelegate {
    
    let menuNames = [Lang("中文 » 英语"),
        Lang("英语 » 中文"),
        Lang("中文 » 日语"),
        Lang("日语 » 中文"),
        Lang("中文 » 韩语"),
        Lang("韩语 » 中文"),
        Lang("中文 » 法语"),
        Lang("法语 » 中文")]
    let froms = ["zh", "en", "zh", "jp", "zh", "kor", "zh", "fra"]
    let tos   = ["en", "zh", "jp", "zh", "kor", "zh", "fra", "zh"]
    
    var prefs = UserDefaults.standard
    var menuView: SINavigationMenuView!
    var inputTxt: PlaceholderTextView!
    var inputAre: UIView!
    var toolBar: UIToolbar!
    var outView: UITextView!
    var clearBtn: UIButton!
    var copyBtn: UIButton!
    var playSoundBtn: UIButton!
    var voiceBtn: UIButton!
    
    var bdParam: BDRecognizerViewParamsObject? = nil
    var recognizerViewController: BDRecognizerViewController? = nil
    var customVoiceView: BDVRCustomRecognitonViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefs.register(defaults: [
            "tranLang" : 0,
            ])
        
        //self.hidesBottomBarWhenPushed = false
        self.navigationItem.title = Lang("翻译")
        // 顶栏统一白底黑字（否则按钮为白色，看不见）
        if #available(iOS 13.0, *) {
            let ap = UINavigationBarAppearance()
            ap.configureWithOpaqueBackground()
            ap.backgroundColor = UIColor.white
            ap.titleTextAttributes = [.foregroundColor: UIColor.black]
            ap.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = ap
            self.navigationController?.navigationBar.scrollEdgeAppearance = ap
            self.navigationController?.navigationBar.compactAppearance = ap
            self.navigationController?.navigationBar.tintColor = UIColor.black
        } else {
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }

        // 下拉菜单
        if (true)
        {
            let frame = CGRect(x: 0.0, y: 0.0, width: self.navigationController!.navigationBar.bounds.size.width, height: self.navigationController!.navigationBar.bounds.size.height)
            self.menuView = SINavigationMenuView(frame: frame, title: menuNames[prefs.integer(forKey: "tranLang")])
            self.menuView.displayMenu(in: self.navigationController!.view)
            self.menuView.items = menuNames
            self.menuView.delegate = self
            self.navigationItem.titleView = self.menuView
        }
        
        // 键盘上方工具条
        if (true)
        {
            let frameT = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45)
            self.toolBar = UIToolbar(frame: frameT)
            self.toolBar.barStyle = UIBarStyle.default;
            self.toolBar.tintColor = UIColor(red: 0.1, green: 0.45, blue: 0.85, alpha: 1.0)
            self.toolBar.backgroundColor = UIColor.white
            let btn1 = UIBarButtonItem(title: Lang("清空"), style: UIBarButtonItem.Style.plain, target: self, action: Selector("doClear"))
            let btn2 = UIBarButtonItem(title: Lang("取消"), style: UIBarButtonItem.Style.plain, target: self, action: Selector("doCancel"))
            let btn3 = UIBarButtonItem(title: Lang("翻译"), style: UIBarButtonItem.Style.plain, target: self, action: Selector("doTran"))
            
            let paddingBtn1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
            self.toolBar.items = [btn1, paddingBtn1, btn2, paddingBtn1, btn3]
        }
        
        // 输入框
        if (true)
        {
            let frame1 = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height/7*3)
            self.inputAre = UIView(frame: frame1)
            self.inputAre.backgroundColor = UIColor.white
            self.inputAre.isUserInteractionEnabled = true
            self.view.addSubview(self.inputAre)
            
            let frame2 = CGRect(x: 10, y: 10, width: self.inputAre.bounds.size.width-20, height: frame1.size.height - 20)
            self.inputTxt = PlaceholderTextView(frame: frame2)
            self.inputTxt.backgroundColor = UIColor.clear
            self.inputTxt.delegate = self
            self.inputTxt.placeholder = Lang("请输入需要翻译的内容...")
            self.inputTxt.font = UIFont.systemFont(ofSize: 16)
            self.inputTxt.textColor = UIColor.black
            self.inputTxt.textAlignment = .left
            self.inputTxt.isEditable = true
            self.inputTxt.layer.cornerRadius = 4
            self.inputTxt.layer.borderColor = UIColor.clear.cgColor
            self.inputTxt.layer.borderWidth = 0
            self.inputTxt.inputAccessoryView = self.toolBar
            self.inputAre.addSubview(self.inputTxt)
        }
        
        // 结果显示区
        if (true)
        {
            let y = self.inputAre.bounds.origin.y + self.inputAre.bounds.height + 10
            let h = self.view.bounds.size.height - self.inputAre.bounds.height - 10 - 49/*tabbar高度*/
            
            let frame1 = CGRect(x: self.view.bounds.origin.x, y: y, width: self.view.bounds.size.width, height: h)
            self.outView = UITextView(frame: frame1)
            self.outView.backgroundColor = UIColor.clear
            self.outView.font = UIFont.systemFont(ofSize: 16)
            self.outView.isEditable = false
            self.view.addSubview(self.outView)
        }
        
        // 结果工具：复制
        if (true)
        {
            self.clearBtn = UIButton(frame: CGRect(x: self.inputAre.bounds.width - 40, y: self.inputAre.bounds.height - 40, width: 40, height: 40))
            self.clearBtn.setImage(UIImage(named: "tabbar_clear"), for: .normal)
            self.clearBtn.setImage(loadColorIcon("tabbar_clear", color: UIColor.blue), for: .highlighted)
            self.clearBtn.backgroundColor = UIColor.clear
            self.clearBtn.addTarget(self, action: Selector("doClear"), for: UIControl.Event.touchUpInside)
            self.clearBtn.layer.zPosition = 100;
            //self.clearBtn.sizeToFit()
            self.voiceBtn = UIButton(frame: CGRect(x: self.inputAre.bounds.width - 90, y: self.inputAre.bounds.height - 40, width: 40, height: 40))
            self.voiceBtn.setImage(UIImage(named: "tabbar_microphone"), for: .normal)
            self.voiceBtn.setImage(loadColorIcon("tabbar_microphone", color: UIColor.blue), for: .highlighted)
            self.voiceBtn.backgroundColor = UIColor.clear
            self.voiceBtn.addTarget(self, action: Selector("onMicrophone"), for: UIControl.Event.touchUpInside)
            self.voiceBtn.layer.zPosition = 100;

            self.copyBtn = UIButton(frame: CGRect(x: self.outView.bounds.width - 50, y: self.outView.bounds.height - 50, width: 50, height: 50))
            self.copyBtn.setImage(UIImage(named: "tabbar_copy"), for: .normal)
            self.copyBtn.setImage(loadColorIcon("tabbar_copy", color: UIColor.blue), for: .highlighted)
            self.copyBtn.backgroundColor = UIColor.clear
            self.copyBtn.addTarget(self, action: Selector("doCopy"), for: UIControl.Event.touchUpInside)
            self.copyBtn.layer.zPosition = 100;
            //self.copyBtn.sizeToFit()

            self.playSoundBtn = UIButton(frame: CGRect(x: self.outView.bounds.width - 50, y: self.outView.bounds.height - 50, width: 50, height: 50))
            self.playSoundBtn.setImage(UIImage(named: "tabbar_playVoice"), for: .normal)
            self.playSoundBtn.setImage(loadColorIcon("tabbar_playVoice", color: UIColor.blue), for: .highlighted)
            self.playSoundBtn.backgroundColor = UIColor.clear
            self.playSoundBtn.addTarget(self, action: Selector("playVoice"), for: UIControl.Event.touchUpInside)
            self.playSoundBtn.layer.zPosition = 100;
            //self.soundBtn.sizeToFit()
            
            self.inputAre.addSubview(self.clearBtn)
            self.inputAre.addSubview(self.voiceBtn)
            self.outView.addSubview(self.copyBtn)
            //self.outView.addSubview(self.soundBtn)
        }
        
        let index = prefs.integer(forKey: "tranLang")
        if self.froms[Int(index)] == "zh"
        {
            self.voiceBtn.isHidden = false
        }
        else
        {
            self.voiceBtn.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.hidesBottomBarWhenPushed = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    func didSelectItem(at index: UInt) {
        
        prefs.set(Int(index), forKey: "tranLang")
        if self.froms[Int(index)] == "zh"
        {
            self.voiceBtn.isHidden = false
        }
        else
        {
            self.voiceBtn.isHidden = true
        }
    }
    
    func textViewDidChange(textView: UITextView)
    {
    }
    
    @objc func onMicrophone()
    {
        self.customVoiceView = nil
        self.customVoiceView = BDVRCustomRecognitonViewController(nibName: nil, bundle: nil)
        self.customVoiceView!.delegate = self
        
        BDVoiceRecognitionClient.sharedInstance().setApiKey("LAdtPcao8U8T6Vn7eKwwnjtL", withSecretKey: "a529e2f82826adb4b054e14f7f0f6e4f")
        BDVoiceRecognitionClient.sharedInstance().setPropertyList([20000])
        BDVoiceRecognitionClient.sharedInstance().setCityID(1)
        BDVoiceRecognitionClient.sharedInstance().setConfig("nlu", withFlag: false)
        BDVoiceRecognitionClient.sharedInstance().setLanguage(Int32(0))
        BDVoiceRecognitionClient.sharedInstance().cancelListenCurrentDBLevelMeter()
        BDVoiceRecognitionClient.sharedInstance().setPlayTone(Int32(1), isPlay: false)
        BDVoiceRecognitionClient.sharedInstance().setPlayTone(Int32(2), isPlay: false)
        let appCode = "8310051"
        let datFilePath  = Bundle.main.path(forResource: "s_1", ofType: "")
        let lmDatFilePath = Bundle.main.path(forResource: "s_2_InputMethod", ofType: "")
        let recogGrammSlot = ["$song_CORE":"中国", "$app_CORE":"孔子"]
        let ret = BDVoiceRecognitionClient.sharedInstance().loadOfflineEngine(appCode, license: nil, datFile: datFilePath, lmDatFile: lmDatFilePath, grammSlot: recogGrammSlot)
        if ret != 0
        {
            return
        }
        else
        {
            UIApplication.shared.keyWindow!.addSubview(self.customVoiceView!.view)
        }
    }
    
    // 百度自带 ui
    private func voice_ui()
    {
        self.inputTxt.endEditing(true)
        
        /**
        self.searchBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VoiceInputViewController(), animated: true)
        **/
        if self.recognizerViewController == nil
        {
            self.recognizerViewController = BDRecognizerViewController(origin: CGPoint(x: 9, y: 128), with: BDTheme.lightBlue())
            self.bdParam = BDRecognizerViewParamsObject()
        }
        
        // 开发者信息，必须修改API_KEY和SECRET_KEY为在百度开发者平台申请得到的值，否则示例不能工作
        self.bdParam!.apiKey = "LAdtPcao8U8T6Vn7eKwwnjtL"
        self.bdParam!.secretKey = "a529e2f82826adb4b054e14f7f0f6e4f"
        // 设置是否需要语义理解，只在搜索模式有效
        self.bdParam!.isNeedNLU = false
        // 设置识别语言
        self.bdParam!.language = BDVoiceRecognitionLanguageChinese
        // 设置识别模式，分为搜索和输入
        self.bdParam!.recogPropList = [20000] // EVoiceRecognitionPropertyInput
        // 设置城市ID，当识别属性包含EVoiceRecognitionPropertyMap时有效
        self.bdParam!.cityID = 1
        // 设置显示效果，是否开启连续上屏
        self.bdParam!.resultShowMode = BDRecognizerResultShowModeContinuousShow
        // 设置提示音开关，是否打开，默认打开
        self.bdParam!.recordPlayTones = EBDRecognizerPlayTonesRecordPlay;
        
        self.bdParam!.isShowTipAfter3sSilence = false
        self.bdParam!.isShowHelpButtonWhenSilence = false
        self.bdParam!.tipsTitle = Lang("请说出你要查找的词组");
        self.bdParam!.tipsList = ["中国", "孔子"];
        
        self.bdParam!.appCode = "8310051"
        self.bdParam!.licenseFilePath = Bundle.main.path(forResource: "bdasr_temp_license", ofType: "dat")
        self.bdParam!.datFilePath = Bundle.main.path(forResource: "s_1", ofType: "")
        self.bdParam!.lmDatFilePath = Bundle.main.path(forResource: "s_2_InputMethod", ofType: "")
        self.bdParam!.recogGrammSlot = ["$name_CORE":"张三\n李四\n", "$song_CORE":"小苹果\n朋友\n"]
        
        self.recognizerViewController!.delegate = self
        self.recognizerViewController!.start(withParams: self.bdParam!)
    }
    
    // 不带百度 UI 的方法
    func voiceRecognitionResultOut(_ results: String!)
    {
        self.doClear()
        self.inputTxt.insertText(results)
        self.doTran()
    }
    
    // 语音识别结果
    func onEnd(withViews aBDRecognizerViewController: BDRecognizerViewController!, withResults aResults: [Any]!)
    {
        let rets = NSMutableString()
        for item in aResults
        {
            let result: NSArray = item as! NSArray
            let dict : NSDictionary = result.object(at: 0) as! NSDictionary
            rets.append(dict.allKeys[0] as! String)
        }
        let txt = rets as String
        self.doClear()
        self.inputTxt.insertText(txt)
        self.doTran()
    }
    
    @objc func playVoice()
    {
        
    }
    
    @objc func doCopy()
    {
        if self.outView.text.count > 0
        {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = self.outView.text
            
            ocUtils.showMessage(Lang("翻译结果已复制成功！"))
        }
    }
    
    @objc func doClear()
    {
        self.inputTxt.selectAll(nil)
        self.inputTxt.deleteBackward()
    }
    
    @objc func doCancel()
    {
        self.inputTxt.endEditing(true)
    }
    
    @objc func doTran()
    {
        self.inputTxt.endEditing(true)
        
        DispatchQueue.global().async {
            
            //这里写需要大量时间的代码
            //println("这里写需要大量时间的代码")
            let ret = self.baiduTran()
            
            DispatchQueue.main.async {
                
                //这里返回主线程，写需要主线程执行的代码
                //println("这里返回主线程，写需要主线程执行的代码")
                self.outView.text = ret
            }
        }
    }
    
    func baiduTran() -> String
    {
        if let str = self.inputTxt.text
        {
            if str.count > 0
            {
                let from = self.froms[prefs.integer(forKey: "tranLang")]
                let to = self.tos[prefs.integer(forKey: "tranLang")]
                let q = str
                let appid = "20160624000023932"
                let pw = "IyhbkLomuFDSU6izeVmd"
                let salt = 100000 + (arc4random() % 100000)
                let sign = md5String(appid + q + "\(salt)" + pw)
                
                let qq = escape(q)
                // 百度直连延续原样（2026-10-29 实测 key 仍有效），端点升级为 https
                let u = "https://api.fanyi.baidu.com/api/trans/vip/translate?q=\(qq)&from=\(from)&to=\(to)&appid=\(appid)&salt=\(salt)&sign=\(sign)"
                
                let url: URL? = URL(string: u)
                let tranRet: Data! = try? Data(contentsOf: url!)
                if tranRet != nil
                {
                    if let json = try? JSONSerialization.jsonObject(with: tranRet, options: .allowFragments)
                    {
                        // 兼容格式: {"from":"en","to":"zh","trans_result":[{"src":"apple","dst":"\u82f9\u679c"}]}
                        if let dict = json as? NSDictionary
                        {
                            if let trans_result = dict.object(forKey: "trans_result") as? NSArray
                            {
                                if trans_result.count > 0
                                {
                                    if let dd: NSDictionary = trans_result[0] as? NSDictionary
                                    {
                                        if let dst = dd["dst"] as? String
                                        {
                                            MyLog(dst)
                                            return dst
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
}
