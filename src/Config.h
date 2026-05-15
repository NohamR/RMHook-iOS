#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *gConfiguredHost;
extern NSNumber *gConfiguredPort;

#ifdef __cplusplus
extern "C" {
#endif

void loadConfiguration(void);
void saveConfiguration(NSString *host, NSNumber *port);
void showConfigAlert(void);

#ifdef __cplusplus
}
#endif
