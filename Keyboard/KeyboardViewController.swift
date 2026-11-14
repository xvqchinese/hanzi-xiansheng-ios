//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import CoreLocation
import MapKit

//func metric(_ name: String) -> CGFloat { return CGFloat(metrics[name]!) }

@objcMembers
class KeyboardViewController: UIInputViewController, KeyboardCandProtocol, CLLocationManagerDelegate
{
    
    let backspaceDelay: TimeInterval = 0.5
    let backspaceRepeat: TimeInterval = 0.05
    
    var heightConstraint: NSLayoutConstraint!
    var heightConstraintAdd: Bool = false
    var mResizeGrip: UIView?
    var mResizeStart: CGFloat?

    var engine: EngineService!
    var layout: KeyboardLayout!
    var mForwardingView: ForwardingView!
    var mBannerCmd: CommandBanner!
    
    var mBannerCand: SmallCand2?
    var mBigCandPanel: BigCandView2?
    var mSelectKB:   SelectKBView?
    var mSettingPanel: SettingView?
    var mPhrsPanel: PhrsView?
    var mCoinciding: CoincidingView?
    var mSmilePanel: SmileView?

    var backspaceDelayTimer: Timer?
    var backspaceRepeatTimer: Timer?
    var autoMoveFocusTimer: Timer?
    var hwTimer: Timer?
    var shiftWasMultitapped: Bool = false
    var oldBounds: CGRect?
    var oldTopBannerH: CGFloat = 0
    var candBounds: CGRect?
    var hwAssociateKey: String?
    var mHwQuery : UILabel? = nil
    var mHwQueryStringList : [String]? = nil
    var mBig5StringList : [String]? = nil
    var mLocation: CLLocationManager?
    var mComposingText:String?      // 预先上屏的字符串
    var mDiagLabel: UILabel? = nil  // 屏上诊断（临时）
    var mDiagText: String? = nil
    
    var lastPage: Int = KbPage.M_Chn              // 数字键盘返回时要用到
    var currentPage: Int
    {
        didSet
        {
            MyLog("------->> currentPage didSet")

            // add by lzl 20141017
            //self.unsetupKeys()
            
            RunTimeBegin()
            self.layout.initialize(currentPage)
            RunTimeEnd("layout.initialize")

            RunTimeBegin()
            self.layout.layoutTemp(currentPage)
            RunTimeEnd("layout.layoutTemp")

            RunTimeBegin()
            self.setupKeys()
            RunTimeEnd("setupKeys")
            // add by lzl 20141017
            
            self.engine.InitIM(currentPage)
            self.showDiag()
            self.closeCand()
            if IsEnglishKB(currentPage)
            {
                Globals.prefs.set(currentPage, forKey: "defaultEnIM")
            }            
            else if IsNeedEngine(currentPage)
            {
                Globals.prefs.set(currentPage, forKey: "defaultCnIM")
            }
            self.onModeChange(currentPage)
        }
    }
    
