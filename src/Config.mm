#import "Config.h"

NSString *gConfiguredHost = @"";
NSNumber *gConfiguredPort = @(0);

void saveConfiguration(NSString *host, NSNumber *port) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:host forKey:@"RMHook_Host"];
    [defaults setObject:port forKey:@"RMHook_Port"];
    [defaults synchronize];
    gConfiguredHost = host;
    gConfiguredPort = port;
    NSLog(@"[RMHook-iOS] Saved config - Host: %@, Port: %@", gConfiguredHost, gConfiguredPort);
}

void loadConfiguration() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *host = [defaults stringForKey:@"RMHook_Host"];
    NSNumber *port = [defaults objectForKey:@"RMHook_Port"];
    
    if (host && host.length > 0 && port && [port intValue] > 0) {
        gConfiguredHost = host;
        gConfiguredPort = port;
        NSLog(@"[RMHook-iOS] Loaded config - Host: %@, Port: %@", gConfiguredHost, gConfiguredPort);
    }
}

void showConfigAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
            }
        }
        if (!window) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
        }

        if (!window || !window.rootViewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                showConfigAlert();
            });
            return;
        }
        
        UIViewController *rootVC = window.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RMHook" 
                                                                       message:@"First Launch: Enter Host and Port" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Host (e.g. example.com)";
            textField.text = @"example.com";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Port (e.g. 443)";
            textField.text = @"443";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *host = alert.textFields[0].text;
            NSNumber *port = @([alert.textFields[1].text integerValue]);
            saveConfiguration(host, port);
        }];
        
        [alert addAction:saveAction];
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}
