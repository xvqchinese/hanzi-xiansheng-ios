//
//  IMEngine.h
//  IMEngine
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 Liangdus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WavEngine : NSObject


+(int)WavCreateByPys:(NSString*)inPys
                    :(NSURL*) url;



@end

// 崩溃隔离（仅诊断用）：fn(tag) 内部崩溃时返回信号编号，否则返回 0
int DWGuardCall(void (*fn)(int tag), int tag);
