//
//  DictRootView.swift
//  DWKeyboard
//
//  Created by Aliang on 16/6/23.
//  Copyright © 2016年 Apple. All rights reserved.
//


import Foundation
import Speech
import AVFoundation
import UIKit
import WebKit
import GLKit
import AVKit
import CoreTelephony
import MobileCoreServices
import CFNetwork
// BDRecognizerViewDelegate
class DictRootController: UIViewController, UISearchBarDelegate, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource, BDRecognizerOutDelegate
{
    
    var prefs = UserDefaults.standard
    var searchBar: UISearchBar!
    var voiceBtn: UIBarButtonItem!
    var meBtn: UIBarButtonItem!
    var web: WKWebView!
    var showResult: WKWebView!
    var activityIndicatorView: UIActivityIndicatorView!
    var searchBarFrame1: CGRect!
    var fontSeg: UISegmentedControl!
    var backBtn: UIBarButtonItem!
    var dictFontIdx: Int = 1
    var historyTable: UITableView!
    var cancelBtn: UIButton!
    var historyAry: [String] = []
    let home_url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/dict/?os=ios&lang=\(Lang("lang"))")
    var errorView: ErrorView!
    var historyClear: UIButton!
    
    var bdParam: BDRecognizerViewParamsObject? = nil
    var recognizerViewController: BDRecognizerViewController? = nil
    var customVoiceView: BDVRCustomRecognitonViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = false
        self.navigationItem.title = Lang("鼎氏词典")
        
