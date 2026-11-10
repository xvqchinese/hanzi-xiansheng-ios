//
//  RootView.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014年 zhaokaiyuan. All rights reserved.
//

import UIKit

class SettingRootController: UITableViewController, UMSocialUIDelegate {
    
    let titles = [
        ["0", Lang("✅如何开启“鼎氏输入法“？")],
        //["1", "日常短语"],
        //["2", "节日短语"],
        ["3", Lang("👥用户词库管理")],
        ["31", Lang("🌐词库在线更新")],
        ["32", Lang("🎨输入法皮肤")],
        ["33", Lang("🔧输入法设置")],
        //["32", "键盘/输入模式选择"],
        //["4", "官方新闻"],
        //["5", "检查更新"],
        //["6", "输入法帮助"],
        //["7", "输入法定制开发"],
        ["81", Lang("📚输入法使用说明")],
        ["82", Lang("🏢鼎氏学院")],
        ["83", Lang("♥️与朋友分享")],
        ["8", Lang("ℹ️联系我们")],
        //["90", "--测试--"],
        ["9", Lang("输入法异常日志")]
    ]
    
    let appKey = "57ad89d1e0f55a08ef0023e4"
    let appUrl = "http://www.xvqchinese.com/dsv2/txz/share.php?os=ios";

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hidesBottomBarWhenPushed = false
        self.navigationItem.title = Lang("home_title")
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.white
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingTableViewCell")
        
        UMSocialData.setAppKey(appKey)
        
        //设置微信AppId、appSecret，分享url
        UMSocialWechatHandler.setWXAppId("wx2b6f1864dd24eb22", appSecret: "1b608e42bf37822857f5627908c03daf", url: appUrl)
        
        //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
        UMSocialQQHandler.setQQWithAppId("1105533349", appKey: "esbyszo80MS5L4ym", url: appUrl)

        //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
        let rurl = "http://sns.whalecloud.com/sina2/callback"
        UMSocialSinaSSOHandler.openNewSinaSSO(withAppKey: "682958140", secret: "9fbcf6bef17cc01003a54e42ea4215d0", redirectURL: rurl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.hidesBottomBarWhenPushed = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if loadStringFileFromGroup("eLog.txt") != nil
        {
            return self.titles.count
        }
        return self.titles.count - 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        switch(cell!.tag)
        {
        case 0:
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(CommonWebView(url: "", title: Lang("help_title"), scalesPage: true), animated: true)
            break
            
        case 1: // 日常短语
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(DailyPhr(), animated: true)
            break
            
        case 2: // 节日短语
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(HolidayPhr(), animated: true)
            break
            
        case 3: // 用户词库
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(UserViewController(), animated: true)
            break
            
        case 31: // 词库在线升级
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(DBUpdate(), animated: true)
            break
            
        case 32:
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(ThemesView(), animated: true)
            break
            
        case 33:
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(SettingsView(root: settingsCreateRoot()), animated: true)
            break
            
        case 6: // 帮助
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(HelpView(), animated: true)
            break
            
        case 8: // 关于
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(AboutView(), animated: true)
            break
            
        case 81:    // online 说明书
            self.hidesBottomBarWhenPushed = true
            let web = CommonWebView(url: "http://www.xvqchinese.com/dsv2/user_manual/?os=ios&lang=\(Lang("lang"))", title: Lang("说明书"), scalesPage: false)
            self.navigationController?.pushViewController(web, animated: true)
            break
            
        case 82: // 学院
            self.hidesBottomBarWhenPushed = true
            let web = CommonWebView(url: "http://www.xvqchinese.com/", title: Lang("鼎氏学院"), scalesPage: false)
            self.navigationController?.pushViewController(web, animated: true)
            break
            
        case 83:
            self.share()
            break;

        case 9: // 输入法异常日志
            self.navigationController?.pushViewController(LogView(), animated: true)
            break
            
        case 90:
            UIApplication.shared.openURL(URL(string: "DWIMEMM.MMApp.ext://open-config-app")!)
            break
            
        default:
            break
        }
    }
    
    func share()
    {
        let title = "汉字先生";

        // 朋友圈
        UMSocialData.default().extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        
        // qq
        UMSocialData.default().extConfig.qqData.title = title
        UMSocialData.default().extConfig.qqData.url = self.appUrl
        UMSocialData.default().extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;

        // qq 空间
        UMSocialData.default().extConfig.qzoneData.title = title;
        UMSocialData.default().extConfig.qzoneData.url = self.appUrl

        // weibo
        //UMSocialData.default().extConfig.sinaData
        
        UMSocialSnsService.presentSnsIconSheetView(self,
            appKey: appKey,
            shareText: "最新专利助学工具，外国朋友学中文必备！\(self.appUrl)",
            shareImage: UIImage(named: "AppIcon"),
            shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone, UMShareToSina],
            delegate: self)
    }

    func didSelectSocialPlatform(platformName: String!, withSocialData socialData: UMSocialData!)
    {
        if platformName == UMShareToSina
        {
            MyLog(platformName)
        }
    }
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!)
    {
        MyLog("response : \(response)")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            label.isUserInteractionEnabled = false
            label.text = self.titles[indexPath.row][1]
            
            cell!.tag = Int(self.titles[indexPath.row][0])!
            cell!.contentView.addSubview(label)
        }
        
        return cell!
    }
    
    
    
}