    var backspaceActive: Bool
    {
        get
        {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    
    enum ShiftState
    {
        case Disabled
        case Enabled
        case Locked
        
        func uppercase() -> Bool
        {
            switch self
            {
            case ShiftState.Disabled:
                return false
            case ShiftState.Enabled:
                return true
            case ShiftState.Locked:
                return true
            }
        }
    }
    var shiftState: ShiftState
    {
        didSet
        {
            switch shiftState
            {
            case .Disabled:
                self.updateKeyCaps(true)
            case .Enabled:
                self.updateKeyCaps(false)
            case .Locked:
                self.updateKeyCaps(false)
            }
        }
    }
    
    
    // TODO: why does the app crash if this isn't here?
    
    convenience init()
    {
        MyLog("------->> init()")
        RunTimeBegin()
        self.init(nibName: nil, bundle: nil)
        RunTimeEnd("init")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        MyLog("------->> init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)")
        
        KeyboardColor.Load()
        Globals.Load()
        
        self.currentPage = Globals.prefs.integer(forKey: "defaultCnIM") // KbPage.M_Chn
        self.shiftState = .Disabled
        self.engine = EngineService()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        RunTimeBegin()
        self.mForwardingView = ForwardingView(frame: CGRect.zero)
        self.mBannerCmd = self.banner_cmd()
        RunTimeEnd("init Banner")

        RunTimeBegin()
        self.layout = KeyboardLayout(model: Globals.keyboard, superview: self.mForwardingView)
        RunTimeEnd("init layout")

        RunTimeBegin()
        self.view.addSubview(self.mBannerCmd!)
        self.view.addSubview(self.mForwardingView)
        self.view.clipsToBounds = false
        self.view.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)

        self.mBannerCmd.show()
        self.mForwardingView.show()
        RunTimeEnd("init --> addSubview")
        
        RunTimeBegin()
        self.layout.initialize(self.currentPage)
        RunTimeEnd("init --- >> layout.initialize")
        self.setupKeys()
        self.onModeChange(self.currentPage)
    }
    
    
    required init(coder: NSCoder)
    {
        MyLog("------->> init(coder: NSCoder)")
        
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        IMEngine.dwimeOpenException()

        let dummyView = UILabel(frame:CGRect.zero)
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dummyView);
        
        let height : CGFloat = 400
        
        self.heightConstraint = NSLayoutConstraint(item:self.inputView!, attribute:.height,
                                    relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:0.0, constant:height)

        // 照安卓 KbResizeView：拖键盘上沿自由调整高度
        self.mResizeGrip = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 26))
        if let g = self.mResizeGrip
        {
            g.backgroundColor = UIColor.clear
            g.isUserInteractionEnabled = true
            let lab = UILabel(frame: g.bounds)
            lab.text = "︿"
            lab.textColor = UIColor(white: 0.55, alpha: 1)
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.textAlignment = .center
            lab.tag = 999
            g.addSubview(lab)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(KeyboardViewController.doResizeKb(_:)))
            g.addGestureRecognizer(pan)
            self.view.addSubview(g)
        }
        self.heightConstraint.priority = UILayoutPriority(999)
        // 键盘内面板改“大/中/小”后立刻重算高度
        NotificationCenter.default.addObserver(forName: Notification.Name("DWKbResize"), object: nil, queue: OperationQueue.main)
        { [weak self] _ in
            guard let s = self else { return }
            let h = s.getKbHeight(getOrientation())
            s.heightConstraint.constant = h
            if !s.heightConstraintAdd
            {
                s.inputView!.addConstraint(s.heightConstraint)
                s.heightConstraintAdd = true
            }
            s.preferredContentSize = CGSize(width: s.view.bounds.width, height: h)
            s.view.setNeedsUpdateConstraints()
            s.view.setNeedsLayout()
            s.view.layoutIfNeeded()
        }
    }
    
    deinit
    {
        MyLog("------->>KeyboardViewController --> deinit")
        self.End()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func openInHost(_ url: URL)
    {
        let sel = NSSelectorFromString("openURL:")
        var cur: UIResponder? = self
        while let c = cur
        {
            if c.responds(to: sel) { c.perform(sel, with: url); return }
            cur = c.next
        }
    }

    // MARK: - 屏上诊断（临时排障用，正式上架前删除）
    func showDiag()
    {
        // 诊断条已下线（送审版不再显示）
    }
    
    func layoutDiag()
    {
        guard let lab = mDiagLabel else { return }
        let w = self.view.bounds.width
        if w <= 0 { return }
        lab.frame = CGRect(x: 0, y: 0, width: w, height: 24)
        self.view.bringSubviewToFront(lab)
    }
    private func End()
    {
        MyLog("------->> End  ******* 释放 *******")

        if self.engine != nil
        {
            self.engine.End()
            self.engine = nil
        }

        if self.layout != nil
        {
            self.layout.End()
            self.layout = nil
        }
        
        if self.mForwardingView != nil
        {
            self.mForwardingView.removeFromSuperview()
            self.mForwardingView.End()
            self.mForwardingView = nil
        }

        if self.mBannerCmd != nil
        {
            self.mBannerCmd.removeFromSuperview()
            self.mBannerCmd.End()
            self.mBannerCmd = nil
        }
        
        if self.mHwQuery != nil
        {
            self.mHwQuery!.removeFromSuperview();
            self.mHwQuery = nil
        }

        self.closeSmallCand()
        self.closeSelectKB()
        self.closeSetting()
        self.closePhrase()
        self.closeBigCand()
        self.closeCoinciding()

        /*
        if self.keyboard != nil
        {
            self.keyboard.End()
            self.keyboard = nil
        }*/
        
        self.heightConstraint = nil
        self.oldBounds = nil
        self.candBounds = nil
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
        self.autoMoveFocusTimer = nil
        self.hwTimer = nil
        self.hwAssociateKey = nil
        self.mComposingText = nil
        self.mHwQueryStringList = nil
        self.mBig5StringList = nil
        self.mLocation = nil
        
        //self.unsetupKeys()
        Globals.End()
        KeyboardColor.End()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        MyLog("------->> viewWillDisappear")
        super.viewWillDisappear(animated)
        self.End()
    }
    
    override func dismissKeyboard()
    {
        MyLog("------->> dismissKeyboard")
        super.dismissKeyboard()
        self.End()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        MyLog("------->> viewDidDisappear")
        super.viewDidDisappear(animated)
        self.End()
    }
    
    override func updateViewConstraints()
    {
        MyLog("------->> updateViewConstraints")
        super.updateViewConstraints()
    }
    
    
    override func viewDidLayoutSubviews()
    {
        self.layoutDiag()
        MyLog("------->> viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        let kbHeight = getKbHeight(getOrientation())
        MyLog("[KBDBG] view=\(self.view.frame) input=\(String(describing: self.inputView?.frame)) kbH=\(kbHeight) gkb=\(String(describing: Globals.kbHeight))")
        if let g = self.mResizeGrip
        {
            g.frame = CGRect(x: self.view.frame.width/2 - 60, y: 0, width: 120, height: 26)
            g.layer.zPosition = 5000
        }
        let topBanner = (self.currentPage == KbPage.M_HW) ? (kbHeight / 6) : (kbHeight / 5)
        let kbWidth = Globals.singleHand ? (self.view.frame.width/5*4) : self.view.frame.width
        let fullRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: kbWidth, height: self.view.frame.height)
        
        // when a key gets a popup added, we don't want the entire layout to be redone
        if (self.oldBounds == nil || self.oldBounds! != fullRect || self.oldTopBannerH != topBanner)
        {
            MyLog("------->> viewDidLayoutSubviews --->>> set")
            RunTimeBegin()
            
            self.mForwardingView?.frame = CGRect(x: 0, y: topBanner, width: kbWidth, height: kbHeight - topBanner)
            self.layout?.layoutTemp(self.currentPage)
    
            self.mBannerCmd?.frame = CGRect(x: 0, y: 0, width: kbWidth, height: topBanner)

            self.oldBounds = fullRect
            self.oldTopBannerH = topBanner;
            self.candBounds = CGRect(x: 0, y: 0, width: kbWidth, height: topBanner)
            RunTimeEnd("viewDidLayoutSubviews")
        }
        
        if self.mBannerCand != nil
        {
            self.mBannerCand?.frame = CGRect(x: 0, y: 0, width: kbWidth, height: topBanner)
        }
        if self.mBigCandPanel != nil
        {
            self.mBigCandPanel?.frame = fullRect // 全屏
        }
        if (self.mForwardingView != nil && self.mForwardingView.enableHandWriting)
        {
            self.mForwardingView?.hwRect = self.layout?.getHandWritingRect(true)
        }
        if (self.mCoinciding != nil && IsNeedCoinciding(self.currentPage))
        {
            self.mCoinciding!.frame = self.layout.getCoincidingRect()
        }
        if (self.mSettingPanel != nil)
        {
            self.mSettingPanel!.frame = CGRect(x: 0, y: topBanner, width: kbWidth, height: kbHeight - topBanner)//self.view.frame // 全屏
        }
        if (self.mPhrsPanel != nil)
        {
            self.mPhrsPanel!.frame = fullRect
        }
        if (self.mSelectKB != nil)
        {
            self.mSelectKB!.frame = CGRect(x: 0, y: topBanner, width: kbWidth, height: kbHeight - topBanner)
        }
        if (self.mSmilePanel != nil)
        {
            self.mSmilePanel!.frame = CGRect(x: 0, y: topBanner, width: kbWidth, height: kbHeight - topBanner)
        }
        
        if (self.mHwQuery != nil)
        {
            self.mHwQuery!.frame.origin.x = 10
            self.mHwQuery!.frame.origin.y = topBanner
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        MyLog("------->> viewWillAppear")
        super.viewWillAppear(animated)
        
        // 每次出现都重读设置，保证 App 里改“键盘高度”后即时生效
        Globals.Load()
        if self.heightConstraint != nil
        {
            let h = getKbHeight(getOrientation())
            self.heightConstraint.constant = h
            self.preferredContentSize = CGSize(width: self.view.bounds.width, height: h)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
            if !self.heightConstraintAdd
            {
                self.inputView!.addConstraint(self.heightConstraint)
                self.heightConstraintAdd = true
            }
        //}
        //else
        //{
            // 横屏不改高度
        //}
    }

    override func viewDidAppear(_ animated: Bool)
    {
        MyLog("------->> viewDidAppear")
        super.viewDidAppear(animated)
        
        self.engine.InitIM(self.currentPage)
        self.showDiag()
    }
    
    // TODO: the new size "snaps" into place on rotation, which I believe is related to performance
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
    {
        MyLog("------->> willRotateToInterfaceOrientation")
        self.oldBounds = nil  // 这里可以使界面重新布局
        //if toInterfaceOrientation.isPortrait
        //{
            if !self.heightConstraintAdd
            {
                self.heightConstraint.constant = getKbHeight(toInterfaceOrientation)
                self.inputView!.addConstraint(self.heightConstraint)
                self.heightConstraintAdd = true
            }
            else
            {
                self.heightConstraint.constant = getKbHeight(toInterfaceOrientation)
            }
        //}
        //else
        //{
            // 横屏不改高度
        //}
        
        self.mForwardingView.reset()
    }
    
    @objc func doResizeKb(_ g: UIPanGestureRecognizer)
    {
        let screenH = UIScreen.main.bounds.height
        let cur = getKbHeight(getOrientation())
        switch g.state
        {
        case .began:
            self.mResizeStart = cur
        case .changed:
            let move = g.translation(in: self.view).y
            var h = (self.mResizeStart ?? cur) - move
            // 照安卓：竖屏 25%~60%（安卓默认 35%）
            let lo = screenH * 0.25, hi = screenH * 0.60
            h = min(max(h, lo), hi)
            self.heightConstraint.constant = h
            self.preferredContentSize = CGSize(width: self.view.bounds.width, height: h)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        case .ended, .cancelled:
            let frac = Double(self.heightConstraint.constant / screenH)
            let gp = UserDefaults(suiteName: "group.DWIME_DS") ?? UserDefaults.standard
            gp.set(CGFloat(frac), forKey: "kbheight")
            gp.synchronize()
            Globals.Update()
        default:
            break
        }
    }

    func getKbHeight(_ toInterfaceOrientation: UIInterfaceOrientation) -> CGFloat
    {
        Globals.Load()   // 每次取高度前重读设置，改了大中小立刻生效
        let h = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let w = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let r = h / w
        var ret: CGFloat = 0;
        
        if toInterfaceOrientation.isPortrait
        {
            if r <= 1.5
            {
                ret = (h * 0.30) * r // ipa=1.33, iphone=1.5, 1.77
            }
            else
            {
                ret = (h * 0.25) * r // ipa=1.33, iphone=1.5, 1.77
            }
        }
        else
        {
            if r <= 1.5
            {
                ret = (w * 0.40) * r // ipa=1.33, iphone=1.5, 1.77
            }
            else
            {
                ret = (w * 0.35) * r // ipa=1.33, iphone=1.5, 1.77
            }
        }
        
        // 大/中/小 直接按屏幕百分比：0.60 / 0.50 / 0.40
        let frac: CGFloat = Globals.kbHeight ?? 0.5
        if frac > 0.2 && frac <= 0.75
        {
            let screenH = UIScreen.main.bounds.height
            if toInterfaceOrientation.isPortrait { return screenH * frac }
            return screenH * frac * 0.85
        }
        if self.currentPage == KbPage.M_HW
        {
            return ret * Globals.kbHeight * 1.1 /*放大倍数*/
        }
        return ret * Globals.kbHeight /*放大倍数*/
    }
    
    func setupKey(_ remove:Bool, _ key: Key)
    {
        let showOptions: UIControl.Event = [.touchDown, .touchDragInside, .touchDragEnter]
        let hideOptions: UIControl.Event = [.touchUpInside, .touchUpOutside, .touchDragOutside]
        let cancelEvents: UIControl.Event = [UIControl.Event.touchUpInside, UIControl.Event.touchUpInside, UIControl.Event.touchDragExit, UIControl.Event.touchUpOutside, UIControl.Event.touchCancel, UIControl.Event.touchDragOutside]
        
        let keyView = self.layout.viewForKey(key) // TODO: check
        
        switch key.type
        {
        case Key.KeyType.KeyboardChange:
            keyView?.setTarget(remove, target: self, action: "advanceToNextInputMode", forControlEvents: .touchUpInside)
            
        case Key.KeyType.Backspace:
            keyView?.setTarget(remove, target: self, action: "backspaceDown:", forControlEvents: .touchDown)
            keyView?.setTarget(remove, target: self, action: "backspaceUp:", forControlEvents: cancelEvents)
            
        case Key.KeyType.Shift:
            keyView?.setTarget(remove, target: self, action: Selector("shiftDown:"), forControlEvents: .touchUpInside)
            keyView?.setTarget(remove, target: self, action: Selector("shiftDoubleTapped:"), forControlEvents: .touchDownRepeat)

        case Key.KeyType.Mode2PopupSymb:
            keyView?.setTarget(remove, target: self, action: Selector("modeChangePopupSymb"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2T9_123:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2T9_123"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2123_CN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2123_CN"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2123_EN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2123_EN"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2Eng:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2Eng"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2Sym_CN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2Sym_CN"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2Sym_EN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2Sym_EN"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2Chn:
            keyView?.setTarget(remove, target: self, action: Selector("modeChange2Chn"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.ModeRet_Chn:
            keyView?.setTarget(remove, target: self, action: Selector("modeReturnChn"), forControlEvents: .touchUpInside)

        case Key.KeyType.ModeRet_Auto:
            keyView?.setTarget(remove, target: self, action: Selector("modeReturnAuto"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.ModeRet_Eng:
            keyView?.setTarget(remove, target: self, action: Selector("modeReturnEng"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2CommonEN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChangeCommonEng"), forControlEvents: .touchUpInside)
            
        case Key.KeyType.Mode2SmartEN:
            keyView?.setTarget(remove, target: self, action: Selector("modeChangeSmartEng"), forControlEvents: .touchUpInside)
            
        default:
            break
        }
        if key.hasOutput
        {
            keyView?.setTarget(remove, target: self, action: "keyPressedHelper:", forControlEvents: .touchUpInside)
        }
        
        if key.showPop && (key.type == Key.KeyType.Character || key.type == Key.KeyType.Period)
        {
            keyView?.setTarget(remove, target: keyView, action: Selector("showPopup"), forControlEvents: showOptions)
            keyView?.setTarget(remove, target: keyView, action: Selector("hidePopup"), forControlEvents: hideOptions)
        }
        
        if key.type != Key.KeyType.Shift
        {
            keyView?.setTarget(remove, target: self, action: Selector("highlightKey:"), forControlEvents: showOptions)
            keyView?.setTarget(remove, target: self, action: Selector("unHighlightKey:"), forControlEvents: hideOptions)
        }
    }
    
    /*
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    BUG NOTE
    None of the UIContentContainer methods are called for this controller.
    */
    //override func viewWillTransitionToSize(_ size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //
    // 分配按键功能
    //
    //}
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func setupKeys()
    {
        let page = Globals.keyboard.pages[self.currentPage]
        for rowKeys in page.rows
        {
            for key in rowKeys
            {
                self.setupKey(false, key)
            }
        }
    }
    
    /*
    private func unsetupKeys()
    {
        // 不缓冲 key 了，所以也不用 unsetup
        for page in Globals.keyboard.pages
        {
            for rowKeys in page.rows
            {
                for key in rowKeys
                {
                    self.setupKey(true, key: key)
                }
            }
        }
    }*/
    
    override func didReceiveMemoryWarning()
    {
        MyLog("------->> didReceiveMemoryWarning ************** 注意 **************")

        super.didReceiveMemoryWarning()
        //self.view.backgroundColor = UIColor.red
        self.mBannerCmd.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?)
    {
        MyLog("------->> textWillChange")
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?)
    {
        MyLog("------->> textDidChange")
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    func updateReturnKey()
    {
        if let proxy = self.textDocumentProxy as UITextInputTraits?
        {
            var title: String = "return"

            MyLog("------->> updateReturnKey ---->> Value =  \(proxy.returnKeyType?.rawValue)")
            
            if proxy.returnKeyType == UIReturnKeyType.go
            {
                title = "Go"
            }
            if proxy.returnKeyType == UIReturnKeyType.google
            {
                title = "Google"
            }
            if proxy.returnKeyType == UIReturnKeyType.join
            {
                title = "Join"
            }
            if proxy.returnKeyType == UIReturnKeyType.next
            {
                title = "Next"
            }
            if proxy.returnKeyType == UIReturnKeyType.route
            {
                title = "Route"
            }
            if proxy.returnKeyType == UIReturnKeyType.search
            {
                title = "Search"
            }
            if proxy.returnKeyType == UIReturnKeyType.send
            {
                title = "Send"
            }
            if proxy.returnKeyType == UIReturnKeyType.yahoo
            {
                title = "Yahoo"
            }
            if proxy.returnKeyType == UIReturnKeyType.done
            {
                title = "Done"
            }
            if proxy.returnKeyType == UIReturnKeyType.emergencyCall
            {
                title = "Call"
            }
            let page = Globals.keyboard.pages[self.currentPage]
            for rowKeys in page.rows
            {
                for key in rowKeys
                {
                    let keyView = self.layout.viewForKey(key)
                    if keyView != nil && keyView!.getType() == Key.KeyType.Return && keyView!.text != title
                    {
                        keyView!.text = title
                        break;
                    }
                }
            }
        }
    }
    
    
    @objc func highlightKey(_ sender: KeyboardKey)
    {
        if !sender.isHighlighted && Globals.accessOpen
        {
            /*
            if Globals.vibrate
            {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }**/
            Globals.Load()
            if Globals.sound
            {
                AudioServicesPlaySystemSound(1104)
            }
        }
        sender.isHighlighted = true
    }
    
    @objc func unHighlightKey(_ sender: KeyboardKey)
    {
        sender.isHighlighted = false
    }
    
    func keyPressedHelper(_ sender: KeyboardKey)
    {
        // alas, this doesn't seem to work yet
        UIDevice.current.playInputClick()
        
        if let key = self.layout.keyForView(sender)
        {
            self.keyPressed(key, isSwipeDown: sender.isSwipeDown)
            sender.isSwipeDown = false
        }
        
        // 英文状态下：shift 按下了，要还原它
        if self.shiftState == ShiftState.Enabled && IsEnglishKB(self.currentPage)
        {
            self.shiftState = ShiftState.Disabled

            for (_, key) in self.layout.modelToView
            {
                if key.page == self.currentPage && key.isHighlighted == true && key.getType() == Key.KeyType.Shift
                {
                    key.isHighlighted = false
                }
            }
        }
    }
    
    func cancelBackspaceTimers()
    {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    func backspaceDown(_ sender: KeyboardKey)
    {
        self.cancelBackspaceTimers()
        
        // first delete
        UIDevice.current.playInputClick()
        
        if let textDocumentProxy = self.textDocumentProxy as UIKeyInput?
        {
            let keyBack = Key(.Backspace)
            if !self.MyKeyPressed(keyBack, repeatCount: 0, isSwipeDown: false)
            {
                textDocumentProxy.deleteBackward()
            }
        }
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = Timer.scheduledTimer(timeInterval: backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    func backspaceUp(_ sender: KeyboardKey)
    {
        self.cancelBackspaceTimers()
    }
    
    @objc func backspaceDelayCallback()
    {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceRepeat, target: self, selector: Selector("backspaceRepeatCallback"), userInfo: nil, repeats: true)
    }
    
    @objc func backspaceRepeatCallback()
    {
        if let textDocumentProxy = self.textDocumentProxy as UIKeyInput?
        {
            let keyBack = Key(.Backspace)
            if !self.MyKeyPressed(keyBack, repeatCount: 0, isSwipeDown: false)
            {
                textDocumentProxy.deleteBackward()
            }
        }
    }
    
    @objc func shiftDown(_ sender: KeyboardKey)
    {
        if self.shiftWasMultitapped
        {
            self.shiftWasMultitapped = false
            return
        }
        
        switch self.shiftState
        {
        case .Disabled:
            self.shiftState = .Enabled
            sender.isHighlighted = true
        case .Enabled:
            self.shiftState = .Disabled
            sender.isHighlighted = false
        case .Locked:
            self.shiftState = .Disabled
            sender.isHighlighted = false
        }
        
        (sender.shape as? ShiftShape)?.withLock = false
    }
    
    @objc func shiftDoubleTapped(_ sender: KeyboardKey)
    {
        self.shiftWasMultitapped = true
        
        switch self.shiftState
        {
        case .Disabled:
            self.shiftState = .Locked
            sender.isHighlighted = true
        case .Enabled:
            self.shiftState = .Locked
            sender.isHighlighted = true
        case .Locked:
            self.shiftState = .Disabled
            sender.isHighlighted = false
        }
        
        (sender.shape as? ShiftShape)?.withLock = (self.shiftState == .Locked)
    }
    
    func updateKeyCaps(_ lowercase: Bool)
    {
        if IsEnglishKB(self.currentPage)
        {
            for (model, key) in self.layout.modelToView
            {
                if key.page == self.currentPage
                {
                    key.text = model.keyCapForCase(!lowercase)
                }
            }
        }
    }

    func onModeChange(_ newMode: Int)
    {
        self.shiftState = .Disabled
        
        if IsNeedCoinciding(newMode)
        {
            self.showCoinciding()
            //self.view.setNeedsLayout()
        }
        else
        {
            self.closeCoinciding()
        }
        
        //-------------------------------------------------------
        // 允许不同模式高度不同
        //-------------------------------------------------------
        self.heightConstraint.constant = getKbHeight(getOrientation())
        //-------------------------------------------------------
        //-------------------------------------------------------

        if newMode == KbPage.M_HW
        {
            self.view.setNeedsLayout()
        }
        else
        {
            self.mHwQuery?.removeFromSuperview()
            self.mHwQuery = nil
        }
        self.mForwardingView.onModeChange(newMode, handler: self)
    }
    
    func doHide()
    {
        self.dismissKeyboard()
    }
    
    func hideKeyboard()
    {
        self.mForwardingView.hide()
        self.closeCoinciding()
        self.mHwQuery?.isHidden = true
    }

    func showKeyboard()
    {
        self.mForwardingView.show()
        if IsNeedCoinciding(self.currentPage)
        {
            self.showCoinciding()
        }
        if self.currentPage == KbPage.M_HW
        {
            self.mHwQuery?.isHidden = false
        }
    }

    func keyPressed(_ key: Key, isSwipeDown: Bool) {}
}

//// does not work; drops CPU to 0% when run on device
//extension UIInputView: UIInputViewAudioFeedback {
//    public var enableInputClicksWhenVisible: Bool {
//        return true
//    }
//}
