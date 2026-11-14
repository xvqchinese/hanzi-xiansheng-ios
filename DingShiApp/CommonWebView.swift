//
//  CommonWebView
//  CommonWebView
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class CommonWebView: UIViewController, WKNavigationDelegate
{
    var web: WKWebView?
    var url: String!
    var titleStr: String!
    var activityIndicatorView: UIActivityIndicatorView!
    var scalesPage: Bool = true
    var hzFlash :HZFlashView!
    var showTimer: Timer?
    
    init(url: String, title: String, scalesPage: Bool)
    {
        self.init()
        self.url = url
        self.titleStr = title
        self.scalesPage = scalesPage
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        self.web = WKWebView(frame: self.view.frame)
        self.web?.navigationDelegate = self
        self.view.addSubview(self.web!)
        self.navigationItem.title = self.titleStr
        
        self.hzFlash = HZFlashView();
        
        if self.url.count == 0
        {
            // 无 url 就显示帮助: how to open ime?
            let mb = Bundle.main
            let srcPath = (mb.resourcePath! as NSString).appendingPathComponent("index.htm")
        
            let log = try? String(contentsOfFile: srcPath, encoding: String.Encoding.utf8)
            self.web?.loadHTMLString(log as! String, baseURL: URL(fileURLWithPath: srcPath))
        }
        else if self.url == "share"
        {
            // 无 url 就显示帮助: how to open ime?
            let mb = Bundle.main
            let srcPath = (mb.resourcePath! as NSString).appendingPathComponent("share.htm")
            
            let log = try? String(contentsOfFile: srcPath, encoding: String.Encoding.utf8)
            self.web?.loadHTMLString(log as! String, baseURL: URL(fileURLWithPath: srcPath))
        }
        else
        {
            // 词典页字号偏小，统一放大一号（注册/登录页除外）
            if !(self.url.contains("reg_ios") || self.url.contains("login_ui") || self.url.contains("apple_login"))
            {
                let css = "var s=document.createElement('style');s.innerHTML='html,body{font-size:26px !important;line-height:1.5 !important;} body,p,div,span,td,li,dd,dt,section,article,blockquote,h1,h2,h3,h4,h5,font{font-size:26px !important;line-height:1.5 !important;max-width:100% !important;overflow-wrap:break-word !important;word-break:break-word !important;white-space:normal !important;} img{max-width:100% !important;height:auto !important;}';document.head.appendChild(s);"
                let script = WKUserScript(source: css, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                self.web?.configuration.userContentController.addUserScript(script)
            }
            var u = self.url
            // 词条页强刷缓存：每次都带一个时间戳，否则 WKWebView 会一直用旧页面（旧字号）
            if u.contains("show.php")
            {
                u += (u.contains("?") ? "&" : "?") + "_t=\(Int(Date().timeIntervalSince1970))"
            }
            self.web?.load(URLRequest(url: URL(string: u)!))
        }

        // wait...
        activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.frame = CGRect(x: self.view.frame.size.width/2 - 50, y: self.view.frame.size.height/2 - 30, width: 100, height: 60)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        activityIndicatorView.color = UIColor.white
        activityIndicatorView.layer.cornerRadius = 5.0
        self.view.addSubview(activityIndicatorView)
     
        // 设置下拉, show.php 下拉不刷新，影响使用
        if !self.url.contains("show.php")
        {
            self.web!.scrollView.addHeaderWithCallback { () -> Void in
                self.web!.reload()
                self.web!.scrollView.headerEndRefreshing()
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        self.activityIndicatorView.startAnimating()
    }
    
    let bigFontCSS = "var s=document.createElement('style');s.type='text/css';s.innerHTML=\"html,body,p,div,span,td,li,dd,dt,section,article,blockquote,h1,h2,h3,h4,h5,font{font-size:26px !important;line-height:1.55 !important;max-width:100% !important;overflow-wrap:break-word !important;word-break:break-word !important;white-space:normal !important;}img{max-width:100% !important;height:auto !important;}\";document.head.appendChild(s);document.documentElement.setAttribute('style','font-size:26px !important');if(document.body){document.body.setAttribute('style',(document.body.getAttribute('style')||'')+';font-size:26px !important');}"

    func injectBigFont(_ webView: WKWebView)
    {
        if self.url.contains("reg_ios") || self.url.contains("login_ui") || self.url.contains("apple_login") { return }
        webView.evaluateJavaScript(bigFontCSS, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.injectBigFont(webView)
        if #available(iOS 14.0, *) { webView.pageZoom = 1.6 }
        self.activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        self.activityIndicatorView.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        self.activityIndicatorView.stopAnimating()
    }
    
    @objc func showHZFlash()
    {
        self.hzFlash.show()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if navigationAction.navigationType == .linkActivated
        {
            if let urlString = navigationAction.request.url?.absoluteString
            {
                print(urlString)
                
                if urlString.contains("voice.cpp")
                {
                    // yi3 -> 鼎氏调母 yiv（2声x 3声v 4声q），否则语音引擎取不到音
                    if let yin = urlString.components(separatedBy: "yin=").last
                    {
                        var code = yin.removingPercentEncoding ?? yin
                        if let last = code.last, let tone = Int(String(last))
                        {
                            code = String(code.dropLast())
                            if tone == 2 { code += "x" }
                            else if tone == 3 { code += "v" }
                            else if tone == 4 { code += "q" }
                        }
                        let rep = playWavReport(code)
                        NSLog("喇叭朗读 %@ -> %@", code, rep)
                    }
                    decisionHandler(.cancel)
                    return
                }
                
                if urlString.contains("flash.cpp")
                {
                    let phrs = urlString.components(separatedBy: "?phr=")
                    if phrs.count == 2
                    {
                        self.hzFlash.setWord(word: (ocUtils.urlDecodedString(phrs[1]) ?? "") as NSString)
                        self.showTimer?.invalidate()
                        self.showTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: Selector("showHZFlash"), userInfo: nil, repeats: false)

                    }
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
}
