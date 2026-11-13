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
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = Lang("皮肤")

        let skins: [(String, String)] = [
            ("白色", ""),
            ("绿色", "KbBColor=0xffc8e6c9&CommandBColor=0xffaed581&CandBColor=0xffaed581&CandDownBColor=0xff8bc34a&KeyColor=0xffffffff&KeyTxtColor=0xff333333&FunKeyColor=0xff8bc34a&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff"),
            ("粉色", "KbBColor=0xfff8bbd0&CommandBColor=0xfff06292&CandBColor=0xfff06292&CandDownBColor=0xffe91e63&KeyColor=0xfffce4ec&KeyTxtColor=0xff333333&FunKeyColor=0xffe91e63&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff"),
            ("黄色", "KbBColor=0xffe6d48c&CommandBColor=0xfff7dc6f&CandBColor=0xfff7dc6f&CandDownBColor=0xffe67e22&KeyColor=0xfff9e79f&KeyTxtColor=0xff333333&FunKeyColor=0xffe67e22&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff")
        ]
        let w: CGFloat = self.view.frame.width
        let cols: CGFloat = 2
        let cellW = (w - 24) / cols
        let cellH = cellW * 1.25
        var i = 0
        for (name, profile) in skins
        {
            let btn = UIButton(type: .custom)
            let x = 8 + CGFloat(i % 2) * (cellW + 8)
            let y = 90 + CGFloat(i / 2) * (cellH + 46)
            btn.frame = CGRect(x: x, y: y, width: cellW, height: cellH)
            btn.backgroundColor = profile.isEmpty ? UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1) : ThemesView.colorFromProfile(profile)
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.setTitle(name, for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btn.tag = i
            btn.addTarget(self, action: Selector("onSkin:"), for: .touchUpInside)
            self.view.addSubview(btn)
            i += 1
        }
    }

    static func colorFromProfile(_ profile: String) -> UIColor
    {
        for one in profile.components(separatedBy: "&")
        {
            let kv = one.components(separatedBy: "=")
            if kv.count == 2 && kv[0] == "KbBColor"
            {
                let hex = kv[1]
                let v = UInt32(hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex, radix: 16) ?? 0xDDDDDD
                return UIColor(red: CGFloat((v >> 16) & 0xff)/255, green: CGFloat((v >> 8) & 0xff)/255, blue: CGFloat(v & 0xff)/255, alpha: 1)
            }
        }
        return UIColor.white
    }

    @objc func onSkin(_ sender: UIButton)
    {
        let profiles: [String] = ["", "KbBColor=0xffc8e6c9&CommandBColor=0xffaed581&CandBColor=0xffaed581&CandDownBColor=0xff8bc34a&KeyColor=0xffffffff&KeyTxtColor=0xff333333&FunKeyColor=0xff8bc34a&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff", "KbBColor=0xfff8bbd0&CommandBColor=0xfff06292&CandBColor=0xfff06292&CandDownBColor=0xffe91e63&KeyColor=0xfffce4ec&KeyTxtColor=0xff333333&FunKeyColor=0xffe91e63&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff", "KbBColor=0xffe6d48c&CommandBColor=0xfff7dc6f&CandBColor=0xfff7dc6f&CandDownBColor=0xffe67e22&KeyColor=0xfff9e79f&KeyTxtColor=0xff333333&FunKeyColor=0xffe67e22&FunKeyTxtColor=0xffffffff&FunKeyGraColor=0xffffffff"]
        let idx = max(0, min(3, sender.tag))
        if let u = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("colorProfile")
        {
            if profiles[idx].isEmpty { try? FileManager.default.removeItem(at: u) }
            else { try? profiles[idx].data(using: .utf8)?.write(to: u) }
        }
        NotificationCenter.default.post(name: Notification.Name("DWRelayout"), object: nil)
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
