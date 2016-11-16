//
//  UIWindow+SendEvent.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/11.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "UIWindow+SendEvent.h"
#import <objc/runtime.h>

NSNotificationName const AZZTouchesDidSentByUIWindow = @"AZZTouchesDidSentByUIWindow";

@implementation UIWindow (SendEvent)

+ (void)load {
    Method orgMethod = class_getInstanceMethod([UIWindow class], NSSelectorFromString(@"_sendTouchesForEvent:"));
    Method newMethod = class_getInstanceMethod([UIWindow class], @selector(azz_sendTouchesForEvent:));
    method_exchangeImplementations(orgMethod, newMethod);
}

- (void)azz_sendTouchesForEvent:(UIEvent *)event {
    NSArray *touches = [AZZTouch touchesWithUIEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:AZZTouchesDidSentByUIWindow object:self userInfo:@{@"touches":touches}];
    [self azz_sendTouchesForEvent:event];
}

@end
