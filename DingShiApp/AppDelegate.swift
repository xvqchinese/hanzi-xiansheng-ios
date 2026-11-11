//
//  AppDelegate.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barStyle = .blackTranslucent
        
        let rootVC = XFMAppViewController(nibName: nil, bundle: nil)
      
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = rootVC
        self.window?.addSubview(rootVC.view!)
        self.window!.makeKeyAndVisible()
        
        // 临时诊断：显示键盘写入的引擎初始化结果（正式上架前删除）
        if let txt = UserDefaults(suiteName: "group.DWIME_DS")?.string(forKey: "diag")
        {
            let ac = UIAlertController(title: "键盘引擎诊断", message: txt, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                rootVC.present(ac, animated: true, completion: nil)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if let urlStr = ocUtils.urlDecodedString(url.absoluteString)
        {
            MyLog("url = \(urlStr)")
            let root = self.window!.rootViewController as! XFMAppViewController
            if urlStr.contains("open-config-app")
            {
                root.gotoSetting()
            }
            else
            {
                let params = urlStr.components(separatedBy: "?key=")
                if params.count == 2
                {
                    root.gotoDict(params[1])
                }
                else
                {
                    return UMSocialSnsService.handleOpen(url)
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return UMSocialSnsService.handleOpen(url)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return UMSocialSnsService.handleOpen(url)
    }

}
