//
//  RootView.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014年 zhaokaiyuan. All rights reserved.
//

import UIKit

class XFMAppViewController: UITabBarController {
    
    var navDict: UINavigationController?
    var navTran: UINavigationController?
    var navKejian: UINavigationController?
    var navSetting: UINavigationController?
    
    var settingRoot : SettingRootController?
    var tranRoot: TranRootController?
    var dictRoot: DictRootController?
    var keJianRoot: KeJianRootController?
    
    var showDictPhtTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.tabBar.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        self.tabBar.tintColor = UIColor(red: 2.0/255.0, green: 187.0/255.0, blue: 0.0/255.0, alpha: 1.0)

        self.dictRoot = DictRootController()
        self.dictRoot?.tabBarItem.title = Lang("词典")
        self.dictRoot?.tabBarItem.image = UIImage(named: "tabbar_mainframe")
        self.dictRoot?.tabBarItem.selectedImage = UIImage(named: "tabbar_mainframeHL")
        self.navDict = TLNavigationController(rootViewController: self.dictRoot!)

        self.tranRoot = TranRootController()
        self.tranRoot?.tabBarItem.title = Lang("翻译")
        self.tranRoot?.tabBarItem.image = UIImage(named: "tabbar_contacts")
        self.tranRoot?.tabBarItem.selectedImage = UIImage(named: "tabbar_contactsHL")
        self.navTran = TLNavigationController(rootViewController: self.tranRoot!)

        self.keJianRoot = KeJianRootController()
        self.keJianRoot?.tabBarItem.title = Lang("学院")
        self.keJianRoot?.tabBarItem.image = UIImage(named: "tabbar_discover")
        self.keJianRoot?.tabBarItem.selectedImage = UIImage(named: "tabbar_discoverHL")
        self.navKejian = TLNavigationController(rootViewController: self.keJianRoot!)

        self.settingRoot = SettingRootController()
        self.settingRoot?.tabBarItem.title = Lang("设置")
        self.settingRoot?.tabBarItem.image = UIImage(named: "tabbar_setting")
        self.settingRoot?.tabBarItem.selectedImage = UIImage(named: "tabbar_settingHL")
        self.navSetting = TLNavigationController(rootViewController: self.settingRoot!)
        
        //self.setViewControllers([self.navDict!, self.navTran!, /*self.navKejian!, */self.navSetting!], animated: false)
        self.setViewControllers([self.navSetting!, self.navDict!, self.navTran!], animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    func gotoSetting()
    {
        self.selectedIndex = 2
    }
    
    func gotoDict(_ word:String)
    {
        self.selectedIndex = 0
        // 定时显示，不然在app事先没有启动的情况下会死机
        self.showDictPhtTimer?.invalidate()
        self.showDictPhtTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: Selector("showDictPhr"), userInfo: word, repeats: false)
    }
    
    @objc func showDictPhr()
    {
        if let word = self.showDictPhtTimer?.userInfo as? String
        {
            if self.dictRoot != nil
            {
                self.dictRoot?.searchBar.text = word;
                self.dictRoot?.doShowPhrItem()
            }
        }
    }
    
}