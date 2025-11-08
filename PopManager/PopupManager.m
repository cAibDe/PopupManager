//
//  PopupManager.m
//  OC开发小集
//
//  Created by DozenZhang on 2025/10/31.
//  Copyright © 2025 MySelf. All rights reserved.
//

#import "PopupManager.h"
#import "UIWindow+Helper.h"
@interface PopupManager ()

/// 等待弹出的弹窗队列
@property (nonatomic, strong) NSMutableArray<UIView<PopupProtocol> *> *waitingQueue;

/// 当前弹出的弹窗
@property (nonatomic, weak) UIView<PopupProtocol> *currentPopupView;

/// 同步队列
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end
@implementation PopupManager
#pragma mark - Life Cycle
+ (instancetype)sharedManager {
    static PopupManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PopupManager alloc] init];
    });
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _waitingQueue = [NSMutableArray array];
        _syncQueue = dispatch_queue_create("com.popup.manager.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
#pragma mark - Public Method
/// 添加弹窗
/// - Parameter popupView: 弹窗视图
- (void)addPopupView:(UIView<PopupProtocol> *)popupView {
    if (!popupView) {
        return;
    }
    //先判断当前控制器是不是合规,不合规就进入到等待队列中
    if (![self isPopupViewValidForCurrentController:popupView]) {
        dispatch_async(self.syncQueue, ^{
            [self.waitingQueue addObject:popupView];
        });
    }else{
        dispatch_async(self.syncQueue, ^{
            if (!self.currentPopupView) {
                //当前没有弹窗在显示
                self.currentPopupView = popupView;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [popupView show];
                });
            }else{
                //添加到等待显示的弹窗数组中
                [self.waitingQueue addObject:popupView];
            }
        });
    }
}
/// 弹窗消失并显示下一个弹窗
- (void)popupDidDismiss {
    dispatch_async(self.syncQueue, ^{
        self.currentPopupView = nil;
        if (self.waitingQueue.count == 0) {
            return;
        }
        //遍历能在当前页面弹出的所有弹窗
        NSMutableArray *allowPopupViewArray = [NSMutableArray new];
        for (UIView<PopupProtocol> *popup in self.waitingQueue) {
            if ([self isPopupViewValidForCurrentController:popup]) {
                [allowPopupViewArray addObject:popup];
            }
        }
        if (allowPopupViewArray.count == 0) {
            return;
        }
        //找出等待弹出的弹窗中优先级最高的弹窗
        UIView<PopupProtocol> *heightestPriorityPopupView = allowPopupViewArray.firstObject;
        for (UIView<PopupProtocol> *popupView in allowPopupViewArray) {
            if (popupView.popupPriority > heightestPriorityPopupView.popupPriority) {
                heightestPriorityPopupView = popupView;
            }
        }
        if (heightestPriorityPopupView) {
            [self.waitingQueue removeObject:heightestPriorityPopupView];
            self.currentPopupView = heightestPriorityPopupView;
            dispatch_async(dispatch_get_main_queue(), ^{
                [heightestPriorityPopupView show];
            });
        }
    });
}
/// 获取当前显示的弹窗
- (UIView<PopupProtocol> *)getCurrentPopupView{
    return self.currentPopupView;
}
/// 检测是否有下一个显示的弹窗(可以在 viewWillAppear 调用)
- (void)checkAndShowNextPopupIfNeeded {
    dispatch_async(self.syncQueue, ^{
        if (self.waitingQueue.count == 0) {
            return;
        }
        if (self.currentPopupView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.currentPopupView show];
            });
            return;
        }
        //遍历能在当前页面弹出的所有弹窗
        NSMutableArray *allowPopupViewArray = [NSMutableArray new];
        for (UIView<PopupProtocol> *popup in self.waitingQueue) {
            if ([self isPopupViewValidForCurrentController:popup]) {
                [allowPopupViewArray addObject:popup];
            }
        }
        if (allowPopupViewArray.count == 0) {
            return;
        }
        //找出等待弹出的弹窗中优先级最高的弹窗
        UIView<PopupProtocol> *heightestPriorityPopupView = allowPopupViewArray.firstObject;
        for (UIView<PopupProtocol> *popupView in allowPopupViewArray) {
            if (popupView.popupPriority > heightestPriorityPopupView.popupPriority) {
                heightestPriorityPopupView = popupView;
            }
        }
        
        if (heightestPriorityPopupView) {
            [self.waitingQueue removeObject:heightestPriorityPopupView];
            self.currentPopupView = heightestPriorityPopupView;
            dispatch_async(dispatch_get_main_queue(), ^{
                [heightestPriorityPopupView show];
            });
        }
    });
}
/// 清空当前等待队列里面的所有弹窗
- (void)clearWaittingQueueAllPopupView {
    [self.waitingQueue removeAllObjects];
}
/// 当前弹窗消失
- (void)dismissCurrentPopupView{
    if (self.currentPopupView ) {
        [self.waitingQueue removeObject:self.currentPopupView];
        [self.currentPopupView removeFromSuperview];
        self.currentPopupView = nil;
    }
}
/// 获取当前显示的最顶端的控制器
- (UIViewController *)topViewController {
    __block UIViewController *topVC = nil;
    //确保在主线程获取window和rootVC
    if ([NSThread isMainThread]) {
        topVC = [self getCurrentVC];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            topVC = [self getCurrentVC];
        });
    }
    return topVC;
}
#pragma mark - Private Method
/// 获取当前控制器
- (UIViewController *)getCurrentVC{
    UIViewController *rootViewController = [UIWindow currentWindonw].rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}
/// 根据当前控制器寻找当前控制器
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *vc=(UITabBarController*)rootVC;
        if (vc.selectedIndex >= vc.viewControllers.count || vc.selectedIndex <= 0) {
            vc.selectedIndex = 0;
        }
        currentVC = [self getCurrentVCFrom:vc.viewControllers[vc.selectedIndex]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}

/// 判断当前的控制器是不是能弹出当前的弹窗
/// - Parameter popupView: 弹窗
- (BOOL)isPopupViewValidForCurrentController:(UIView<PopupProtocol> *)popupView {
    if (![popupView respondsToSelector:@selector(targetViewControllerClasses)]) {
        return YES; //没有限制 就认为是 任何界面都可以
    }
    NSArray<Class> *classes = popupView.targetViewControllerClasses;
    if (classes.count == 0) {
        return YES; //空数组也认为是 任何界面都可以
    }
    UIViewController *currentVC = [self topViewController];
    for (Class cls in classes) {
        if ([currentVC isKindOfClass:cls]) {
            return YES;
        }
    }
    return NO;
}
@end
