//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/

class CommandBanner: BannerView
{
    //var phraseBt : UIButton = UIButton()
    var smileBt : UIButton = UIButton()
    var caretBt : UIButton = UIButton()
    
    var settingBt : UIButton = UIButton()
    var switchBt : UIButton = UIButton()
    var closeBt : UIButton = UIButton()

    var moveLBt : UIButton = UIButton()
    var moveRBt : UIButton = UIButton()
    
    var curPoint: CGPoint?
    var handler: AnyObject!

    init(handler: AnyObject)
    {
        self.handler = handler
        super.init(frame: CGRect.zero)
        self.backgroundColor = KeyboardColor.mCommandBColor // UIColor.clear//UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.3)
        self.isUserInteractionEnabled = true
        self.isOpaque = false
        //self.alpha = 0.5
        
        self.smileBt.setBackgroundImage(Globals.images["sml"], for: .normal)
        self.smileBt.setBackgroundImage(Globals.images["smlp"], for: .selected)
        self.smileBt.setBackgroundImage(Globals.images["smlp"], for: .highlighted)
        self.smileBt.sizeToFit()
        
        /*
        self.phraseBt.setBackgroundImage(Globals.images["phr"], for: .normal)
        self.phraseBt.setBackgroundImage(Globals.images["phrp"], for: .selected)
        self.phraseBt.setBackgroundImage(Globals.images["phrp"], for: .highlighted)
        self.phraseBt.sizeToFit()*/

        self.caretBt.setBackgroundImage(Globals.images["car"], for: .normal)
        self.caretBt.setBackgroundImage(Globals.images["carp"], for: .selected)
        self.caretBt.setBackgroundImage(Globals.images["carp"], for: .highlighted)
        self.caretBt.sizeToFit()
        
        self.settingBt.setBackgroundImage(Globals.images["set"], for: .normal)
        self.settingBt.setBackgroundImage(Globals.images["setp"], for: .selected)
        self.settingBt.setBackgroundImage(Globals.images["setp"], for: .highlighted)
        self.settingBt.sizeToFit()
        
        self.switchBt.setBackgroundImage(Globals.images["kbd"], for: .normal)
        self.switchBt.setBackgroundImage(Globals.images["kbdp"], for: .selected)
        self.switchBt.setBackgroundImage(Globals.images["kbdp"], for: .highlighted)
        self.switchBt.sizeToFit()
        
        self.closeBt.setBackgroundImage(Globals.images["hid"], for: .normal)
        self.closeBt.setBackgroundImage(Globals.images["hidp"], for: .selected)
        self.closeBt.setBackgroundImage(Globals.images["hidp"], for: .highlighted)
        self.closeBt.sizeToFit()
        
        self.moveLBt.setTitle("  <<<<< < <  ", for: .normal)
        self.moveLBt.sizeToFit()
        self.moveRBt.setTitle("  > > >>>>>  ", for: .normal)
        self.moveRBt.sizeToFit()
        
        self.addSubview(self.settingBt)
        self.addSubview(self.switchBt)
        self.addSubview(self.closeBt)
        //self.addSubview(self.phraseBt)
        self.addSubview(self.smileBt)
        self.addSubview(self.caretBt)

        // 设置按钮处理函数，处理器在 KeyboardViewController
        self.settingBt.addTarget(self.handler, action: Selector("doSetting"), for: .touchUpInside)
        self.switchBt.addTarget(self.handler, action: Selector("doSwitch"), for: .touchUpInside)
        self.closeBt.addTarget(self.handler, action: Selector("doHide"), for: .touchUpInside)
        //self.phraseBt.addTarget(self.handler, action: Selector("doPhrase"), for: .touchUpInside)
        self.smileBt.addTarget(self.handler, action: Selector("doSmile"), for: .touchUpInside)
        self.caretBt.addTarget(self.handler, action: Selector("doCaret"), for: .touchUpInside)
        self.caretBt.isUserInteractionEnabled = false

        self.moveLBt.addTarget(self.handler, action: Selector("caretMoveL"), for: .touchDragInside)
        self.moveRBt.addTarget(self.handler, action: Selector("caretMoveR"), for: .touchDragInside)
        self.moveLBt.isUserInteractionEnabled = false
        self.moveRBt.isUserInteractionEnabled = false
    }
    
