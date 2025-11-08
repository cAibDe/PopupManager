//
//  PopupManager.h
//  OC开发小集
//
//  Created by DozenZhang on 2025/10/31.
//  Copyright © 2025 MySelf. All rights reserved.
//

/*
 使用这个弹窗控制类 可以根据自己的需求自定义个弹窗视图，但是要签署PopupProtocol协议，并实现相应的属性和方法
 
 整体思路：
    1.如果在当前可显示的页面添加的弹窗，第一个添加的会直接显示，后续添加的弹窗会统一添加到一个等待弹出的数组中，
    然后根据优先级从高到底的排序依次的显示，如果出现优先级相同的情况，会优先显示先添加进来的弹窗；
    2.如果在添加了非当前页面显示的弹窗，则统一添加到等待弹出的数组中。目标页面调用viewWillAppear方法的时候，
    在等待弹出的弹窗中找到优先级最高的弹窗弹出。
 
 解决的问题：
    随着项目中的弹窗类型越来越多，控制弹窗显示的顺序已经成了一个问题。需要很多的非必要的条件判断变量来控制弹窗的显示。
    所以我们就来设计了这么一个类，我们来给所有的弹窗一个优先级显示的属性。
    让开发人员可以不用再顾虑那么多的顺序问题，唯一要考虑的就是怎么制定优先级的高低。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol PopupProtocol <NSObject>
@required

/// 弹窗的优先级
@property (nonatomic, assign, readonly) NSInteger popupPriority;

/// 显示弹窗
- (void)show;

@optional
/// 目标弹窗显示的控制器的类
@property (nonatomic, strong,nullable) NSArray<Class> *targetViewControllerClasses;

@end
@interface PopupManager : NSObject

/// 创建单例
+ (instancetype)sharedManager;

/// 添加弹窗
/// - Parameter popupView: 弹窗视图
- (void)addPopupView:(UIView<PopupProtocol> *)popupView;

/// 弹窗消失并显示下一个弹窗
- (void)popupDidDismiss;

/// 获取当前显示的弹窗
- (UIView<PopupProtocol> *)getCurrentPopupView;

/// 检测是否有下一个显示的弹窗(可以在 viewWillAppear 调用)
- (void)checkAndShowNextPopupIfNeeded;

/// 清空当前等待队列里面的所有弹窗
- (void)clearWaittingQueueAllPopupView;

/// 当前弹窗消失
- (void)dismissCurrentPopupView;
/// 获取当前显示的最顶端的控制器
- (UIViewController *)topViewController;
@end

NS_ASSUME_NONNULL_END
