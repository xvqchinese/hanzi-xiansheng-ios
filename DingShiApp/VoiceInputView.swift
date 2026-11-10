//
//  VoiceInputView.swift
//  DWKeyboard
//
//  Created by Aliang on 16/6/28.
//  Copyright © 2016年 Apple. All rights reserved.
//

import Foundation
import UIKit


class VoiceInputViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.hidesBottomBarWhenPushed = false
        self.navigationItem.title = "语音输入"
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.hidesBottomBarWhenPushed = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
}
