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
        
        return true
    }


    // 临时自检（正式上架前删除）
    static var dbHolder: Data?      // 必须持有，否则引擎读到已释放内存会崩

    static func engineSelfTest() -> String
    {
        var msg = ""
        var d: Data? = nil
        var src = ""

        if let path = Bundle.main.path(forResource: "py", ofType: "data"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)), data.count > 1024
        {
            d = data; src = "内置"
        }
        else
        {
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")
            let gp = container?.appendingPathComponent("py.data")
            if let gp2 = gp, let data = try? Data(contentsOf: gp2), data.count > 1024
            { d = data; src = "共享区" }
        }

        guard let db = d else { return "两处都没有 py.data（内置与共享区均缺失）" }

        AppDelegate.dbHolder = db
        msg += "词库来源 \(src)  \(db.count) 字节"

        IMEngine.dwimeExit()

        // 所有引擎调用都放在 withUnsafeBytes 内，保证内存全程有效
        let r: (Int32, Int32, Int32, Int32, String) = db.withUnsafeBytes { raw -> (Int32, Int32, Int32, Int32, String) in
            let code = IMEngine.dwimeInit(raw.baseAddress, Int32(db.count), nil, 0, nil, 0, 2, 1, 8)
            if code != 0 { return (code, 0, 0, 0, "") }
            let c0 = IMEngine.dwimeCount()
            let k = IMEngine.dwimeProcessKey(110, 0, 0)
            let c1 = IMEngine.dwimeCount()
            var word = ""
            if c1 > 0, let cand = IMEngine.dwimeGetCand(0, false) { word = String(cString: cand) }
            return (code, c0, k, c1, word)
        }

        msg += "\n初始化返回 \(r.0)  初始候选 \(r.1)"
        if r.0 != 0 { return msg + "\n初始化失败，后续不再调用引擎" }
        msg += "\n按键 n 返回 \(r.2)  候选数 \(r.3)"
        msg += r.4.isEmpty ? "\n无候选（拼音索引没建起来）" : "\n首个候选：\(r.4)"
        return msg
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
