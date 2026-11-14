//
//  ocUtils.h
//  DWKeyboard
//
//  Created by Aliang on 16/6/27.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BDRecognizerViewController.h"
#import "BDRecognizerViewDelegate.h"
#import "BDRecognizerViewDelegate.h"
#import "BDVRRawDataRecognizer.h"
#import "BDVRRawDataRecognizer.h"

@interface ocUtils : NSObject

+(void)showMessage:(NSString *)message;
+(NSString *)composeInputModeResult:(id)aObj;

+(void) drawWordPath:(NSString*)word
                    :(NSString*)fontName
                    :(UIImageView*) imageView
                    :(NSArray*) skAry
                    :(CFIndex) flashIndex;

+(NSString *)URLDecodedString:(NSString *)str;
+(NSString *)getHZFlashSkary:(int)index;
+(NSString *)skLettersFor:(NSString *)zi;



@end