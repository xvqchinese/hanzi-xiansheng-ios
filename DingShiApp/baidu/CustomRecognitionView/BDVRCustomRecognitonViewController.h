//
//  BDVRCustomRecognitonViewController.h
//  BDVRClientSample
//
//  Created by Baidu on 13-9-25
//  Copyright 2013 Baidu Inc. All rights reserved.
//

// 头文件
#import <UIKit/UIKit.h>
#import "BDVoiceRecognitionClient.h"
#import "BDRecognizerOutDelegate.h"

#define playStartMusicSwitch    NO
#define voiceLevelMeter         NO

@protocol BDRecognizerOutDelegate;


// @class - BDVRCustomRecognitonViewController
// @brief - 语音搜索界面的实现类
@interface BDVRCustomRecognitonViewController : UIViewController<MVoiceRecognitionClientDelegate>
{
	UIImageView *_dialog;
    NSTimer *_voiceLevelMeterTimer; // 获取语音音量界别定时器
}

// 属性
@property (nonatomic, retain) UIImageView *dialog;
@property (nonatomic, retain) NSTimer *voiceLevelMeterTimer;
@property(nonatomic, assign) id<BDRecognizerOutDelegate> delegate;

// 方法
- (void)cancel:(id)sender;

@end // BDVRCustomRecognitonViewController

