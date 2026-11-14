//
//  WavEngine.m
//  WavEngine
//
//  Created by mac on 14-10-20.
//  Copyright (c) 2014年 Liangdus. All rights reserved.
//

#import "WavEngine.h"
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>


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
        void * data = CreateVoiceFile(pys, &size, 1);
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
    char buf[240], spc[180], slr[180];
    ucontext_t *u = (ucontext_t *)uc;
    unsigned long x[30] = {0}, pc = 0, lr = 0, fp = 0;
    if (u) {
        for (int i = 0; i < 29; i++) x[i] = (unsigned long)u->uc_mcontext->__ss.__x[i];
        pc = (unsigned long)u->uc_mcontext->__ss.__pc;
        lr = (unsigned long)u->uc_mcontext->__ss.__lr;
        fp = x[29];
    }
    dw_sym(pc, spc, sizeof(spc));
    dw_sym(lr, slr, sizeof(slr));
    snprintf(buf, sizeof(buf), "\n    pc=%s lr=%s", spc, slr);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    x0=%lx x1=%lx x2=%lx x3=%lx x4=%lx x5=%lx x6=%lx",
             x[0], x[1], x[2], x[3], x[4], x[5], x[6]);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    x8=%lx x9=%lx x10=%lx x11=%lx x12=%lx x13=%lx",
             x[8], x[9], x[10], x[11], x[12], x[13]);
    dw_strcat(g_dw_detail, buf);
    snprintf(buf, sizeof(buf), "\n    x19=%lx x20=%lx x21=%lx x22=%lx x23=%lx x24=%lx x25=%lx",
             x[19], x[20], x[21], x[22], x[23], x[24], x[25]);
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


//==== 引擎对象内存窥探（诊断用，临时） ====
static unsigned long dw_find_obj(const void *db)
{
    if (!db) return 0;
    unsigned long dbp = (unsigned long)db, obj = 0;
    int images = (int)_dyld_image_count();
    for (int i = 0; i < images && !obj; i++) {
        const struct mach_header_64 *h = (const struct mach_header_64 *)_dyld_get_image_header(i);
        if (!h || h->magic != MH_MAGIC_64) continue;
        unsigned long slide = (unsigned long)_dyld_get_image_vmaddr_slide(i);
        const struct load_command *lc = (const struct load_command *)((const char *)h + sizeof(struct mach_header_64));
        for (unsigned int j = 0; j < h->ncmds && !obj; j++) {
            if (lc->cmd == LC_SEGMENT_64) {
                const struct segment_command_64 *sg = (const struct segment_command_64 *)lc;
                if (strcmp(sg->segname, "__DATA") == 0 || strcmp(sg->segname, "__DATA_CONST") == 0) {
                    uintptr_t a0 = (uintptr_t)(sg->vmaddr + slide);
                    uintptr_t a1 = a0 + (uintptr_t)sg->vmsize;
                    for (uintptr_t a = a0; a + 8 <= a1; a += 8) {
                        if (*(unsigned long *)a == dbp) {
                            unsigned long cand = a - 0x8018u;
                            if (cand > 0x100000000UL && cand < 0x400000000UL &&
                                *(unsigned long *)(cand + 0x8018u) == dbp) { obj = cand; break; }
                        }
                    }
                }
            }
            lc = (const struct load_command *)((const char *)lc + lc->cmdsize);
        }
    }
    return obj;
}

const char *DWPeekEngine(const void *db)
{
    static char out[1100];
    out[0] = 0;
    unsigned long obj = dw_find_obj(db);
    if (!obj) { snprintf(out, sizeof(out), " 对象=没找到"); return out; }
    unsigned long arr = *(unsigned long *)(obj + 0x82c0u);
    unsigned long p30 = *(unsigned long *)(obj + 0x8030u);
    unsigned long p38 = *(unsigned long *)(obj + 0x8038u);
    unsigned long p40 = *(unsigned long *)(obj + 0x8040u);
    snprintf(out, sizeof(out), " 对象=%lx 联想表=%lx", obj, arr);
    (void)p30; (void)p38; (void)p40;
    return out;
}

const char *DWPeekMore(const void *db)
{
    static char out[1100];
    out[0] = 0;
    unsigned long obj = dw_find_obj(db);
    if (!obj) { snprintf(out, sizeof(out), " 对象没找到"); return out; }
    unsigned long dbp = (unsigned long)db;
    unsigned long p18 = *(unsigned long *)(obj + 0x8018u);
    unsigned long p20 = *(unsigned long *)(obj + 0x8020u);
    unsigned long p28 = *(unsigned long *)(obj + 0x8028u);
    unsigned long p30 = *(unsigned long *)(obj + 0x8030u);
    unsigned long p38 = *(unsigned long *)(obj + 0x8038u);
    unsigned long p40 = *(unsigned long *)(obj + 0x8040u);
    unsigned long pC0 = *(unsigned long *)(obj + 0x82c0u);
    unsigned long pC8 = *(unsigned long *)(obj + 0x82c8u);
    unsigned int d0 = 0, dm = 0;
    unsigned int i0 = 0, im = 0;
    if (p20 > dbp && p20 < dbp + 0x200000UL) {
        d0 = *(unsigned int *)p20;
        dm = *(unsigned int *)(p20 + 4u * 31950u);
        if ((unsigned long)d0 + 8u < (unsigned long)(p20 - dbp)) i0 = *(unsigned short *)(dbp + (unsigned long)d0 + 4u);
        if ((unsigned long)dm + 8u < (unsigned long)(p20 - dbp)) im = *(unsigned short *)(dbp + (unsigned long)dm + 4u);
    }
    snprintf(out, sizeof(out), " 18=+%lx 20=+%lx 28=+%lx 30=%lx 38=%lx 40=%lx C0=%lx C8=%lx d0=%x i0=%u dm=%x im=%u",
             (p18 - dbp), (p20 - dbp), (p28 - dbp), p30, p38, p40, pC0, pC8, d0, i0, dm, im);
    return out;
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
