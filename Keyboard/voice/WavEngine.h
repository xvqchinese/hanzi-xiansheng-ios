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

// 崩溃隔离：捕获引擎 SIGSEGV/SIGBUS/SIGILL，记录后继续运行（仅诊断用）
int32_t DWGuardCall(void (^ _Nonnull blk)(void));
