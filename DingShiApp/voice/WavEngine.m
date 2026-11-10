//
//  WavEngine.m
//  WavEngine
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 Liangdus. All rights reserved.
//

#import "WavEngine.h"

@implementation WavEngine

extern void * CreateVoiceFile(const char * pys, int * sizeOut, int convToDS);
extern int OpenVoiceEngine();



+(int)WavCreateByPys:(NSString*)inPys
                    :(NSURL*) url
{
    if (inPys != nil)
    {
        char * pys = (char *)[inPys cStringUsingEncoding:NSUTF8StringEncoding];
        
        OpenVoiceEngine();
        int size = 0;
        void * data = CreateVoiceFile(pys, &size, 0);
        if (data != NULL)
        {
            NSData * wavData = [NSData dataWithBytes:data length:size];
            [wavData writeToURL:url atomically:false];
            free(data);
        }
        return size;
    }
    return 0;
}



@end
