//
//  KeyboardLayout.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/25/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

// TODO: need to rename, consolidate, and define terms
struct layoutConstants
{
    static let landscapeRatio: CGFloat = 2
    
    // side edges increase on 6 in portrait
    static let sideEdgesPortraitArray: [CGFloat] = [3, 4]
    static let sideEdgesPortraitWidthThreshholds: [CGFloat] = [400]
    static let sideEdgesLandscape: CGFloat = 3
    
   
    // key gaps have weird and inconsistent rules
    static let keyGapPortraitNormal: CGFloat = 6
    static let keyGapPortraitSmall: CGFloat = 5
    static let keyGapPortraitNormalThreshhold: CGFloat = 350
    static let keyGapPortraitUncompressThreshhold: CGFloat = 350
    static let keyGapLandscapeNormal: CGFloat = 6
    static let keyGapLandscapeSmall: CGFloat = 5
    // TODO: 5.5 row gap on 5L
    // TODO: wider row gap on 6L
    static let keyCompressedThreshhold: Int = 11

    static let popupGap: CGFloat = 8 // TODO: not exactly precise
    static let popupWidthIncrement: CGFloat = 26
    static let popupTotalHeightArray: [CGFloat] = [102, 108, 110, 110, 120, 120, 130]
    static let popupTotalHeightDeviceWidthThreshholds: [CGFloat] = [350, 400, 500, 600, 700, 800]
    
    static func sideEdgesPortrait(_ width: CGFloat) -> CGFloat
    {
        return self.findThreshhold(self.sideEdgesPortraitArray, threshholds: self.sideEdgesPortraitWidthThreshholds, measurement: width)
    }

    
    static func keyGapPortrait(_ width: CGFloat, rowCharacterCount: Int) -> CGFloat
    {
        let compressed = (rowCharacterCount >= self.keyCompressedThreshhold)
        if compressed
        {
            if width >= self.keyGapPortraitUncompressThreshhold
            {
                return self.keyGapPortraitNormal
            }
            else
            {
                return self.keyGapPortraitSmall
            }
        }
        else
        {
            return self.keyGapPortraitNormal
        }
    }
    static func keyGapLandscape(_ width: CGFloat, rowCharacterCount: Int) -> CGFloat
    {
        let compressed = (rowCharacterCount >= self.keyCompressedThreshhold)

        if compressed
        {
            return self.keyGapLandscapeSmall
        }
        else
        {
            return self.keyGapLandscapeNormal
        }
    }

    static func popupTotalHeight(_ deviceWidth: CGFloat) -> CGFloat
    {
        return self.findThreshhold(self.popupTotalHeightArray, threshholds: self.popupTotalHeightDeviceWidthThreshholds, measurement: deviceWidth)
    }
    
    static func findThreshhold(_ elements: [CGFloat], threshholds: [CGFloat], measurement: CGFloat) -> CGFloat
    {
        assert(elements.count == threshholds.count + 1, "elements and threshholds do not match")
        return elements[self.findThreshholdIndex(threshholds, measurement: measurement)]
    }
    static func findThreshholdIndex(_ threshholds: [CGFloat], measurement: CGFloat) -> Int
    {
        for (i, threshhold) in threshholds.reversed().enumerated()
        {
            if measurement >= threshhold
            {
                let actualIndex = threshholds.count - i
                return actualIndex
            }
        }
        return 0
    }
}

let globalColors: [String:UIColor] =
[
    "lightColor":       UIColor.white,
    "lightShadowColor": UIColor(hue: (220/360.0), saturation: 0.04, brightness: 0.56, alpha: 1),
    "lightTextColor":   UIColor.black,
    "darkColor":        UIColor(hue: (217/360.0), saturation: 0.09, brightness: 0.75, alpha: 1),
    "darkShadowColor":  UIColor(hue: (220/360.0), saturation: 0.04, brightness: 0.56, alpha: 1),
    "darkTextColor":    UIColor.white,
    "blueColor":        UIColor(hue: (211/360.0), saturation: 1.0, brightness: 1.0, alpha: 1),
    "blueShadowColor":  UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.43, alpha: 1),
    "borderColor":      UIColor(hue: (214/360.0), saturation: 0.04, brightness: 0.65, alpha: 1.0)
]

