//
//  PopupView.h
//  OC开发小集
//
//  Created by DozenZhang on 2025/10/31.
//  Copyright © 2025 MySelf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupManager.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^SureAction)(void);
typedef void(^CancelAction)(void);
@interface PopupView : UIView<PopupProtocol>

/// 弹窗的优先级
@property (nonatomic, assign, readonly) NSInteger popupPriority;

/// 弹窗可以弹出的控制器集合
@property (nonatomic, strong, nullable) NSArray<Class> *targetViewControllerClasses;

/// 当前的弹窗是不是要点击消失
@property (nonatomic, assign) BOOL crrfrncSignFlag;

/// 确定按钮的执行
@property (nonatomic, copy) SureAction sureAction;
/// 取消按钮的执行
@property (nonatomic, copy) CancelAction cancelAction;

/// 弹窗视图的初始化(后期可以根据需求自定义)
/// - Parameters:
///   - popupPriority: 弹窗的优先级
///   - message: 弹窗信息
- (instancetype)initWithPopupPriority:(NSInteger)popupPriority message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