        if (true)
        {
            let mainViewBounds = self.navigationController!.view.bounds
            let navBottom = self.navigationController!.navigationBar.frame.maxY
            let w = min(mainViewBounds.width, UIScreen.main.bounds.width)
            self.searchBarFrame1 = CGRect(x: 8, y: navBottom + 4, width: w - 16, height: 36)
            self.searchBar = UISearchBar(frame: self.searchBarFrame1)
            
            let clearImg = imageWithColor(UIColor.clear, width: 1, height: 40)
            self.searchBar.delegate = self
            self.searchBar.backgroundImage = clearImg
            self.searchBar.showsCancelButton = false
            self.searchBar.barStyle = UIBarStyle.default
            self.searchBar.tintColor = UIColor.black
            self.searchBar.placeholder = Lang("请输入中文或英文进行查询")
            self.searchBar.isTranslucent = false
            self.searchBar.searchBarStyle = .minimal
            self.searchBar.barTintColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
            self.searchBar.tintColor = UIColor.black
            if let tf = self.searchBar.value(forKey: "searchField") as? UITextField
            {
                tf.backgroundColor = UIColor.white
                tf.textColor = UIColor.black
            }
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.searchBar.placeholder = Lang("请输入中文或英文进行查询")
            if let tf = self.searchBar.value(forKey: "searchField") as? UITextField
            {
                tf.attributedPlaceholder = NSAttributedString(string: Lang("请输入中文或英文进行查询"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController!.view.addSubview(self.searchBar)

            if let v = prefs.object(forKey: "dictFontSize") as? Int { self.dictFontIdx = max(0, min(2, v)) }
            self.fontSeg = UISegmentedControl(items: [Lang("小"), Lang("中"), Lang("大")])
            self.fontSeg.selectedSegmentIndex = self.dictFontIdx
            self.fontSeg.tintColor = UIColor.black
            let segY = self.searchBarFrame1.maxY + 4
            let segW: CGFloat = 132
            self.fontSeg.frame = CGRect(x: w - 8 - segW, y: segY, width: segW, height: 28)
            self.fontSeg.addTarget(self, action: Selector("onFontSeg"), for: .valueChanged)
            // 大中小只用于键盘占屏比例，词典页不再显示
            self.fontSeg.isHidden = true
        }
        if (true)
        {
            self.voiceBtn = UIBarButtonItem(image: UIImage(named: "tabbar_microphone"), style: UIBarButtonItem.Style.plain, target: self, action: Selector("onVoiceBtn"))
            self.meBtn = UIBarButtonItem(image: UIImage(named: "tabbar_me"), style: UIBarButtonItem.Style.plain, target: self, action: Selector("onMeInfoBtn"))
            
            self.navigationItem.setRightBarButton(self.voiceBtn, animated: true)
            self.backBtn = UIBarButtonItem(title: Lang("返回"), style: .plain, target: self, action: Selector("onBackBtn"))
            self.navigationItem.setLeftBarButtonItems([self.backBtn, self.meBtn], animated: true)
        }
        
        if (true)
        {
            self.cancelBtn = UIButton()
            self.cancelBtn.setTitle(Lang("取消  "), for: .normal)
            self.cancelBtn.setTitleColor(UIColor.black, for: .normal)
            self.cancelBtn.sizeToFit()
            self.cancelBtn.addTarget(self, action: Selector("endWorking"), for: .touchUpInside)
            self.cancelBtn.frame.origin.x = self.navigationController!.view.bounds.width - self.cancelBtn.frame.width
            self.cancelBtn.frame.origin.y = self.searchBar.frame.origin.y + (self.searchBar.frame.height - self.cancelBtn.frame.height) / 2
        }
        
        if (true)
        {
            let topInset: CGFloat = 72
            let tabH = self.tabBarController?.tabBar.frame.height ?? 0
            self.web = WKWebView(frame: CGRect(x: 0, y: topInset, width: self.view.frame.width, height: max(0, self.view.frame.height - topInset - tabH)))
            self.web.navigationDelegate = self
            self.view.addSubview(self.web!)
            self.web.load(URLRequest(url: self.home_url!))
        }
        
        if (true)
        {
            let app = UIApplication.shared
            let y = self.view.frame.origin.y + self.navigationController!.navigationBar.bounds.size.height + app.statusBarFrame.height + 72
            let h = self.view.frame.height - self.navigationController!.navigationBar.bounds.size.height - app.statusBarFrame.height - self.tabBarController!.tabBar.frame.height
            self.showResult = WKWebView(frame: CGRect(x: self.view.frame.origin.x, y: y, width: self.view.frame.size.width, height: h))
            self.showResult.navigationDelegate = self
        }
        self.setupRefresh()
        
        if (true)
        {
            let app = UIApplication.shared
            let y = self.view.frame.origin.y + self.navigationController!.navigationBar.bounds.size.height + app.statusBarFrame.height
            let h = self.view.frame.height - self.navigationController!.navigationBar.bounds.size.height - app.statusBarFrame.height - self.tabBarController!.tabBar.frame.height
            self.historyTable = UITableView(frame: CGRect(x: self.view.frame.origin.x, y: y, width: self.view.frame.size.width, height: h))
            self.historyTable.delegate = self
            self.historyTable.dataSource = self
            self.historyTable.backgroundColor = UIColor.white
            self.historyTable.register(UITableViewCell.self, forCellReuseIdentifier: "historyTableViewCell")

            if let ls = (prefs.object(forKey: "searchHistory") as? [String])
            {
                self.historyAry = ls
            }
            
            self.historyClear = UIButton()
            self.historyClear.setTitle(Lang("  清空历史  "), for: .normal)
            self.historyClear.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            self.historyClear.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            self.historyClear.addTarget(self, action: Selector("onClearHistory"), for: .touchUpInside)
            self.historyClear.sizeToFit()
            self.historyClear.frame.origin.x = self.historyTable.frame.width - self.historyClear.frame.width - 10
            self.historyClear.frame.origin.y = 10
            self.historyClear.layer.zPosition = 100
            self.historyClear.layer.cornerRadius = 5
            self.historyTable.addSubview(self.historyClear)
        }
        
        if (true)
        {
            self.errorView = ErrorView(frame: CGRect(x: 20, y: self.view.frame.height/2, width: self.view.frame.width-40, height: 80))
            self.errorView.layer.zPosition = 200
        }

        if (true)
        {
            // wait...
            self.activityIndicatorView = UIActivityIndicatorView(style: .white)
            self.activityIndicatorView.frame = CGRect(x: self.view.frame.size.width/2 - 50, y: self.view.frame.size.height/2 - 30, width: 100, height: 60)
            self.activityIndicatorView.hidesWhenStopped = true
            self.activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.activityIndicatorView.color = UIColor.white
            self.activityIndicatorView.layer.cornerRadius = 5.0
            self.activityIndicatorView.layer.zPosition = 100
            self.view.addSubview(self.activityIndicatorView)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.hidesBottomBarWhenPushed = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBar.isHidden = false
        if self.cancelBtn.superview != nil
        {
            self.cancelBtn.isHidden = false
        }
        self.searchBar.text = ""
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    
    // 下拉刷新
    func setupRefresh()
    {
        if let web = self.web
        {
            web.scrollView.addHeaderWithCallback({
                web.load(URLRequest(url: self.home_url!))
                web.scrollView.headerEndRefreshing()
            })
        }
        
        if(true)
        {
            self.showResult.scrollView.addHeaderWithCallback({ () -> Void in
                self.showResult.reload()
                self.showResult.scrollView.headerEndRefreshing()
            })
        }
    }
    
    @objc func onClearHistory()
    {
        self.historyAry.removeAll()
        self.historyTable.reloadData()
        self.prefs.set(self.historyAry, forKey: "searchHistory")
    }
    
    func hideError()
    {
        self.errorView.removeFromSuperview()
    }
    
    func showError(_ str: String)
    {
        self.errorView.setErrorMsg(msg: str)
        self.view.addSubview(self.errorView);
    }

    @objc func onMeInfoBtn()
    {
        self.searchBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(UserInfoViewController(), animated: true)
    }
    
    // MARK: 词典页语音（改 iOS 原生识别，去掉百度 SDK 依赖）
    var spRec: SFSpeechRecognizer?
    var spReq: SFSpeechAudioBufferRecognitionRequest?
    var spTask: SFSpeechRecognitionTask?
    var spEngine: AVAudioEngine?
    var spListening: Bool = false
    var spVoiceTip: UILabel?

    @objc func onVoiceBtn()
    {
        if spListening { stopDictVoice(); return }
        let auth = SFSpeechRecognizer.requestAuthorization { _ in }
        _ = auth
        AVAudioSession.sharedInstance().requestRecordPermission { ok in
            DispatchQueue.main.async {
                if !ok { self.dictVoiceTipShow("未授权麦克风，请到 设置→汉字先生 打开"); return }
                self.startDictVoice()
            }
        }
    }

    func dictVoiceTipShow(_ t: String)
    {
        spVoiceTip?.removeFromSuperview()
        let lab = UILabel()
        lab.text = t
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = .white
        lab.backgroundColor = UIColor(white: 0.15, alpha: 0.92)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.frame = CGRect(x: 12, y: 96, width: self.view.bounds.width - 24, height: 40)
        lab.layer.cornerRadius = 8
        lab.clipsToBounds = true
        self.view.addSubview(lab)
        self.spVoiceTip = lab
    }

    func startDictVoice()
    {
        stopDictVoice()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true, options: [])
        } catch {
            dictVoiceTipShow("音频会话启动失败")
            return
        }
        spRec = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        guard let rec = spRec, rec.isAvailable else {
            dictVoiceTipShow("语音识别暂不可用，请稍后再试")
            return
        }
        spReq = SFSpeechAudioBufferRecognitionRequest()
        spReq?.shouldReportPartialResults = true
        if #available(iOS 13.0, *) { spReq?.requiresOnDeviceRecognition = false }
        let engine = AVAudioEngine()
        spEngine = engine
        let input = engine.inputNode
        let fmt = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: fmt) { buf, _ in
            self.spReq?.append(buf)
        }
        do {
            engine.prepare()
            try engine.start()
        } catch {
            dictVoiceTipShow("麦克风启动失败")
            stopDictVoice()
            return
        }
        spListening = true
        dictVoiceTipShow("请说普通话…")
        spTask = rec.recognitionTask(with: spReq!) { result, err in
            if let r = result {
                let t = r.bestTranscription.formattedString
                if !t.isEmpty {
                    DispatchQueue.main.async {
                        self.dictVoiceTipShow(t)
                        self.searchBar.text = t
                    }
                }
                if r.isFinal {
                    DispatchQueue.main.async {
                        self.stopDictVoice()
                        if self.searchBar.text?.isEmpty == false {
                            self.startWorking()
                            self.doSearch()
                        }
                    }
                }
            }
            if err != nil {
                DispatchQueue.main.async {
                    self.stopDictVoice()
                    if let t = self.searchBar.text, !t.isEmpty {
                        self.startWorking()
                        self.doSearch()
                    } else {
                        self.dictVoiceTipShow("没听清，请再说一次")
                    }
                }
            }
        }
        // 6 秒没有结果也收尾
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            if self.spListening { self.stopDictVoice() }
        }
    }

