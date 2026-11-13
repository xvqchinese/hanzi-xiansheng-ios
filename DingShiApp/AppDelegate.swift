//
//  AppDelegate.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

@_silgen_name("DWLastCrash")
func DWLastCrash() -> UnsafePointer<CChar>?

@_silgen_name("DWGuardCall")
func DWGuardCall(_ fn: @convention(c) (Int32) -> Void, _ tag: Int32) -> Int32

final class DWTrustAll: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let t = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: t))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

final class DWAppProbe {
    static let shared = DWAppProbe()
    var holders: [Data] = []
    var curIdx: Int = 0
    var line: String = ""
}

func dwAppProbeEntry(_ tag: Int32) {
    let p = DWAppProbe.shared
    guard p.curIdx < p.holders.count else { return }
    let d = p.holders[p.curIdx]
    let ptr = d.withUnsafeBytes { $0.baseAddress }
    guard let pp = ptr else { return }
    IMEngine.dwimeExit()
    let code = IMEngine.dwimeInit(pp, Int32(d.count), nil, 0, nil, 0, 2, 1, 8)
    if code != 0 { p.line += "init=\(code) "; return }
    let r = IMEngine.dwimeProcessKey(110, 0, 0)
    p.line += "r=\(r) cnt=\(IMEngine.dwimeCount())"
    if IMEngine.dwimeCount() > 0, let c = IMEngine.dwimeGetCand(0, false) { p.line += " 首=\(String(cString: c))" }
    p.line += " len=\(d.count)"
}

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

        // 临时诊断：把键盘落盘日志弹出来（正式上架前删除）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard let c = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS") else { return }
            let u = c.appendingPathComponent("kb_diag.log")
            guard let t = try? String(contentsOf: u, encoding: .utf8), !t.isEmpty else {
                let ac0 = UIAlertController(title: "键盘诊断日志", message: "还没有日志：请先在键盘上按一个字母，再回来打开 App", preferredStyle: .alert)
                ac0.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                rootVC.present(ac0, animated: true, completion: nil)
                return
            }
            var extVer = "?"
            if let plugins = Bundle.main.builtInPlugInsURL {
                let kb = plugins.appendingPathComponent("Keyboard.appex")
                if let b = Bundle(url: kb), let v = b.infoDictionary?["CFBundleShortVersionString"] as? String { extVer = v }
            }
            let appVer = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
            let head = "扩展版本=\(extVer)  主App=\(appVer)\n\n"
            var sum = ""
            if let u = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.DWIME_DS")?.appendingPathComponent("kb_sum.log"),
               let d = try? Data(contentsOf: u), let txt = String(data: d, encoding: .utf8) { sum = txt }
            let tail = t.count > 700 ? String(t.suffix(700)) : t
            let dictRes = AppDelegate.probeDictVariants()
            let ac = UIAlertController(title: "键盘诊断：词库 × 版本测试", message: head + "【词库版本测试（中文 L=8 + 键 n）】\n" + dictRes + "\n\n【键盘汇总】\n" + sum, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            rootVC.present(ac, animated: true, completion: nil)
        }

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


extension AppDelegate {
    static func probeDictVariants() -> String {
        // 改为纯本地校验：不触碰 C 引擎，避免再崩
        guard let u = Bundle.main.url(forResource: "py", withExtension: "data"),
              let d = try? Data(contentsOf: u) else { return "内置 py：读取失败" }
        let b = [UInt8](d)
        let marker = Array("PYIMBIN1".utf8)
        var found = false
        if b.count > marker.count {
            var i = b.count - marker.count
            while i >= 0 {
                var same = true
                var k = 0
                while k < marker.count {
                    if b[i + k] != marker[k] { same = false; break }
                    k += 1
                }
                if same { found = true; break }
                i -= 1
            }
        }
        return "内置 py=\(d.count)字节 / 索引段=" + (found ? "已找到" : "缺失")
    }
}
