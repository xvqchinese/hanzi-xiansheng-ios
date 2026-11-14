import UIKit
import AuthenticationServices

class RegisterView: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
{
    var onDone: (() -> Void)?

    let titleLabel = UILabel()
    let tipLabel = UILabel()
    let appleBtn = UIButton(type: .system)
    let wechatBtn = UIButton(type: .system)
    let phoneBtn = UIButton(type: .system)
    let mailBtn = UIButton(type: .system)
    let skipBtn = UIButton(type: .system)
    let netLabel = UILabel()
    var netOK = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        titleLabel.text = "汉 字 先 生"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        self.view.addSubview(titleLabel)

        tipLabel.text = "注册后学习记录、皮肤、词库可跟账号同步，换手机可恢复"
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.textColor = UIColor.darkGray
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        self.view.addSubview(tipLabel)

        setupButton(appleBtn, "  通过 Apple 登录", UIColor.black, UIColor.white)
        appleBtn.addTarget(self, action: #selector(onApple), for: .touchUpInside)
        setupButton(wechatBtn, "  微信登录", UIColor(red: 0.02, green: 0.70, blue: 0.20, alpha: 1), UIColor.white)
        wechatBtn.addTarget(self, action: #selector(onWeChat), for: .touchUpInside)
        setupButton(phoneBtn, "  手机号注册 / 登录", UIColor(red: 0.10, green: 0.45, blue: 0.90, alpha: 1), UIColor.white)
        phoneBtn.addTarget(self, action: #selector(onPhone), for: .touchUpInside)
        setupButton(mailBtn, "  邮箱注册 / 登录", UIColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1), UIColor.white)
        mailBtn.addTarget(self, action: #selector(onMail), for: .touchUpInside)

        skipBtn.setTitle("先不注册，直接使用", for: .normal)
        skipBtn.setTitleColor(UIColor.gray, for: .normal)
        skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        skipBtn.addTarget(self, action: #selector(onSkip), for: .touchUpInside)
        self.view.addSubview(skipBtn)

        netLabel.font = UIFont.systemFont(ofSize: 13)
        netLabel.textColor = UIColor.darkGray
        netLabel.textAlignment = .center
        netLabel.numberOfLines = 0
        netLabel.text = "正在检查网络…"
        self.view.addSubview(netLabel)
        checkNetwork()
    }

    func checkNetwork()
    {
        netOK = false
        netLabel.textColor = UIColor.darkGray
        netLabel.text = "正在检查网络…"
        var req = URLRequest(url: URL(string: "https://www.xvqchinese.com/dsv2/txz/db_update/getdb.php?os=ios")!)
        req.timeoutInterval = 8
        req.cachePolicy = .reloadIgnoringLocalCacheData
        URLSession.shared.dataTask(with: req) { d, r, e in
            DispatchQueue.main.async {
                let code = (r as? HTTPURLResponse)?.statusCode ?? 0
                if e == nil && code == 200
                {
                    self.netOK = true
                    self.netLabel.textColor = UIColor(red: 0.02, green: 0.60, blue: 0.20, alpha: 1)
                    self.netLabel.text = "网络正常，可以注册或登录"
                }
                else
                {
                    self.netOK = false
                    self.netLabel.textColor = UIColor(red: 0.80, green: 0.10, blue: 0.10, alpha: 1)
                    self.netLabel.text = "网络未连接或服务器未响应，请稍后重试"
                }
            }
        }.resume()
    }

    func setupButton(_ b: UIButton, _ t: String, _ bg: UIColor, _ fg: UIColor)
    {
        b.setTitle(t, for: .normal)
        b.setTitleColor(fg, for: .normal)
        b.backgroundColor = bg
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 8
        b.layer.masksToBounds = true
        self.view.addSubview(b)
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let w = self.view.frame.width
        let h = self.view.frame.height
        let top = h > 700 ? h * 0.12 : 80.0
        titleLabel.frame = CGRect(x: 0, y: top, width: w, height: 44)
        tipLabel.frame = CGRect(x: 20, y: top + 50, width: w - 40, height: 40)

        var y = top + 110
        let bw = w - 60
        for b in [appleBtn, wechatBtn, phoneBtn, mailBtn]
        {
            b.frame = CGRect(x: 30, y: y, width: bw, height: 52)
            y += 68
        }
        skipBtn.frame = CGRect(x: 0, y: y + 6, width: w, height: 40)
        netLabel.frame = CGRect(x: 20, y: y + 48, width: w - 40, height: 44)
    }

    // MARK: - 苹果登录
    @objc func onApple()
    {
        if !netOK
        {
            self.alert("当前未连接网络，请稍后重试或先不注册")
            return
        }
        let req = ASAuthorizationAppleIDProvider().createRequest()
        req.requestedScopes = [.fullName, .email]
        let c = ASAuthorizationController(authorizationRequests: [req])
        c.delegate = self
        c.presentationContextProvider = self
        c.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization)
    {
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = cred.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else { return }
        var name = "Apple 用户"
        if let fn = cred.fullName?.givenName { name = fn }
        postAppleLogin(token: token, name: name, user: cred.user)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error)
    {
        alert("苹果登录未完成：\(error.localizedDescription)")
    }

    func postAppleLogin(token: String, name: String, user: String)
    {
        guard let url = URL(string: "https://www.xvqchinese.com/dsv2/txz/apple_login.php") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "token=\(token.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&name=\(name.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&user=\(user.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"
        req.httpBody = body.data(using: .utf8)
        let t = URLSession.shared.dataTask(with: req) { d, _, e in
            let bodyText = d.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            print("apple_login resp: \(bodyText) err: \(String(describing: e))")
            DispatchQueue.main.async {
                if bodyText.contains("\"ok\":1")
                {
                    KeychainLogin.save(userId: user, name: name, kind: "apple")
                    self.finish()
                }
                else if let e = e
                {
                    self.alert("苹果登录提交失败：\(e.localizedDescription)")
                }
                else
                {
                    self.alert("苹果登录提交失败，服务器返回：\(bodyText.prefix(120))")
                }
            }
        }
        t.resume()
    }

    // MARK: - 其它入口
    @objc func onWeChat() { alert("微信登录即将开通，请先用 Apple 登录或手机号、邮箱注册") }

    @objc func onPhone()
    {
        let vc = CommonWebView(url: "https://www.xvqchinese.com/dsv2/txz/reg_ios.php", title: "注册", scalesPage: true)
        self.presentNav(vc)
    }

    @objc func onMail()
    {
        let vc = CommonWebView(url: "https://www.xvqchinese.com/dsv2/txz/login_ui_ios.php", title: "登录", scalesPage: true)
        self.presentNav(vc)
    }

    func presentNav(_ vc: UIViewController)
    {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(closeNav))
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = UIColor.white
        nav.navigationBar.tintColor = UIColor.black
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    @objc func closeNav()
    {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func onSkip()
    {
        KeychainLogin.saveGuest()
        finish()
    }

    func finish()
    {
        if let d = self.onDone { d() }
    }

    func alert(_ msg: String)
    {
        let a = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
        self.present(a, animated: true, completion: nil)
    }
}

class KeychainLogin
{
    static let suite = "group.DWIME_DS"

    static func save(userId: String, name: String, kind: String)
    {
        let d = UserDefaults(suiteName: suite)
        d?.set(userId, forKey: "acctId")
        d?.set(name, forKey: "acctName")
        d?.set(kind, forKey: "acctKind")
        d?.set(true, forKey: "acctDone")
    }

    static func saveGuest()
    {
        UserDefaults(suiteName: suite)?.set(true, forKey: "acctDone")
    }

    static func isDone() -> Bool
    {
        return UserDefaults(suiteName: suite)?.bool(forKey: "acctDone") ?? false
    }
}
