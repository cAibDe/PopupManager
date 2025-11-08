#import "UIWindow+Helper.h"

@implementation UIWindow (Helper)

+ (UIWindow *)currentWindonw {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *window in scene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
