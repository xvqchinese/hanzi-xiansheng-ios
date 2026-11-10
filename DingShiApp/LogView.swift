//
//  Daily.swift
//  DWKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class LogView: UIViewController
{
    var web: WKWebView?
    var del: UIButton?

    override func viewDidLoad()
    {
        self.navigationItem.title = Lang("log_title")

        self.web = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.web!)

        let log = loadStringFileFromGroup("eLog.txt")
        self.web?.loadHTMLString(log as! String, baseURL: nil)

        self.del = UIButton()
        self.del?.setTitle("   Delete   ", for: .normal)
        self.del?.setTitleColor(UIColor.white, for: .normal)
        self.del?.setTitleColor(UIColor.brown , for: .highlighted)
        self.del?.backgroundColor = UIColor.red
        self.del?.layer.cornerRadius = 5.0
        self.del?.sizeToFit()
        self.del!.center = self.view.center
        self.del?.addTarget(self, action: Selector("delete_log_file"), for: .touchUpInside)
        self.view.addSubview(self.del!)
    }

    @objc func delete_log_file()
    {
        let fm = FileManager.default
        let url: URL = fileUrlFromGroup("eLog.txt")
        
        do {
            try fm.removeItem(at: url)
        } catch _ {
        }
    }
}