// handles the layout for the keyboard, including key spacing and arrangement
class KeyboardLayout: KeyboardKeyProtocol
{
    
    dynamic var colors: [String:UIColor]
    {
        get
        {
            return globalColors
        }
    }
    
    var model: Keyboard!
    var superview: UIView!
    var modelToView: [Key:KeyboardKey] = [:]
    var viewToModel: [KeyboardKey:Key] = [:]
    
    //private var cacheKeys: [String:KeyboardKey] = [:]     // specialButton
    
    
    init(model: Keyboard, superview: UIView)
    {
        self.model = model
        self.superview = superview
    }
    
    deinit
    {
        self.End()
    }
    
    // add by lzl 20141017
    private func clear()
    {
        for kView in self.modelToView
        {
            kView.1.removeFromSuperview()
        }
        self.modelToView.removeAll(keepingCapacity: false)
        self.viewToModel.removeAll(keepingCapacity: false)
        
        //self.cacheKeys.removeAll(keepingCapacity: false) // ?????测试中： 速度可以的话就清，不然永久保留
    }
    
    func End()
    {
        self.clear()
        //self.cacheKeys.removeAll(keepingCapacity: false)
        self.model = nil
        self.superview = nil
    }
    
    func initialize(_ page: Int)
    {
        //assert(!self.initialized, "already initialized")
        
        self.clear()
        self.createViews(self.model, page)
    }
    
    func viewForKey(_ model: Key) -> KeyboardKey?
    {
        return self.modelToView[model]
    }
    
    func keyForView(_ key: KeyboardKey) -> Key?
    {
        return self.viewToModel[key]
    }
    
    func setColorsForKey(_ key: KeyboardKey)
    {
        switch key.getType()
        {
        case
        Key.KeyType.Character,
        Key.KeyType.SpecialCharacter,
        Key.KeyType.Period:
            key.color = KeyboardColor.mKeyColor // colors["lightColor"]!
            key.textColor = KeyboardColor.mKeyTxtColor // colors["lightTextColor"]!
            //key.underColor = colors["lightShadowColor"]!
            //key.borderColor = colors["borderColor"]!
        case
        Key.KeyType.Space:
            key.color = KeyboardColor.mKeyColor // colors["lightColor"]!
            key.textColor = KeyboardColor.mKeyTxtColor // colors["lightTextColor"]!
            key.downColor = KeyboardColor.mKeyColor_hi // colors["darkColor"]!
            //key.underColor = colors["lightShadowColor"]!
            //key.borderColor = colors["borderColor"]!
        case
        Key.KeyType.Return,
        Key.KeyType.Shift,
        Key.KeyType.Backspace:
            key.color =  KeyboardColor.mFunKeyColor // colors["darkColor"]!
            key.textColor = KeyboardColor.mFunKeyGraColor // colors["darkTextColor"]!
            key.downColor = KeyboardColor.mFunKeyColor_hi // colors["lightColor"]!
            key.downTextColor = KeyboardColor.mKeyTxtColor // colors["lightTextColor"]!
            //key.underColor = colors["darkShadowColor"]!
            //key.borderColor = colors["borderColor"]!
            //key.downUnderColor = colors["lightShadowColor"]!
            
        case
        Key.KeyType.KeyboardChange:
            key.color = KeyboardColor.mFunKeyColor // colors["darkColor"]!
            key.textColor = KeyboardColor.mFunKeyTxtColor // colors["lightTextColor"]!
            key.downColor = KeyboardColor.mFunKeyColor_hi // colors["lightColor"]!
            //key.downUnderColor = colors["lightShadowColor"]!
            //key.underColor = colors["darkShadowColor"]!
            //key.borderColor = colors["borderColor"]!
        case
        Key.KeyType.Mode2T9_123,
        Key.KeyType.Mode2PopupSymb,
        Key.KeyType.Mode2123_CN,
        Key.KeyType.Mode2123_EN,
        Key.KeyType.Mode2Chn,
        Key.KeyType.Mode2Eng,
        Key.KeyType.Mode2Sym_CN,
        Key.KeyType.Mode2Sym_EN,
        Key.KeyType.ModeRet_Chn,
        Key.KeyType.ModeRet_Eng,
        Key.KeyType.ModeRet_Auto,
        Key.KeyType.Mode2CommonEN,
        Key.KeyType.Mode2SmartEN,
        Key.KeyType.Separate:
            key.color = KeyboardColor.mFunKeyColor // colors["darkColor"]!
            key.textColor = KeyboardColor.mFunKeyTxtColor // colors["lightTextColor"]!
            //key.underColor = colors["darkShadowColor"]!
            //key.borderColor = colors["borderColor"]!
        case Key.KeyType.Hidden:
            break
            
        }
    }

