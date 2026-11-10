//
//  BDRecognizerOutDelegate.h
//  DWKeyboard
//
//  Created by Aliang on 16/6/29.
//  Copyright © 2016年 Apple. All rights reserved.
//
#import <UIKit/UIKit.h>


/**
 * @brief 语音输出委托接口
 */
@protocol BDRecognizerOutDelegate <NSObject>

@required
- (void)voiceRecognitionResultOut:(NSString *)results;

@end // BDRecognizerOutDelegate
