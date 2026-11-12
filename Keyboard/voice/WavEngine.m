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

#import <dlfcn.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/ucontext.h>
#include <unistd.h>

static sigjmp_buf g_dw_env;
static volatile int g_dw_armed = 0;
static volatile int g_dw_sig = 0;
static char g_dw_detail[1100] = {0};

static void dw_strcat(char *dst, const char *src)
{
    size_t l = strlen(dst);
    if (l < 1090) snprintf(dst + l, 1100 - l, "%s", src);
}

static void dw_sym(unsigned long addr, char *out, int outlen)
{
    if (!addr) { snprintf(out, outlen, "0"); return; }
    Dl_info info;
    if (dladdr((void *)addr, &info) && info.dli_fbase) {
        snprintf(out, outlen, "+0x%lx(%s)",
                 addr - (unsigned long)info.dli_fbase,
                 info.dli_sname ? info.dli_sname : "?");
    } else {
        snprintf(out, outlen, "0x%lx", addr);
    }
}

static void dw_guard_handler(int sig, siginfo_t *si, void *uc)
{
    g_dw_sig = sig;
    char buf[220], spc[180];
    ucontext_t *u = (ucontext_t *)uc;
    unsigned long x[30] = {0}, pc = 0, fp = 0;
    if (u) {
        for (int i = 0; i < 29; i++) x[i] = (unsigned long)u->uc_mcontext->__ss.__x[i];
        pc = (unsigned long)u->uc_mcontext->__ss.__pc;
        fp = x[29];
    }
    dw_sym(pc, spc, sizeof(spc));
    snprintf(buf, sizeof(buf), "\n    pc=%s fault=%p", spc, si ? si->si_addr : (void *)0);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    x0=%lx x1=%lx x2=%lx x3=%lx x4=%lx x5=%lx x6=%lx",
             x[0], x[1], x[2], x[3], x[4], x[5], x[6]);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    x19=%lx x20=%lx x21=%lx x22=%lx x24=%lx x25=%lx",
             x[19], x[20], x[21], x[22], x[24], x[25]);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    bt:");
    dw_strcat(g_dw_detail, buf);
    unsigned long cur = fp;
    for (int k = 0; k < 6 && cur; k++) {
        if ((cur & 7) || cur < 0x100000000UL || cur > 0x8000000000UL) break;
        unsigned long *p = (unsigned long *)cur;
        unsigned long prev = p[0], ra = p[1];
        if (ra) {
            dw_sym(ra, spc, sizeof(spc));
            snprintf(buf, sizeof(buf), " %s", spc);
            dw_strcat(g_dw_detail, buf);
        }
        if (prev <= cur) break;
        cur = prev;
    }
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