    private func getKeyFromCache(_ name: String, key: Key, page: Int) -> KeyboardKey?
    {
        /**
        if self.cacheKeys[name] != nil
        {
            return self.cacheKeys[name]
        }***/
        let keyRet: KeyboardKey = KeyboardKey(vibrancy: key.specialButton(), pop: key.showPop, type: key.type, page: page)

        keyRet.isEnabled = true
        if page == KbPage.M_SK9
        {
            keyRet.text = key.keyCapForCase(true) // 笔画要大写
        }
        else
        {
            keyRet.text = key.keyCapForCase(!IsEnglishKB(page))
        }
        keyRet.delegate = self
        setColorsForKey(keyRet)
        
        // font sizing
        switch keyRet.getType()
        {
        case
        Key.KeyType.Mode2123_CN,
        Key.KeyType.Mode2123_EN,
        Key.KeyType.Mode2Chn,
        Key.KeyType.Mode2Eng,
        Key.KeyType.Mode2Sym_CN,
        Key.KeyType.Mode2Sym_EN,
        Key.KeyType.ModeRet_Chn,
        Key.KeyType.ModeRet_Eng,
        Key.KeyType.Separate,
        Key.KeyType.Space,
        Key.KeyType.Return:
            keyRet.label.adjustsFontSizeToFitWidth = false
            keyRet.label.minimumScaleFactor = 0.1
            keyRet.label.font = keyRet.label.font.withSize(16)
        default:
            break
        }
        
        // shapes
        switch keyRet.getType()
        {
        case Key.KeyType.Shift:
            let shiftShape = ShiftShape()
            keyRet.shape = shiftShape
            
        case Key.KeyType.Backspace:
            let backspaceShape = BackspaceShape()
            keyRet.shape = backspaceShape

        case Key.KeyType.Return:
            let enterShape = EnterShape()
            keyRet.shape = enterShape
            
        case Key.KeyType.KeyboardChange:
            let globeShape = GlobeShape()
            keyRet.shape = globeShape
            
        case Key.KeyType.Mode2SmartEN:
            let sShape = UIImageView(image: Globals.images["bokc"])
            keyRet.image = sShape
            
        case Key.KeyType.Mode2CommonEN:
            let sShape = UIImageView(image: Globals.images["boko"])
            keyRet.image = sShape
        default:
            break
        }

        //self.cacheKeys[name] = keyRet
        
        return keyRet
    }

