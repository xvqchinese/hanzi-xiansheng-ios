//
//  Daily.swift
//  MMKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class ThemesView: UIViewController, WKNavigationDelegate
{
    var web: WKWebView?
    var edit: UITextView?
    var activityIndicatorView: UIActivityIndicatorView!
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        self.web = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.web!)
        self.web?.navigationDelegate = self
        self.web?.backgroundColor = UIColor.white
        
        self.edit = UITextView(frame: CGRect(x: 1, y: 1, width: self.view.frame.size.width, height: 30))
        self.edit?.layer.zPosition = 100;
        self.view.addSubview(self.edit!)
        
        self.navigationItem.title = Lang("皮肤")
        
        // 原皮肤页挂在第三方服务器（dwhand.com），已确认非自有服务器，摘除
        let html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head><body style='text-align:center;padding-top:60px;color:#666;font-family:-apple-system,sans-serif;'><h2 style='font-size:18px;'>皮肤功能调整中</h2><p style='font-size:14px;'>该功能正在维护，请稍后再试。</p></body></html>"
        self.web?.loadHTMLString(html, baseURL: nil)

        // wait...
        activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.frame = CGRect(x: self.view.frame.size.width/2 - 50, y: self.view.frame.size.height/2 - 30, width: 100, height: 60)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        activityIndicatorView.color = UIColor.white
        activityIndicatorView.layer.cornerRadius = 5.0
        self.view.addSubview(activityIndicatorView)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        self.activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        self.activityIndicatorView.stopAnimating()
    }
    
    // 返回 .cancel 取消请求
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let temp = navigationAction.request.url
        {
            MyLog(">>>>>" + temp.absoluteString + "<<<<<")

            if temp.absoluteString.contains("set_color_to_default")
            {
                // 设置为默的就是把 颜色文件删除即可
                let fm = FileManager.default
                let url = fileUrlFromGroup("colorProfile")
                do {
                    try fm.removeItem(at: url)
                } catch _ {
                }
                self.edit?.becomeFirstResponder()
                decisionHandler(.cancel)
                return
            }
            else if temp.absoluteString.contains("set_color_to_file")
            {
                // 把颜色数据写入“colorProfile” 共享文件
                let urlParam = temp.absoluteString.components(separatedBy: "?")
                if urlParam.count == 2
                {
                    let url = fileUrlFromGroup("colorProfile")
                    do {
                        try urlParam[1].write(to: url, atomically: false, encoding: String.Encoding.utf8)
                    } catch _ {
                    }
                    self.edit?.becomeFirstResponder()
                }
                else
                {
                    let alert = UIAlertController(title: Lang("error_title"), message: "颜色参数错误！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Lang("about_button_ok"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
}