    deinit
    {
        self.End()
    }
    
    func End()
    {
        self.curPoint = nil
        self.handler = nil
        //self.phraseBt.removeFromSuperview()
        self.smileBt.removeFromSuperview()
        self.caretBt.removeFromSuperview()
        self.settingBt.removeFromSuperview()
        self.switchBt.removeFromSuperview()
        self.closeBt.removeFromSuperview()
    }
    
    
    func show()
    {
        if self.isHidden
        {
            self.backgroundColor = KeyboardColor.mCommandBColor
        }
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    func endCaret()
    {
        //self.phraseBt.isHidden = false
        self.smileBt.isHidden = false
        self.settingBt.isHidden = false
        self.switchBt.isHidden = false
        self.closeBt.isHidden = false
        self.moveRBt.removeFromSuperview()
        self.moveLBt.removeFromSuperview()
    }
    
    func beginCaret()
    {
        self.addSubview(self.moveLBt)
        self.addSubview(self.moveRBt)
        //self.phraseBt.isHidden = true
        self.smileBt.isHidden = true
        self.settingBt.isHidden = true
        self.switchBt.isHidden = true
        self.closeBt.isHidden = true
    }
    
    //override func draw(_ rect: CGRect) {}
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let bt = super.hitTest(point, with: event)
        if bt == self.caretBt
        {
            return self
        }
        return bt
    }
    
    // TODO: drag up control centre from bottom == stuck
    func handleControl(_ view: UIView?, controlEvent: UIControl.Event)
    {
        if let control = view as? UIControl
        {
            let targets = control.allTargets
            for target in targets
            { // TODO: Xcode crashes
                let actions = control.actions(forTarget: target, forControlEvent: controlEvent)
                if (actions != nil)
                {
                    for action in actions!
                {
                        let selector = Selector(action as String)
                        control.sendAction(selector, to: target, for: nil)
                    }
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first! as UITouch
        let position = touch.location(in: self)

        if CGRectContainsPoint(self.caretBt.frame, position)
        {
            self.curPoint = position
            self.caretBt.isHighlighted = true
            self.beginCaret()
        }
    }

    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first! as UITouch
        let position = touch.location(in: self)
        
        if CGRectContainsPoint(self.caretBt.frame, position)
        {
            self.curPoint = position
            self.caretBt.isHighlighted = true
            self.beginCaret()
        }
        
        if self.caretBt.isHighlighted
        {
            if self.curPoint != nil
            {
                if position.x < self.curPoint!.x
                {
                    if (self.curPoint!.x - position.x) >= 4
                    {
                        self.handleControl(self.moveLBt, controlEvent: .touchDragInside)
                        self.curPoint = position
                    }
                }
                else if position.x > self.curPoint!.x
                {
                    if (position.x - self.curPoint!.x) >= 4
                    {
                        self.handleControl(self.moveRBt, controlEvent: .touchDragInside)
                        self.curPoint = position
                    }
                }
            }
        }
    }



    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if self.caretBt.isHighlighted
        {
            self.caretBt.isHighlighted = false
            self.endCaret()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        if self.caretBt.isHighlighted
        {
            self.caretBt.isHighlighted = false
            self.endCaret()
        }
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let padding = self.frame.width/20
        
        self.settingBt.center.y = self.center.y
        self.settingBt.frame.origin.x = padding

        self.switchBt.center.y = self.center.y
        self.switchBt.center.x = self.center.x / 2 + padding
        
        self.caretBt.center.y = self.center.y
        self.caretBt.center.x = self.center.x
        
        //self.phraseBt.center.y = self.center.y
        //self.phraseBt.center.x = self.center.x + self.center.x / 2 - padding
        self.smileBt.center.y = self.center.y
        self.smileBt.center.x = self.center.x + self.center.x / 2 - padding

        self.closeBt.center.y = self.center.y
        self.closeBt.frame.origin.x = self.frame.width - self.closeBt.frame.width - padding
        
        self.moveLBt.center.y = self.center.y
        self.moveRBt.center.y = self.center.y
        self.moveLBt.frame.origin.x = self.caretBt.frame.origin.x - self.moveLBt.frame.width
        self.moveRBt.frame.origin.x = self.caretBt.frame.origin.x + self.caretBt.frame.width
    }
}
