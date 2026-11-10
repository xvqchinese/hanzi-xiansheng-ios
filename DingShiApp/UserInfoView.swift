//
//  UserInfoView.swift
//  DWKeyboard
//
//  Created by Aliang on 16/6/28.
//  Copyright © 2016年 Apple. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class UserInfoViewController: UIViewController, WKNavigationDelegate
{
    var web: WKWebView?
    var activityIndicatorView: UIActivityIndicatorView!
    
    let appKey = "57ad89d1e0f55a08ef0023e4"
    let appUrl = "http://www.xvqchinese.com/dsv2/txz/share.php?os=ios";

    
    override func viewDidLoad()
    {
        self.web = WKWebView(frame: self.view.frame)
        self.web?.navigationDelegate = self
        self.view.addSubview(self.web!)
        self.navigationItem.title = Lang("用户")
        
        self.web?.load(URLRequest(url: URL(string: "http://www.xvqchinese.com/dsv2/txz/?os=ios&lang=\(Lang("lang"))")!))
        
        // wait...
        activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.frame = CGRect(x: self.view.frame.size.width/2 - 50, y: self.view.frame.size.height/2 - 30, width: 100, height: 60)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        activityIndicatorView.color = UIColor.white
        activityIndicatorView.layer.cornerRadius = 5.0
        self.view.addSubview(activityIndicatorView)
        
        // 设置下拉
        self.web!.scrollView.addHeaderWithCallback { () -> Void in
            self.web!.reload()
            self.web!.scrollView.headerEndRefreshing()
        }

    
        UMSocialData.setAppKey(appKey)
        
        //设置微信AppId、appSecret，分享url
        UMSocialWechatHandler.setWXAppId("wx2b6f1864dd24eb22", appSecret: "1b608e42bf37822857f5627908c03daf", url: appUrl)
        
        //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
        UMSocialQQHandler.setQQWithAppId("1105533349", appKey: "esbyszo80MS5L4ym", url: appUrl)
        
        //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
        let rurl = "http://sns.whalecloud.com/sina2/callback"
        UMSocialSinaSSOHandler.openNewSinaSSO(withAppKey: "682958140", secret: "9fbcf6bef17cc01003a54e42ea4215d0", redirectURL: rurl)
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
    
    // 下载用户备份的词库
    private func getUserPhrFromServer() -> [String]?
    {
        // 下载自造词
        let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/download.php?os=ios")
        if let data: Data = try? Data(contentsOf: url!)
        {
            if let phrs: NSString = String(data: data, encoding: String.Encoding.utf8) as NSString?
            {
                let phrAry = phrs.components(separatedBy: "\r\n")
                return phrAry
            }
        }
        return nil
    }
    
    // 加载用户词库
    private func loadUserDB(_ im: Int32, allowＣreate:Bool) -> UnsafeMutableRawPointer?
    {
        var userDB : UnsafeMutableRawPointer? = loadDBToMem((im == IM_PINYIN) ? "userDB_PY.data" : "userDB_SK.data")
        if userDB == nil && allowＣreate
        {
            let dbSize = Int(IMEngine.dwimePrepareUserDB(im))
            userDB = malloc(Int(dbSize))
            if userDB != nil
            {
                IMEngine.dwimeCreateUserDB(im, userDB!)
            }
        }
        return userDB
    }

    // 保存
    private func saveUserDB(_ im : Int32, userDB: UnsafeMutableRawPointer)
    {
        let url = fileUrlFromGroup((im == IM_PINYIN) ? "userDB_PY.data" : "userDB_SK.data")
        let db = Data(bytes: userDB, count: Int(IMEngine.dwimePrepareUserDB(im)))
        try? db.write(to: url, options: [])
    }
    
    // 下载还原用户词库
    private func downloadUserDB() -> Int
    {
        let pyUser = self.loadUserDB(IM_PINYIN, allowＣreate: true) // 拼音记忆
        let skUser = self.loadUserDB(IM_STROKE, allowＣreate: true) // 笔画记忆
        var count: Int = 0
        
        // 下载自造词
        if let phrAry = self.getUserPhrFromServer()
        {
            for line in phrAry
            {
                if line.count == 0
                {
                    continue;
                }
                
                let itemAry = line.components(separatedBy: "\t")
                
                // 加入数据库
                // 笔画数据, 拼音的词也加入笔画里
                if itemAry.count >= 1
                {
                    if (skUser != nil && !IMEngine.dwimeUserDBItemExisted(IM_STROKE, skUser!, itemAry[0], ""))
                    {
                        IMEngine.imSplImeUserAddExt(IM_STROKE, skUser!, itemAry[0], "")
                        count += 1
                    }
                }
                
                // 加入数据库
                // 拼音数据，只还原拼音的数据
                if itemAry.count == 2
                {
                    if (pyUser != nil && !IMEngine.dwimeUserDBItemExisted(IM_PINYIN, pyUser!, itemAry[0], itemAry[1]))
                    {
                        IMEngine.imSplImeUserAddExt(IM_PINYIN, pyUser!, itemAry[0], itemAry[1])
                        count += 1
                    }
                }
            }
        }

        if pyUser != nil
        {
            self.saveUserDB(IM_PINYIN, userDB: pyUser!)
            free(pyUser!);
        }
        if skUser != nil
        {
            self.saveUserDB(IM_STROKE, userDB: skUser!)
            free(skUser!);
        }
        return count
    }
    
    // 上传备份用户记忆数据
    private func uploadUserDB() -> String
    {
        var uploadStr: String = "";
        
        // 拼音
        if true
        {
            let pyUser = self.loadUserDB(IM_PINYIN, allowＣreate: false) // 拼音记忆
            if pyUser != nil
            {
                let count = IMEngine.dwimeUserDBGetCount(IM_PINYIN, pyUser!)
                for i in 0..<count
                {
                    if (IMEngine.dwimeUserDBIsNewPhr(IM_PINYIN, pyUser!, i))
                    {
                        let phr = IMEngine.dwimeUserDBGetPhr(IM_PINYIN, pyUser!, i)
                        let pys = IMEngine.dwimeUserDBGetCode(IM_PINYIN, pyUser!, i)
                        uploadStr += "\(phr)\t\(pys)\r\n";
                    }
                }
                free(pyUser!)
            }
        }
        
        // 笔画
        if (true)
        {
            let skUser = self.loadUserDB(IM_STROKE, allowＣreate: false) // 笔画记忆
            if skUser != nil
            {
                let count = IMEngine.dwimeUserDBGetCount(IM_STROKE, skUser!)
                for i in 0..<count
                {
                    let phr = IMEngine.dwimeUserDBGetPhr(IM_STROKE, skUser!, i)
                    uploadStr += "\(phr)\r\n";
                }
                free(skUser!)
            }
        }
        
        // 上传
        let url: URL? = URL(string: "http://www.xvqchinese.com/dsv2/txz/upload.php?os=ios")
        let urlRequest = NSMutableURLRequest(url: url!)
        let body = "phrs=\(escape(uploadStr))"
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body.data(using: String.Encoding.utf8)
        
        var response: URLResponse?
        if let ret = try? NSURLConnection.sendSynchronousRequest(urlRequest as URLRequest, returning: &response)
        {
            if let msg = String(data: ret, encoding: String.Encoding.utf8)
            {
                return msg
            }
        }
        
        return ""
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if navigationAction.navigationType == .linkActivated
        {
            if let urlString = navigationAction.request.url?.absoluteString
            {
                print(urlString)
                if urlString.contains("upload.cpp")
                {
                    self.activityIndicatorView.startAnimating()
                    DispatchQueue.global().async {
                        //这里写需要大量时间的代码
                        let msg = self.uploadUserDB()
                        DispatchQueue.main.async {
                            //这里返回主线程，写需要主线程执行的代码
                            self.activityIndicatorView.stopAnimating()
                            ocUtils.showMessage(msg.count==0 ? Lang("备份完成！") : msg)
                        }
                    }
                    decisionHandler(.cancel)
                    return
                }
                if urlString.contains("download.cpp")
                {
                    self.activityIndicatorView.startAnimating()
                    DispatchQueue.global().async {
                        //这里写需要大量时间的代码
                        let count = self.downloadUserDB()
                        DispatchQueue.main.async {
                            //这里返回主线程，写需要主线程执行的代码
                            self.activityIndicatorView.stopAnimating()
                            if count > 0
                            {
                                ocUtils.showMessage(Lang("数据下载还原成功！"))
                            }
                            else
                            {
                                ocUtils.showMessage(Lang("数据下载完成！"))
                            }
                        }
                    }
                    decisionHandler(.cancel)
                    return
                }
                if urlString.contains("qq.cpp")
                {
                    let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatform(withName: UMShareToQQ)
                    snsPlatform!.loginClickHandler(self, UMSocialControllerService.default(), true, {responds in
                        
                        if responds?.responseCode == UMSResponseCodeSuccess
                        {
                            let a:UMSocialAccountEntity = UMSocialAccountManager.socialAccountDictionary()[UMShareToQQ] as! UMSocialAccountEntity
                            MyLog("username is \(a.userName), uid is \(a.usid), token is \(a.accessToken) url is \(a.iconURL)")

                            let lang = Lang("lang")
                            let loginParam = "platform=qq&username=\(a.userName)&usid=\(a.usid)&unionId=\(a.unionId)&iconUrl=\(a.iconURL)&accessTonen=\(a.accessToken)";
                            let url = URL(string: "http://www.xvqchinese.com/dsv2/txz/?os=ios&lang=\(lang)&\(loginParam)")!
                            self.web?.load(URLRequest(url: url))
                        }
                        
                    })
                    decisionHandler(.cancel)
                    return
                }
                if urlString.contains("wx.cpp")
                {
                    let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatform(withName: UMShareToWechatSession)
                    snsPlatform!.loginClickHandler(self, UMSocialControllerService.default(), true, {responds in
                        
                        if responds?.responseCode == UMSResponseCodeSuccess
                        {
                            let a:UMSocialAccountEntity = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as! UMSocialAccountEntity
                            MyLog("username is \(a.userName), uid is \(a.usid), token is \(a.accessToken) url is \(a.iconURL)")
                            
                            let lang = Lang("lang")
                            let loginParam = "platform=wx&username=\(a.userName)&usid=\(a.usid)&unionId=\(a.unionId)&iconUrl=\(a.iconURL)&accessTonen=\(a.accessToken)";
                            let url = URL(string: "http://www.xvqchinese.com/dsv2/txz/?os=ios&lang=\(lang)&\(loginParam)")!
                            self.web?.load(URLRequest(url: url))
                        }
                        
                    })
                    decisionHandler(.cancel)
                    return
                }
                if urlString.contains("wb.cpp")
                {
                        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatform(withName: UMShareToSina)
                        snsPlatform!.loginClickHandler(self, UMSocialControllerService.default(), true, {responds in
                    
                        if responds?.responseCode == UMSResponseCodeSuccess
                        {
                            let a:UMSocialAccountEntity = UMSocialAccountManager.socialAccountDictionary()[UMShareToSina] as! UMSocialAccountEntity
                            MyLog("username is \(a.userName), uid is \(a.usid), token is \(a.accessToken) url is \(a.iconURL)");
                            
                            
                            let lang = Lang("lang")
                            let loginParam = "platform=wb&username=\(a.userName)&usid=\(a.usid)&unionId=\(a.unionId)&iconUrl=\(a.iconURL)&accessTonen=\(a.accessToken)";
                            let url = URL(string: "http://www.xvqchinese.com/dsv2/txz/?os=ios&lang=\(lang)&\(loginParam)")!
                            self.web?.load(URLRequest(url: url))
                        }
                    
                    })
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
}
