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

#import <UIKit/UIKit.h>

#define TARGET_MODULE  "remarkable_mobile"
#define IDA_BASE       0x100000000


// __ZN21QNetworkAccessManager13createRequestENS_9OperationERK15QNetworkRequestP9QIODevice
#if V3_25_0
#define QtNetworkAccessManager_createRequest 0x1017FB9F4 // sub_1017FB9F4
#elif V3_27_1
#define QtNetworkAccessManager_createRequest 0x10192472C // sub_10192472C
#endif

// __ZN10QWebSocket4openERK15QNetworkRequest
#if V3_25_0
# define QtWebSocket_open 0x100526A18 // sub_100526A18
#elif V3_27_1
# define QtWebSocket_open 0x100564A24 // sub_100564A24
#endif


#import "Config.h"

static inline QString QStringFromNSStringSafe(NSString* str) {
    if (!str) return QString();
    return QString::fromNSString(str);
}

static inline bool shouldPatchURL(const QString &host) {
    if (host.isEmpty()) {
        return false;
    }

    return QString(R"""(
        hwr-production-dot-remarkable-production.appspot.com
        service-manager-production-dot-remarkable-production.appspot.com
        local.appspot.com
        my.remarkable.com
        ping.remarkable.com
        internal.cloud.remarkable.com
        eu.tectonic.remarkable.com
        backtrace-proxy.cloud.remarkable.engineering
        dev.ping.remarkable.com
        dev.tectonic.remarkable.com
        dev.internal.cloud.remarkable.com
        eu.internal.tctn.cloud.remarkable.com
        webapp-prod.cloud.remarkable.engineering
    )""")
        .contains(host, Qt::CaseInsensitive);
}

// QObject *__fastcall QNetworkAccessManager::createRequest(
//         QtSharedPointer::ExternalRefCountData *self,
//         __int64 op,
//         const QNetworkRequest *req,
//         __int64 outgoingData)
static QNetworkReply* (*original_qNetworkAccessManager_createRequest)(
    QNetworkAccessManager* self,
    QNetworkAccessManager::Operation op,
    const QNetworkRequest& req,
    QIODevice* outgoingData
);

QNetworkReply* hooked_qNetworkAccessManager_createRequest(
    QNetworkAccessManager* self,
    QNetworkAccessManager::Operation op,
    const QNetworkRequest& req,
    QIODevice* outgoingData
) {
    NSLog(@"[RMHook-iOS] createRequest called for URL: %s", req.url().toString().toStdString().c_str());
    const QString host = req.url().host();
    if (shouldPatchURL(host)) {
        QNetworkRequest newReq(req);
        QUrl newUrl = req.url();
        const QString overrideHost = QStringFromNSStringSafe(gConfiguredHost);
        newUrl.setHost(overrideHost);
        newUrl.setPort([gConfiguredPort intValue]);
        newReq.setUrl(newUrl);

        if (original_qNetworkAccessManager_createRequest) {
            return original_qNetworkAccessManager_createRequest(self, op, newReq, outgoingData);
        }
        return nullptr;
    }

    if (original_qNetworkAccessManager_createRequest) {
        return original_qNetworkAccessManager_createRequest(self, op, req, outgoingData);
    }
    return nullptr;
}

// void __fastcall QWebSocket::open(QWebSocket *self, const QNetworkRequest *req)
static void (*original_qWebSocket_open)(
    QWebSocket* self,
    const QNetworkRequest& req
);

void hooked_qWebSocket_open(
    QWebSocket* self,
    const QNetworkRequest& req
) {
    NSLog(@"[RMHook-iOS] QWebSocket::open called for URL: %s", req.url().toString().toStdString().c_str());
    if (!original_qWebSocket_open) {
        return;
    }

    const QString host = req.url().host();
    if (shouldPatchURL(host)) {
        QUrl newUrl = req.url();
        const QString overrideHost = QStringFromNSStringSafe(gConfiguredHost);
        newUrl.setHost(overrideHost);
        newUrl.setPort([gConfiguredPort intValue]);

        QNetworkRequest newReq(req);
        newReq.setUrl(newUrl);

        original_qWebSocket_open(self, newReq);
        return;
    }

    original_qWebSocket_open(self, req);
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


%ctor {
    @autoreleasepool {
        loadConfiguration();

        if (gConfiguredHost.length == 0 || [gConfiguredPort intValue] == 0) {
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                              object:nil 
                                                               queue:[NSOperationQueue mainQueue] 
                                                          usingBlock:^(NSNotification * _Nonnull note) {
                showConfigAlert();
            }];
        }

        uintptr_t base = findModuleBase(TARGET_MODULE);
        if (!base) {
            NSLog(@"[RMHook-iOS] Module '%s' not found, tweak inactive.", TARGET_MODULE);
            return;
        }
        NSLog(@"[RMHook-iOS] '%s' base = 0x%lx", TARGET_MODULE, (unsigned long)base);

        uintptr_t offset = QtNetworkAccessManager_createRequest - IDA_BASE;
        uintptr_t addr   = base + offset;
        MSHookFunction((void *)addr, (void *)hooked_qNetworkAccessManager_createRequest, (void **)&original_qNetworkAccessManager_createRequest);
        NSLog(@"[RMHook-iOS] Hooked QtNetworkAccessManager_createRequest @ 0x%lx (offset 0x%lx)", (unsigned long)addr, (unsigned long)offset);

        uintptr_t offset2 = QtWebSocket_open - IDA_BASE;
        uintptr_t addr2   = base + offset2;
        MSHookFunction((void *)addr2, (void *)hooked_qWebSocket_open, (void **)&original_qWebSocket_open);
        NSLog(@"[RMHook-iOS] Hooked QtWebSocket_open @ 0x%lx (offset 0x%lx)", (unsigned long)addr2, (unsigned long)offset2);
    }
}
