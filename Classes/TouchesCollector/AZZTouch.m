//
//  AZZTouch.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/16.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZTouch.h"

@implementation AZZTouch

+ (instancetype)touchWithUITouch:(UITouch *)touch {
    return [[self alloc] initWithUITouch:touch];
}

+ (NSArray<AZZTouch *> *)touchesWithUIEvent:(UIEvent *)event {
    NSMutableArray *touches = [NSMutableArray array];
    NSArray *uitouches = [[event allTouches] allObjects];
    for (UITouch *touch in uitouches) {
        [touches addObject:[self touchWithUITouch:touch]];
    }
    return [touches copy];
}

- (instancetype)initWithUITouch:(UITouch *)touch {
    self = [super init];
    if (self) {
        _timestamp = touch.timestamp;
        _phase = touch.phase;
        _tapCount = touch.tapCount;
        _locationInKeyWindow = [touch locationInView:[UIApplication sharedApplication].keyWindow];
        _previousLocationInKeyWindow = [touch previousLocationInView:[UIApplication sharedApplication].keyWindow];
    }
    return self;
}

- (NSString *)description {
    NSString *phase;
    switch (self.phase) {
        case UITouchPhaseBegan:
            phase = @"Began";
            break;
        case UITouchPhaseMoved:
            phase = @"Moved";
            break;
        case UITouchPhaseEnded:
            phase = @"Ended";
            break;
        case UITouchPhaseCancelled:
            phase = @"Cancelled";
            break;
        case UITouchPhaseStationary:
            phase = @"Stationary";
            break;
    }
    return [NSString stringWithFormat:@"<AZZTouch: %p> phase: %@ tap count: %@ location in key window: %@ previous location in key window: %@", self, phase, @(self.tapCount), [NSValue valueWithCGPoint:self.locationInKeyWindow], [NSValue valueWithCGPoint:self.previousLocationInKeyWindow]];
}

@end
