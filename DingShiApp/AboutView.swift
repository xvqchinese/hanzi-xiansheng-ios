//
//  Daily.swift
//  DWKeyboard
//
//  Created by mac on 14-11-20.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

import UIKit
import WebKit


class AboutView: UIViewController
{
    var web: WKWebView?
    
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
        
            self.navigationItem.title = Lang("about_title")
            
            let mb = Bundle.main
            let srcPath = (mb.resourcePath! as NSString).appendingPathComponent("about_v2.htm")
        
            let log = try? String(contentsOfFile: srcPath, encoding: String.Encoding.utf8)
            self.web?.loadHTMLString(log as! String, baseURL: URL(fileURLWithPath: srcPath))
    }
}