    func createViews(_ keyboard: Keyboard, _ curPage: Int)
    {
        let page = keyboard.pages[curPage]

        if true
        {
            let numRows = page.rows.count
            
            for i in 0...numRows
            {
                if (i < numRows)
                {
                    let numKeys = page.rows[i].count
                    
                    for j in 0...numKeys
                    {
                        
                        if (j < numKeys)
                        {
                            let key = page.rows[i][j]
                            
                            let keyView = self.getKeyFromCache("\(curPage)\(i)\(j)", key: key, page: curPage)
                        
                            if key.type != Key.KeyType.Hidden
                            {
                                self.superview.addSubview(keyView!)
                            }
                            self.modelToView[key] = keyView
                            self.viewToModel[keyView!] = key
                        }
                    }
                }
            }
        }
    }
    
    func getHandWritingRect(_ includeGap: Bool) -> CGRect
    {
        var r : CGRect = CGRect.zero
        var width : CGFloat = 0
        var height : CGFloat = 0
        var x : CGFloat = 0
        var y : CGFloat = 0xffff
        let gap: CGFloat = includeGap ? self.getGap(self.superview.bounds, page: KbPage.M_HW) : 0

        for (_, view) in self.modelToView.enumerated()
        {
            if view.1.getType() == Key.KeyType.Hidden
            {
                let f = view.1.frame
                
                width = f.size.width
                x = f.origin.x

                if height < f.origin.y + f.size.height
                {
                    height = f.origin.y + f.size.height
                }
                
                if y > f.origin.y
                {
                    y = f.origin.y
                }
            }
        }
        y -= gap
        height += gap
        width += gap
        r = CGRect(x: x, y: y, width: width, height: height - y)
        
        return r
    }

    func getCoincidingRect() -> CGRect
    {
        var r = self.getHandWritingRect(false)
        
        r.origin.y += self.superview.frame.origin.y
        return r
    }
    
    
    //////////////////////
    // LAYOUT FUNCTIONS //
    //////////////////////
    
    // TODO: temp
    func layoutTemp(_ curPage: Int)
    {
        self.layoutKeys(self.model, views: self.modelToView, bounds: self.superview.bounds, curPage: curPage)
    }
    
    func rounded(_ measurement: CGFloat) -> CGFloat
    {
        return round(measurement * UIScreen.main.scale) / UIScreen.main.scale
    }
    
    // 计算间隔
    private func getGap(_ bounds: CGRect, page: Int) -> CGFloat
    {
        return bounds.height / (20)
    }
    
    // 布局设置
    func layoutKeys(_ model: Keyboard, views: [Key:KeyboardKey], bounds: CGRect, curPage: Int)
    {
        let isLandscape: Bool =
        {
            let boundsRatio = bounds.width / bounds.height
            return (boundsRatio >= layoutConstants.landscapeRatio)
        }()
        
        let sideEdges   = (isLandscape ? layoutConstants.sideEdgesLandscape : layoutConstants.sideEdgesPortrait(bounds.width))
        let bottomEdge  = sideEdges

        let topEdge: CGFloat    = self.getGap(bounds, page: curPage)
        let rowGap: CGFloat     = topEdge
        let lastRowGap: CGFloat = topEdge
        
        let mostKeysInRow: Int =
            {
                var currentMax: Int = 0
                let page = model.pages[curPage]
                for (_, row) in page.rows.enumerated()
                {
                    currentMax = max(currentMax, row.count)
                }
                return currentMax
            }()


        let page = model.pages[curPage]
        if true
        {
            let numRows = page.rows.count
            
            let rowGapTotal = CGFloat(numRows - 1 - 1) * rowGap + lastRowGap
            
            let keyGap: CGFloat = (isLandscape ? layoutConstants.keyGapLandscape(bounds.width, rowCharacterCount: mostKeysInRow) : layoutConstants.keyGapPortrait(bounds.width, rowCharacterCount: mostKeysInRow))
            
            let keyHeight: CGFloat =
            {
                let totalGaps = bottomEdge + topEdge + rowGapTotal
                let returnHeight = (bounds.height - totalGaps) / CGFloat(numRows)
                return self.rounded(returnHeight)
            }()
            
            let letterKeyWidth: CGFloat =
            {
                let totalGaps = (sideEdges * CGFloat(2)) + (keyGap * CGFloat(mostKeysInRow - 1))
                let returnWidth = (bounds.width - totalGaps) / CGFloat(mostKeysInRow)
                return self.rounded(returnWidth)
            }()
            
            for (r, row) in page.rows.enumerated()
            {
                let rowGapCurrentTotal = (r == page.rows.count - 1 ? rowGapTotal : CGFloat(r) * rowGap)
                let frame = CGRect(x: rounded(sideEdges), y: rounded(topEdge + (CGFloat(r) * keyHeight) + rowGapCurrentTotal), width: rounded(bounds.width - CGFloat(2) * sideEdges), height: rounded(keyHeight))
                
                self.layoutCharacterRow(row, modelToView: self.modelToView, keyWidth: letterKeyWidth, gapWidth: keyGap, frame: frame)
            }
        }
    }
    


