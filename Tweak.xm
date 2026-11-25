#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <mach/vm_page_size.h>
#import <string.h>

// 目标：汽水音乐主二进制（vmaddr 0x100000000，文件偏移 == vmaddr - 0x100000000）
// 0x1be96fc  BNPlayingConfigure.userAudioQuality.getter      -> mov w0,#5 ; ret   (spatial)
// 0x1bea0d4  BNPlayingConfigure.ignoreCheckingPlayPermission.getter -> mov w0,#1 ; ret
static const uint8_t kPatchA[8] = {0x40, 0x00, 0x80, 0x52, 0xC0, 0x03, 0x5F, 0xD6};
static const uint8_t kPatchB[8] = {0x20, 0x00, 0x80, 0x52, 0xC0, 0x03, 0x5F, 0xD6};

static void QishuiApplyPatch(void) {
    const struct mach_header_64 *hdr = (const struct mach_header_64 *)_dyld_get_image_header(0);
    if (!hdr) { NSLog(@"[QishuiPatch] main image not found"); return; }

    uint8_t *base = (uint8_t *)hdr;
    uint8_t *p1 = base + 0x1be96fc;
    uint8_t *p2 = base + 0x1bea0d4;

    vm_address_t page = (vm_address_t)p1 & ~(vm_address_t)(vm_page_size - 1);
    kern_return_t kr = vm_protect(mach_task_self(), page, vm_page_size * 2,
                                  false,
                                  VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[QishuiPatch] vm_protect failed: %d", kr);
        return;
    }

    memcpy(p1, kPatchA, sizeof(kPatchA));
    memcpy(p2, kPatchB, sizeof(kPatchB));

    NSLog(@"[QishuiPatch] patched: %p / %p", p1, p2);
}

__attribute__((constructor))
static void QishuiPatchInit(void) {
    QishuiApplyPatch();
}