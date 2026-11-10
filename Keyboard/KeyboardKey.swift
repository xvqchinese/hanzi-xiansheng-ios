//
//  KeyboardKey.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

// popup constraints have to be setup with the superview in mind; hence these callbacks
protocol KeyboardKeyProtocol {
    func frameForPopup(_ key: KeyboardKey, direction: Direction) -> CGRect
    func willShowPopup(_ key: KeyboardKey, direction: Direction) //may be called multiple times during layout
    func willHidePopup(_ key: KeyboardKey)
}

// properties: vibrancy alpha percentage, underlay color, corner radius, graphics size

@objcMembers
class KeyboardKey: UIControl, KeyboardView {
    
    var delegate: KeyboardKeyProtocol?
    
    private var background: KeyboardKeyBackground!
    var label: UILabel!

    var popup: KeyboardKeyBackground?
    private var connector: KeyboardConnector?
    
    private var labelS1: UILabel?
    private var popupLabel: UILabel?

    
    var page: Int
    var isSwipeDown: Bool = false

    private var type: Key.KeyType
    //private var customColor: Bool = false
    private var showPop: Bool
    private var vibrancy: Bool = false
    
    var text: String
    {
        didSet
        {
            let temp: NSString = text as NSString

            if (temp.range(of: "`").length > 0)
            {
                let ary = temp.components(separatedBy: "`")
                
                let lb = ary[0].copy() as! NSString
                self.label.text = lb as String
                self.label.frame = self.bounds
                
                if ary.count >= 2
                {
                    self.setSmallLabel(ary[1].copy() as! String)
                }
                
                self.redrawText()
            }
            else
            {
                self.labelS1?.text = ""
                self.labelS1?.isHidden = true
                
                self.label.text = text
                self.label.frame = self.bounds
                self.redrawText()
            }
        }
    }
    
    var color: UIColor { didSet { updateColors() }}
    var textColor: UIColor { didSet { updateColors() }}
    var downColor: UIColor? { didSet { updateColors() }}
    var downTextColor: UIColor? { didSet { updateColors() }}
    
    var popupDirection: Direction?
    
    override var isEnabled: Bool { didSet { updateColors() }}
    override var isSelected: Bool
    {
        didSet
        {
            updateColors()
        }
    }
    override var isHighlighted: Bool
    {
        didSet
        {
            updateColors()
        }
    }
    
    var shape: Shape?
    {
        didSet
        {
            self.redrawShape()
            updateColors()
        }
    }
    
    var image: UIImageView?
    {
        didSet
        {
            self.redrawImage()
        }
    }
    
    override var frame: CGRect
    {
        didSet
        {
            self.redrawText()
        }
    }
    
    init(vibrancy: Bool, pop: Bool, type: Key.KeyType, page: Int)
    {
        self.label = UILabel()
        self.text = ""
        self.page = page
        self.type = type
        self.showPop = pop
        self.vibrancy = vibrancy
        
        self.color = KeyboardColor.mKeyColor // UIColor.white
        self.textColor = KeyboardColor.mKeyTxtColor  // UIColor.black
        self.popupDirection = nil
        
        
        super.init(frame: CGRect.zero/*frame*/)

        self.background = KeyboardKeyBackground(frame: CGRect.zero)
        self.addSubview(self.background)

        self.label.textAlignment = .center
        self.label.font = self.label.font.withSize(18)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.isUserInteractionEnabled = false
        self.addSubview(self.label)
        
        self.clipsToBounds = false
    }
    
