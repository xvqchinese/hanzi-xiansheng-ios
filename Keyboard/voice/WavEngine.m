//
//  WavEngine.m
//  WavEngine
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 Liangdus. All rights reserved.
//

#import "WavEngine.h"

@implementation WavEngine

extern void * CreateVoiceFile(const char * pys, int * size);
extern int OpenVoiceEngine();



+(int)WavCreateByPys:(NSString*)inPys
                    :(NSURL*) url
{
    if (inPys != nil)
    {
        char * pys = (char *)[inPys cStringUsingEncoding:NSUTF8StringEncoding];
        
        OpenVoiceEngine();
        int size = 0;
        void * data = CreateVoiceFile(pys, &size);
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

#import <setjmp.h>
#include <signal.h>
#include <unistd.h>

static sigjmp_buf g_dw_env;
static volatile int g_dw_armed = 0;
static volatile int g_dw_sig = 0;

static void dw_guard_handler(int sig)
{
    g_dw_sig = sig;
    if (g_dw_armed) { g_dw_armed = 0; siglongjmp(g_dw_env, 1); }
    _exit(139);
}

int DWGuardCall(void (*fn)(int tag), int tag)
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = dw_guard_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_NODEFER | SA_RESETHAND;
    sigaction(SIGSEGV, &sa, NULL);
    sigaction(SIGBUS,  &sa, NULL);
    sigaction(SIGILL,  &sa, NULL);
    sigaction(SIGTRAP, &sa, NULL);
    sigaction(SIGABRT, &sa, NULL);
    g_dw_sig = 0;
    if (sigsetjmp(g_dw_env, 1) == 0) {
        g_dw_armed = 1;
        fn(tag);
        g_dw_armed = 0;
        return 0;
    }
    return g_dw_sig ? g_dw_sig : -1;
}
