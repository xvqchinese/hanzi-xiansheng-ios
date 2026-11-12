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

#import <dlfcn.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/ucontext.h>
#include <unistd.h>

static sigjmp_buf g_dw_env;
static volatile int g_dw_armed = 0;
static volatile int g_dw_sig = 0;
static char g_dw_detail[600] = {0};

static void dw_sym(unsigned long addr, char *out, int outlen)
{
    if (!addr) { snprintf(out, outlen, "0"); return; }
    Dl_info info;
    if (dladdr((void *)addr, &info) && info.dli_fbase) {
        unsigned long off = addr - (unsigned long)info.dli_fbase;
        snprintf(out, outlen, "+0x%lx(%s)", off, info.dli_sname ? info.dli_sname : "?");
    } else {
        snprintf(out, outlen, "0x%lx", addr);
    }
}

static void dw_guard_handler(int sig, siginfo_t *si, void *uc)
{
    g_dw_sig = sig;
    unsigned long pc = 0, lr = 0, sp = 0;
    ucontext_t *u = (ucontext_t *)uc;
    if (u) {
        pc = (unsigned long)u->uc_mcontext->__ss.__pc;
        lr = (unsigned long)u->uc_mcontext->__ss.__lr;
        sp = (unsigned long)u->uc_mcontext->__ss.__sp;
    }
    char spc[160], slr[160];
    dw_sym(pc, spc, sizeof(spc));
    dw_sym(lr, slr, sizeof(slr));
    snprintf(g_dw_detail, sizeof(g_dw_detail), "\n    pc=%s lr=%s sp=0x%lx fault=%p",
             spc, slr, sp, si ? si->si_addr : (void *)0);
    if (g_dw_armed) { g_dw_armed = 0; siglongjmp(g_dw_env, 1); }
    _exit(139);
}

int DWGuardCall(void (*fn)(int tag), int tag)
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = dw_guard_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO | SA_NODEFER | SA_RESETHAND;
    sigaction(SIGSEGV, &sa, NULL);
    sigaction(SIGBUS,  &sa, NULL);
    sigaction(SIGILL,  &sa, NULL);
    sigaction(SIGTRAP, &sa, NULL);
    sigaction(SIGABRT, &sa, NULL);
    g_dw_sig = 0;
    g_dw_detail[0] = 0;
    if (sigsetjmp(g_dw_env, 1) == 0) {
        g_dw_armed = 1;
        fn(tag);
        g_dw_armed = 0;
        return 0;
    }
    return g_dw_sig ? g_dw_sig : -1;
}

const char *DWLastCrash(void)
{
    return g_dw_detail;
}
