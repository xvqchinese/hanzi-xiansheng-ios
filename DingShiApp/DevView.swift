//
//  Daily.swift
//  DWKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class DevView: UIViewController
{
    var web: WKWebView?
    
    override func viewDidLoad()
    {
        self.navigationItem.title = Lang("help_title")

        self.web = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.web!)
        
        // 原开发者页挂在第三方服务器（dwhand.com），已确认非自有服务器，摘除
        let html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head><body style='text-align:center;padding-top:60px;color:#666;font-family:-apple-system,sans-serif;'><h2 style='font-size:18px;'>功能调整中</h2><p style='font-size:14px;'>该页面正在维护，请稍后再试。</p></body></html>"
        self.web?.loadHTMLString(html, baseURL: nil)
    }
}