    required init(coder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    deinit
    {
        //  removeAll 就会调用这里
        self.delegate = nil
        self.shape?.removeFromSuperview()
        self.shape?.End()
        self.shape = nil
        self.background.removeFromSuperview()
        self.background = nil
        self.popup?.removeFromSuperview()
        self.popup = nil
        self.connector?.removeFromSuperview()
        self.connector = nil
        self.popupLabel?.removeFromSuperview()
        self.popupLabel = nil        
        self.popupDirection = nil
		self.image?.removeFromSuperview()
		self.image = nil
        self.labelS1?.removeFromSuperview()
        self.labelS1 = nil
    }
    
    func setSmallLabel(_ str: String)
    {
        if self.labelS1 == nil
        {
            self.labelS1 = UILabel()
            let algCenter : Bool = (self.type == Key.KeyType.Character || self.type == Key.KeyType.Mode2SmartEN || self.type == Key.KeyType.Mode2CommonEN)
            self.labelS1?.textAlignment = (algCenter ? .center : .right)
            self.labelS1?.font = self.labelS1!.font.withSize(9)
            self.labelS1?.adjustsFontSizeToFitWidth = true
            self.labelS1?.isUserInteractionEnabled = false
            self.addSubview(self.labelS1!)
        }
            
        self.labelS1?.text = str
        self.labelS1?.isHidden = false

        let tune : NSString = "ˋˇˊ"
        if tune.range(of: str).length > 0
        {
            self.labelS1?.font = self.labelS1!.font.withSize(20)
            self.labelS1?.textColor = UIColor.red
        }
        else
        {
            self.labelS1?.textColor = KeyboardColor.mSmallTxtColor
        }
    }

    func setTarget(_ remove: Bool, target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControl.Event)
    {
        if remove
        {
            self.removeTarget(target, action: action, for: controlEvents)
        }
        else
        {
            self.addTarget(target, action: action, for: controlEvents)
        }
    }
    
    func getType() -> Key.KeyType
    {
        return self.type
    }

    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let superview = background.superview
        {
            self.background.frame = superview.bounds
        }
        
        if self.labelS1 == nil || self.labelS1!.isHidden
        {
            self.label.frame = self.bounds
        }
        else
        {
            self.label.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height * 0.7)
            if self.labelS1 != nil && !self.labelS1!.isHidden
            {
                self.labelS1!.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + self.bounds.height * 0.6, width: self.bounds.width - (self.type == Key.KeyType.Character ? 0 : 3), height: self.bounds.height * 0.4)
            }
        }
        
        if self.popup != nil && self.popupDirection == nil
        {
            self.popupDirection = Direction.Up
            
            self.layoutPopup(self.popupDirection!)
            self.configurePopup(self.popupDirection!)

            self.delegate?.willShowPopup(self, direction: self.popupDirection!)
            
            let upperLeftCorner = self.popup!.frame.origin
            var _ = self.superview!.convert(upperLeftCorner, from: self) // TODO: hack
        }
        
        self.redrawText()
        self.redrawShape()
        self.redrawImage()
    }
    
    func redrawText()
    {
    }
    
    func redrawShape()
    {
        if let shape = self.shape
        {
            self.text = ""
            shape.removeFromSuperview()
            self.addSubview(shape)
            
            let sizeRatio = CGFloat(1)
            let size = CGSize(width: self.bounds.width * sizeRatio, height: self.bounds.height * sizeRatio)
            shape.frame = CGRect(x: CGFloat((self.bounds.width - size.width) / 2.0), y: CGFloat((self.bounds.height - size.height) / 2.0), width: size.width, height: size.height)
            
            shape.setNeedsDisplay()
        }
    }
    
    func redrawImage()
    {
        if let image = self.image
        {
            self.text = ""
            image.removeFromSuperview()
            self.addSubview(image)
            
            let sizeRatio = CGFloat(1)
            let size = CGSize(width: self.bounds.width * sizeRatio, height: self.bounds.height * sizeRatio)
            image.frame = CGRect(x: CGFloat((self.bounds.width - size.width) / 2.0), y: CGFloat((self.bounds.height - size.height) / 2.0), width: size.width, height: size.height)
            
            image.contentMode = .scaleAspectFit
            image.setNeedsDisplay()
        }
    }
    
    func updateColors()
    {
        var keyboardViews: [KeyboardView] = [self.background]
        if self.popup != nil { keyboardViews.append(self.popup!) }
        if self.connector != nil { keyboardViews.append(self.connector!) }
        
        let switchColors = self.isHighlighted || self.isSelected
        
        for kv in keyboardViews
        {
            var keyboardView = kv
            keyboardView.color = (switchColors && self.downColor != nil ? self.downColor! : self.color)
        }
        
        if self.page == KbPage.M_Chn && (self.label.text == "Q" || self.label.text == "V" || self.label.text == "X")
        {
            self.label.textColor = UIColor.red
        }
        else
        {
            self.label.textColor = (switchColors && self.downTextColor != nil ? self.downTextColor! : self.textColor)
            self.shape?.color = (switchColors && self.downTextColor != nil ? self.downTextColor! : self.textColor)
        }
        
        if self.vibrancy
        {
            self.background.color = switchColors ? KeyboardColor.mFunKeyColor_hi : KeyboardColor.mFunKeyColor
        }
        else if !self.showPop
        {
            self.background.color = switchColors ? KeyboardColor.mKeyColor_hi : KeyboardColor.mKeyColor
        }
    }
    
    func layoutPopup(_ dir: Direction)
    {
        assert(self.popup != nil, "popup not found")
        
        if let popup = self.popup
        {
            if let delegate = self.delegate
            {
                let frame = delegate.frameForPopup(self, direction: dir)
                popup.frame = frame
                popupLabel?.frame = popup.bounds
            }
            else
            {
                popup.frame = CGRect.zero
                popup.center = self.center
            }
        }
    }
    
    func configurePopup(_ direction: Direction)
    {
        assert(self.popup != nil, "popup not found")
        
        self.background.attach(direction)
        self.popup!.attach(direction.opposite())
        
        let kv = self.background!
        let p = self.popup!
        
        self.connector?.removeFromSuperview()
        self.connector = KeyboardConnector(start: kv, end: p, startConnectable: kv, endConnectable: p, startDirection: direction, endDirection: direction.opposite())
        self.connector!.layer.zPosition = -1
        self.addSubview(self.connector!)
        
        if direction == Direction.Up
        {
            self.popup!.drawUnder = false
        }
    }
    
    func showPopup()
    {
        if self.popup == nil
        {
            let len: Int = self.label.text!.count
            let fontSize: CGFloat = len > 3 ? 30 : 40
            
            self.layer.zPosition = 0x2000
           
            let popup = KeyboardKeyBackground(frame: CGRect.zero)
            popup.cornerRadius = 9.0
            self.addSubview(popup)
            self.popup = popup
            let popupLabel = UILabel()
            popupLabel.textColor = KeyboardColor.mKeyTxtColor // UIColor.black
            popupLabel.textAlignment = self.label.textAlignment
            popupLabel.font = self.label.font.withSize(fontSize)
            popupLabel.frame = popup.bounds
            popupLabel.text = self.label.text
            popup.addSubview(popupLabel)
            self.popupLabel = popupLabel

            self.label.isHidden = true
        }
    }
    
    func hidePopup()
    {
        if self.popup != nil
        {
            self.delegate?.willHidePopup(self)
            
            self.popupLabel?.removeFromSuperview()
            self.popupLabel = nil
            
            self.connector?.removeFromSuperview()
            self.connector = nil
            
            self.popup?.removeFromSuperview()
            self.popup = nil
            
            self.label.isHidden = false
            self.background.attach(nil)
            
            self.layer.zPosition = 0
            
            self.popupDirection = nil
        }
    }
}





