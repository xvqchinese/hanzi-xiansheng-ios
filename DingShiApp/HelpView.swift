//
//  Daily.swift
//  DWKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class HelpView: UIViewController
{
    var web: WKWebView?
    
    override func viewDidLoad()
    {
        self.navigationItem.title = Lang("help_title")
        
        self.web = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.web!)
        
        // 原帮助页挂在第三方服务器（dwhand.com），已确认非自有服务器，改为本地离线帮助
        let html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head><body style='font-family:-apple-system,sans-serif;padding:16px;color:#333;'><h2 style='font-size:18px;'>如何开启汉字先生键盘</h2><p style='font-size:14px;line-height:1.6;'>1. 打开「设置」→「通用」→「键盘」→「键盘」<br>2. 点击「添加新键盘」，选择「鼎氏」<br>3. 点按地球图标 可切换输入法<br>4. 如需完整功能，请允许「完全访问」（设置 → 鼎氏 → 允许完全访问）</p><p style='font-size:14px;line-height:1.6;'>词典与翻译功能可在 App 首页使用。</p></body></html>"
        self.web?.loadHTMLString(html, baseURL: nil)
    }
}