    func stopDictVoice()
    {
        spListening = false
        spTask?.cancel(); spTask = nil
        spReq?.endAudio(); spReq = nil
        if let e = spEngine {
            e.stop()
            e.inputNode.removeTap(onBus: 0)
        }
        spEngine = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        if let v = spVoiceTip {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { v.removeFromSuperview() }
        }
    }

    // 不带百度 UI 的方法
    func voiceRecognitionResultOut(_ results: String!)
    {
        let txt = results.replacingOccurrences(of: "。", with: "")
        self.searchBar.text = txt
        self.startWorking()
        self.doSearch()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        self.hideError()
        self.activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.activityIndicatorView.stopAnimating()
        self.applyFontTo(webView)
        if #available(iOS 14.0, *) { webView.pageZoom = 1.45 }
    }

    func dictFontPx() -> Int
    {
        let base: CGFloat = self.dictFontIdx == 0 ? 24 : (self.dictFontIdx == 1 ? 30 : 36)
        let scale = min(max(UIScreen.main.bounds.width / 390.0, 0.9), 1.25)
        return Int(base * scale)
    }

    @objc func onBackBtn()
    {
        if let nav = self.navigationController, nav.viewControllers.count > 1
        {
            nav.popViewController(animated: true)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func applyFontTo(_ webView: WKWebView)
    {
        let px = self.dictFontPx()
        let js = "(function(){var m=document.querySelector(\"meta[name=viewport]\");if(!m){m=document.createElement(\"meta\");m.setAttribute(\"name\",\"viewport\");document.head.appendChild(m);}m.setAttribute(\"content\",\"width=device-width, initial-scale=1.0, maximum-scale=1.0\");var s=document.createElement(\"style\");s.type=\"text/css\";s.innerHTML=\"body,p,div,span,td,li,dd,dt,section,article,blockquote,h1,h2,h3,h4,h5,font,a{font-size:__PX__px !important;line-height:1.55 !important;max-width:100% !important;overflow-wrap:break-word !important;word-break:break-word !important;white-space:normal !important;}img{max-width:100% !important;height:auto !important;}\";document.head.appendChild(s);})();"
        webView.evaluateJavaScript(js.replacingOccurrences(of: "__PX__", with: String(px), options: .literal, range: nil), completionHandler: nil)
    }

    @objc func onFontSeg()
    {
        self.dictFontIdx = self.fontSeg.selectedSegmentIndex
        prefs.set(self.dictFontIdx, forKey: "dictFontSize")
        if let w = self.web { self.applyFontTo(w) }
        if let r = self.showResult { self.applyFontTo(r) }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        self.activityIndicatorView.stopAnimating()
        
        self.showError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if navigationAction.navigationType == .linkActivated
        {
            self.activityIndicatorView.stopAnimating()
            self.searchBar.isHidden = true
            self.hidesBottomBarWhenPushed = true
            self.cancelBtn.isHidden = true
            
            if let urlStr = navigationAction.request.url?.absoluteString
            {
                if  webView == self.web!
                {
                    self.navigationController?.pushViewController(CommonWebView(url: urlStr, title:"", scalesPage: true), animated: true)
                }
                else if webView == self.showResult
                {
                    self.navigationController?.pushViewController(CommonWebView(url: urlStr, title:Lang("词条内容"), scalesPage: false), animated: true)
                }
            }
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.historyAry.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // 选择历史记录
        self.searchBar.text = self.historyAry[indexPath.row]
        self.doShowPhrItem()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil
        {
            // no value
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell") as UITableViewCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.default
            let label = UILabel()
            label.frame = CGRect(x: cell!.frame.height / 2, y: 0, width: 320, height: cell!.frame.height)
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = UIColor.black.withAlphaComponent(0.6)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            label.isUserInteractionEnabled = false
            label.text = self.historyAry[indexPath.row]
            label.tag = 1000
            cell!.contentView.addSubview(label)
        }
        else
        {
            let label:UILabel = cell!.contentView.viewWithTag(1000) as!  UILabel
            label.text = self.historyAry[indexPath.row]
        }
        
        return cell!
    }
    
    func startWorking()
    {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.navigationController!.view.addSubview(self.cancelBtn)
        self.cancelBtn.isHidden = false
        let w = self.searchBarFrame1.width+80 - self.cancelBtn.frame.width
        self.searchBar.frame = CGRect(x: self.searchBarFrame1.origin.x-40, y: self.searchBarFrame1.origin.y, width: w, height: self.searchBarFrame1.height)
        self.web?.removeFromSuperview()
        self.view.addSubview(self.historyTable)
    }
    
    // 结束查找
    @objc func endWorking()
    {
        self.activityIndicatorView.stopAnimating()
        self.cancelBtn.removeFromSuperview()
        self.searchBar.frame = self.searchBarFrame1
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        self.navigationItem.setLeftBarButton(self.meBtn, animated: true)
        self.navigationItem.setRightBarButton(self.voiceBtn, animated: true)
        self.historyTable.removeFromSuperview()
        self.showResult.removeFromSuperview()
        self.view.addSubview(self.web!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.startWorking()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.endWorking()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.count > 0
        {
            self.doSearch()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if (self.searchBar.text?.count ?? 0) > 0
        {
            for i in 0..<self.historyAry.count
            {
                if self.historyAry[i] == self.searchBar.text!
                {
                    self.historyAry.remove(at: i)
                    break
                }
            }

            if (true)
            {
                self.historyAry.insert(self.searchBar.text!, at: 0)
                self.historyTable.reloadData()
                self.prefs.set(self.historyAry, forKey: "searchHistory")
            }
            self.doShowPhrItem()
        }
    }
    
    func doShowPhrItem()
    {
        self.activityIndicatorView.stopAnimating()
        self.searchBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.cancelBtn.isHidden = true

        let key = escape(self.searchBar.text!)
        let url = "http://www.xvqchinese.com/dsv2/txz/dict/show.php?os=ios&key=\(key)"
        self.navigationController?.pushViewController(CommonWebView(url: url, title:Lang("词条内容"), scalesPage: false), animated: true)
        self.searchBar.endEditing(true)
    }
    
    func doSearch()
    {
        if self.historyTable.superview != nil
        {
            self.historyTable.removeFromSuperview()
        }
        if self.showResult.superview == nil
        {
            self.view.addSubview(self.showResult)
        }

        let key = escape(self.searchBar.text!)
        let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/dict/key.php?os=ios&key=\(key)")
        let request : URLRequest = URLRequest(url: url!)
        self.showResult.stopLoading()
        self.showResult.load(request)
    }
}
