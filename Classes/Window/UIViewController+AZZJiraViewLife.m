//
//  UIViewController+AZZJiraViewLife.m
//  BugReporter
//
//  Created by 朱安智 on 2017/1/10.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "UIViewController+AZZJiraViewLife.h"
#import <objc/runtime.h>

#import "AZZWindow.h"

@implementation UIViewController (AZZJiraViewLife)

+ (void)load {
    Method orgDidMethod = class_getInstanceMethod([UIViewController class], NSSelectorFromString(@"_setViewAppearState:isAnimating:"));
    Method newDidMethod = class_getInstanceMethod([UIViewController class], @selector(azz_setViewAppearState:isAnimating:));
    method_exchangeImplementations(orgDidMethod, newDidMethod);
}

- (void)azz_setViewAppearState:(int)state isAnimating:(BOOL)animating {
    [self azz_setViewAppearState:state isAnimating:animating];
    if (state == 0) {
        [[AZZWindow sharedInstance] viewControllerDidDisappear:[self class]];
    } else if (state == 2) {
        [[AZZWindow sharedInstance] viewControllerDidAppear:[self class]];
    }
}

@end
