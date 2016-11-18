//
//  AZZTouch.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZZTouch : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval timestamp;
@property (nonatomic, assign, readonly) UITouchPhase phase;
@property (nonatomic, assign, readonly) NSUInteger tapCount;
@property (nonatomic, assign, readonly) CGPoint locationInKeyWindow;
@property (nonatomic, assign, readonly) CGPoint previousLocationInKeyWindow;

+ (instancetype)touchWithUITouch:(UITouch *)touch;
+ (NSArray<AZZTouch *> *)touchesWithUIEvent:(UIEvent *)event;

@end
