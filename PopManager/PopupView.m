//
//  PopupView.m
//  OC开发小集
//
//  Created by DozenZhang on 2025/10/31.
//  Copyright © 2025 MySelf. All rights reserved.
//

#import "PopupView.h"
#import "UIWindow+Helper.h"
@interface PopupView ()

@property (nonatomic, assign) NSInteger popupPriority;

@property (nonatomic, strong) UILabel *mesageLabel;

@end
@implementation PopupView
- (instancetype)initWithPopupPriority:(NSInteger)popupPriority message:(NSString *)message{
    self = [super initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _popupPriority = popupPriority;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 160)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 12;
        containerView.center = self.center;
        [self addSubview:containerView];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 220, 60)];
        messageLabel.text = message;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:messageLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(80 , 110, 100, 30);
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:button];
    }
    return self;
}
#pragma mark - <PopupProtocol>
- (void)show {
    UIWindow *window = [UIWindow currentWindonw];
    [window addSubview:self];
    self.center = window.center;
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}
- (void)hidden {
    if (!self.crrfrncSignFlag) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [[PopupManager sharedManager] popupDidDismiss];
            if (self.sureAction) {
                self.sureAction();
            }
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.sureAction) {
                self.sureAction();
            }
        }];
    }
}
@end
