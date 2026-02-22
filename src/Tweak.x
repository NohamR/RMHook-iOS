// RMHook-iOS Tweak (POC)
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <string.h>
#import <stdint.h>

// Target binary name inside the IPA
#define TARGET_MODULE  "remarkable_mobile"
#define IDA_BASE       0x100000000ULL

// --- sub_1000C81B8 ---
// void __usercall sub_1000C81B8(__int64 a1@<X0>, _QWORD *a2@<X8>)
// X8 is ARM64's indirect-result register (not a normal parameter).
// We use a naked trampoline to handle this.
static void (*orig_sub_1000C81B8)(int64_t a1);

// Pre-call logger
__attribute__((used))
static void rmhook_pre(int64_t a1, uint64_t *out) {
    NSLog(@"[RMHook] >>> sub_1000C81B8 ENTER  a1=0x%llx  x8(out)=%p",
          (unsigned long long)a1, (void *)out);
}

// Post-call logger and patcher
__attribute__((used))
static void rmhook_post(uint64_t *out) {
    if (!out) {
        NSLog(@"[RMHook] <<< sub_1000C81B8 RETURN (out=NULL)");
        return;
    }
    uint64_t base_ptr   = out[0];
    uint64_t data_ptr   = out[1];
    uint64_t char_count = out[2];
    if (data_ptr && char_count > 0 && char_count <= 4096) {
        NSString *orig = [[NSString alloc] initWithBytes:(const void *)(uintptr_t)data_ptr
                                                  length:(NSUInteger)(char_count * 2)
                                                encoding:NSUTF16LittleEndianStringEncoding];
        NSLog(@"[RMHook] <<< sub_1000C81B8 RETURN original (%llu chars) = \"%@\"",
              char_count, orig ?: @"<decode error>");
    }
    // Patch: replace returned string with custom value
    NSString *replacement = @"rm.noh.am";
    NSUInteger newCount = [replacement length];
    if (data_ptr && newCount <= char_count) {
        NSData *utf16 = [replacement dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        memcpy((void *)(uintptr_t)data_ptr, utf16.bytes, utf16.length);
        out[2] = newCount;
        *(uint64_t *)(uintptr_t)(base_ptr + 8) = newCount;
        NSLog(@"[RMHook] <<< patched → \"%@\"", replacement);
    } else {
        NSLog(@"[RMHook] <<< patch skipped (replacement too long or no buffer)");
    }
}

// Naked trampoline for sub_1000C81B8
__attribute__((naked))
static void hook_sub_1000C81B8(void) {
    __asm__ volatile(
        "sub  sp,  sp,  #32             \n"
        "stp  x29, x30, [sp, #16]       \n"
        "add  x29, sp,  #16             \n"
        "stp  x0,  x8,  [sp,  #0]       \n"
        "mov  x1,  x8                   \n"
        "bl   _rmhook_pre               \n"
        "ldp  x0,  x8,  [sp,  #0]       \n"
        "adrp x9,  _orig_sub_1000C81B8@PAGE          \n"
        "ldr  x9,  [x9, _orig_sub_1000C81B8@PAGEOFF] \n"
        "blr  x9                        \n"
        "ldr  x0,  [sp,  #8]            \n"
        "bl   _rmhook_post              \n"
        "ldp  x29, x30, [sp, #16]       \n"
        "add  sp,  sp,  #32             \n"
        "ret                            \n"
    );
}

// --- sub_1000C8444 ---
// void __usercall sub_1000C8444(_QWORD *a1@<X0>, __int64 a2@<X8>)
static void (*orig_sub_1000C8444)(int64_t a1);

__attribute__((used))
static void rmhook_pre_8444(int64_t a1, uint64_t *out) {
    NSLog(@"[RMHook] >>> sub_1000C8444 ENTER  a1=0x%llx  x8(out)=%p",
          (unsigned long long)a1, (void *)out);
}

__attribute__((used))
static void rmhook_post_8444(uint64_t *out) {
    if (!out) {
        NSLog(@"[RMHook] <<< sub_1000C8444 RETURN (out=NULL)");
        return;
    }
    uint64_t base_ptr   = out[0];
    uint64_t data_ptr   = out[1];
    uint64_t char_count = out[2];
    if (data_ptr && char_count > 0 && char_count <= 4096) {
        NSString *orig = [[NSString alloc] initWithBytes:(const void *)(uintptr_t)data_ptr
                                                  length:(NSUInteger)(char_count * 2)
                                                encoding:NSUTF16LittleEndianStringEncoding];
        NSLog(@"[RMHook] <<< sub_1000C8444 RETURN original (%llu chars) = \"%@\"",
              char_count, orig ?: @"<decode error>");
    }
    NSString *replacement = @"rm.noh.am";
    NSUInteger newCount = [replacement length];
    if (data_ptr && newCount <= char_count) {
        NSData *utf16 = [replacement dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        memcpy((void *)(uintptr_t)data_ptr, utf16.bytes, utf16.length);
        out[2] = newCount;
        *(uint64_t *)(uintptr_t)(base_ptr + 8) = newCount;
        NSLog(@"[RMHook] <<< sub_1000C8444 patched → \"%@\"", replacement);
    } else {
        NSLog(@"[RMHook] <<< sub_1000C8444 patch skipped (replacement too long or no buffer)");
    }
}

__attribute__((naked))
static void hook_sub_1000C8444(void) {
    __asm__ volatile(
        "sub  sp,  sp,  #32             \n"
        "stp  x29, x30, [sp, #16]       \n"
        "add  x29, sp,  #16             \n"
        "stp  x0,  x8,  [sp,  #0]       \n"
        "mov  x1,  x8                   \n"
        "bl   _rmhook_pre_8444          \n"
        "ldp  x0,  x8,  [sp,  #0]       \n"
        "adrp x9,  _orig_sub_1000C8444@PAGE          \n"
        "ldr  x9,  [x9, _orig_sub_1000C8444@PAGEOFF] \n"
        "blr  x9                        \n"
        "ldr  x0,  [sp,  #8]            \n"
        "bl   _rmhook_post_8444         \n"
        "ldp  x29, x30, [sp, #16]       \n"
        "add  sp,  sp,  #32             \n"
        "ret                            \n"
    );
}

// Helpers
static uintptr_t findModuleBase(const char *moduleName) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, moduleName))
            return (uintptr_t)_dyld_get_image_header(i);
    }
    return 0;
}

// Constructor
%ctor {
    @autoreleasepool {
        uintptr_t base = findModuleBase(TARGET_MODULE);
        if (!base) {
            NSLog(@"[RMHook] Module '%s' not found – tweak inactive.", TARGET_MODULE);
            return;
        }
        NSLog(@"[RMHook] '%s' base = 0x%lx", TARGET_MODULE, (unsigned long)base);

        uintptr_t offset = 0x1000C81B8ULL - IDA_BASE;
        uintptr_t addr   = base + offset;
        MSHookFunction((void *)addr, (void *)hook_sub_1000C81B8, (void **)&orig_sub_1000C81B8);
        NSLog(@"[RMHook] Hooked sub_1000C81B8 @ 0x%lx (offset 0x%lx)", (unsigned long)addr, (unsigned long)offset);

        uintptr_t offset2 = 0x1000C8444ULL - IDA_BASE;
        uintptr_t addr2   = base + offset2;
        MSHookFunction((void *)addr2, (void *)hook_sub_1000C8444, (void **)&orig_sub_1000C8444);
        NSLog(@"[RMHook] Hooked sub_1000C8444 @ 0x%lx (offset 0x%lx)", (unsigned long)addr2, (unsigned long)offset2);
    }
}
