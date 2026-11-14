//
//  KeyboardViewControllerExtendableMethods.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 9/28/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

extension KeyboardViewController {
    
    ///////////////////////////////////////////////
    // OVERRIDE THESE METHODS IN YOUR SUPERCLASS //
    ///////////////////////////////////////////////
    
    // TODO: I dunno what happened, this used to work
    //func keyPressed(_ key: Key) {}
    
    // TODO: but this one CAN be overriden? what's going on?!
    func banner_cmd() -> CommandBanner { return CommandBanner(handler: self) } // 工具条
    func banner_cand() -> SmallCand2 { return SmallCand2(frame: self.candBounds!, handler: self) } // 候选条
    
    func view_selectKB() -> SelectKBView { return SelectKBView() }
    func view_setting() -> SettingView { return SettingView(frame: self.view.bounds) }

    func view_bigCand() -> BigCandView2 { return BigCandView2(handler: self) }

    func view_coinciding() -> CoincidingView { return CoincidingView(handler: self) }

    func view_phrs() -> PhrsView { return PhrsView(handler:self) }

    func view_smile() -> SmileView { return SmileView(handler:self) }
}