    func layoutCharacterRow(_ row: [Key], modelToView: [Key:KeyboardKey], keyWidth: CGFloat, gapWidth: CGFloat, frame: CGRect)
    {
        _ = CGFloat(row.count) * keyWidth + CGFloat(row.count - 1) * gapWidth
        var allRatio = CGFloat(0);
        
        for key in row
        {
            allRatio += key.widthRatio
        }
        
        let sideSpace = (frame.width * (CGFloat(1.0) - allRatio)) / CGFloat(2);
        var currentOrigin = frame.origin.x + sideSpace
        let gapNum = gapWidth * CGFloat(row.count - 1)
        for key in row
        {
            if let view = modelToView[key]
            {
                let tempWidth = (frame.width - gapNum) * key.widthRatio
                view.frame = CGRect(x: rounded(currentOrigin), y: frame.origin.y, width: tempWidth, height: frame.height)
                currentOrigin += (tempWidth + gapWidth)
            }
            else
            {
                assert(false, "view missing for model")
            }
        }
    }

    ////////////////
    // END LAYOUT //
    ////////////////
    
    func frameForPopup(_ key: KeyboardKey, direction: Direction) -> CGRect
    {
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        let totalHeight = layoutConstants.popupTotalHeight(actualScreenWidth)
        
        let popupWidth = key.bounds.width + layoutConstants.popupWidthIncrement
        let popupHeight = totalHeight - layoutConstants.popupGap - key.bounds.height
        //let popupCenterY = 0

        var frame = CGRect(x: (key.bounds.width - popupWidth) / CGFloat(2), y: -popupHeight - layoutConstants.popupGap, width: popupWidth, height: popupHeight)
        let actualSuperview = (self.superview.superview != nil ? self.superview.superview! : self.superview)

        let localFrame = actualSuperview!.convert(frame, from: key.popup!.superview)
        if localFrame.origin.y < 3
        {
            frame.size.height -= (3 - localFrame.origin.y)
        }
        
        return frame
    }
    
    func willShowPopup(_ key: KeyboardKey, direction: Direction)
    {
        // TODO: actual numbers, not standins
        if let popup = key.popup
        {
            // TODO: total hack
            let actualSuperview = (self.superview.superview != nil ? self.superview.superview! : self.superview)
            
            var localFrame = actualSuperview!.convert(popup.frame, from: popup.superview)
            
            if localFrame.origin.y < 3
            {
                localFrame.origin.y = 3                
                //key.background.attached = Direction.Down
                //key.connector?.startDir = Direction.Down
                //key.background.hideDirectionIsOpposite = true
            }
            
            if localFrame.origin.x < 3
            {
                localFrame.origin.x = key.frame.origin.x
            }
            
            if localFrame.origin.x + localFrame.width > superview.bounds.width - 3
            {
                localFrame.origin.x = key.frame.origin.x + key.frame.width - localFrame.width
            }
            
            popup.frame = actualSuperview!.convert(localFrame, to: popup.superview)
        }
    }
    
    func willHidePopup(_ key: KeyboardKey)
    {
    }
}