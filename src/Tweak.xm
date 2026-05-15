#import <substrate.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <string.h>
#import <stdint.h>

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QDebug>
#include <QtCore/QIODevice>
#include <QtCore/QUrl>
#include <QtCore/QString>
#include <QtCore/Qt>
#include <QtWebSockets/QWebSocket>
#include <QtCore/QSettings>
#include <QtCore/QVariant>
#include <QtCore/QAnyStringView>

#define TARGET_MODULE  "remarkable_mobile"
#define IDA_BASE       0x100000000

// __ZN21QNetworkAccessManager13createRequestENS_9OperationERK15QNetworkRequestP9QIODevice
#define QtNetworkAccessManager_createRequest 0x1017FB9F4 // sub_1017FB9F4

// __ZN10QWebSocket4openERK15QNetworkRequest
# define QtWebSocket_open 0x100526A18 // sub_100526A18


// QObject *__fastcall QNetworkAccessManager::createRequest(
//         QtSharedPointer::ExternalRefCountData *a1,
//         __int64 a2,
//         const QNetworkRequest *a3,
//         __int64 a4)
static void *(*orig_createRequest)(void *a1, int a2, const void *a3, void *a4);

void *hook_createRequest(void *a1, int a2, const void *a3, void *a4) {
    NSLog(@"[RMHook-iOS] createRequest called");
    return orig_createRequest(a1, a2, a3, a4);
}

// void __fastcall QWebSocket::open(QWebSocket *this, const QUrl *a2, const QWebSocketHandshakeOptions *a3)
static void (*orig_open)(void *this_ptr, const void *a2, const void *a3);

void hook_open(void *this_ptr, const void *a2, const void *a3) {
    NSLog(@"[RMHook-iOS] QWebSocket::open called");
    orig_open(this_ptr, a2, a3);
}


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
            NSLog(@"[RMHook-iOS] Module '%s' not found, tweak inactive.", TARGET_MODULE);
            return;
        }
        NSLog(@"[RMHook-iOS] '%s' base = 0x%lx", TARGET_MODULE, (unsigned long)base);

        uintptr_t offset = QtNetworkAccessManager_createRequest - IDA_BASE;
        uintptr_t addr   = base + offset;
        MSHookFunction((void *)addr, (void *)hook_createRequest, (void **)&orig_createRequest);
        NSLog(@"[RMHook-iOS] Hooked QtNetworkAccessManager_createRequest @ 0x%lx (offset 0x%lx)", (unsigned long)addr, (unsigned long)offset);

        uintptr_t offset2 = QtWebSocket_open - IDA_BASE;
        uintptr_t addr2   = base + offset2;
        MSHookFunction((void *)addr2, (void *)hook_open, (void **)&orig_open);
        NSLog(@"[RMHook-iOS] Hooked QtWebSocket_open @ 0x%lx (offset 0x%lx)", (unsigned long)addr2, (unsigned long)offset2);
    }
}
