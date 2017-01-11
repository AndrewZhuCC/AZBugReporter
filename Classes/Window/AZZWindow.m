//
//  AZZWindow.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/10.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZWindow.h"
#import "UIWindow+SendEvent.h"
#import "AZZTouchesCollector.h"

#import "AZZJiraLoginViewController.h"

#import "AZPerformanceMonitor.h"

#define CurrentDeviceBatteryLevel [UIDevice currentDevice].batteryLevel

@interface AZZWindow ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIPanGestureRecognizer *panGrestureRecognizer;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *currentBatterValues;
@property (nonatomic, assign) BOOL collectValue;

@end

@implementation AZZWindow

+ (instancetype)sharedInstance {
    static AZZWindow *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AZZWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.windowLevel = UIWindowLevelStatusBar - 1.f;
    self.backgroundColor = [UIColor clearColor];
    
    AZZJiraLoginViewController *loginVC = [[AZZJiraLoginViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.rootViewController = nvc;
    [self.rootViewController.view setHidden:YES];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(-25, 300, 50, 50)];
    _button.layer.cornerRadius = 25;
    _button.layer.backgroundColor = [UIColor yellowColor].CGColor;
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.zPosition = 1000;
    [self addSubview:_button];
    
    self.panGrestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGrestureRecognized:)];
    [self.button addGestureRecognizer:self.panGrestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateDidChangedNotify:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWritingLogNotify:) name:AZPerformanceMonitorWritingLog object:nil];
#ifdef DEBUG
    self.collectValue = YES;
#else
    self.collectValue = [UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnplugged;
#endif
}

#pragma mark - BatteryNotification

- (void)viewControllerDidAppear:(Class)vcClass {
    if (self.collectValue) {
        NSString *className = NSStringFromClass(vcClass);
        [self.currentBatterValues setObject:@(CurrentDeviceBatteryLevel) forKey:className];
    }
}

- (void)viewControllerDidDisappear:(Class)vcClass {
    if (self.collectValue) {
        NSString *className = NSStringFromClass(vcClass);
        NSNumber *numValue = [self.batterValues objectForKey:className];
        if (!numValue) {
            numValue = @(0.0);
        }
        float batteryLevel = [numValue floatValue];
        batteryLevel += ([[self.currentBatterValues objectForKey:className] floatValue] - CurrentDeviceBatteryLevel);
        [self.batterValues setObject:@(batteryLevel) forKey:className];
        NSLog(@"CurrentBatteryUsage:%@", self.batterValues.debugDescription);
    }
}

- (void)batteryStateDidChangedNotify:(NSNotification *)notify {
#ifdef DEBUG
    self.collectValue = YES;
#else
    self.collectValue = [UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnplugged;
#endif
}

- (void)didWritingLogNotify:(NSNotification *)notify {
    AZPerformanceMonitor *monitor = notify.object;
    AZPerformanceMonitorConfiguration *config = monitor.config;
    switch (config.monitorType) {
        case MonitorType_CPU:
        {
            [self collectionStart:@"C"];
            break;
        }
        case MonitorType_RunLoop:
        {
            [self collectionStart:@"R"];
            break;
        }
    }
}

- (void)buttonTapped:(UIButton *)button {
    self.button.layer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.button setTitle:nil forState:UIControlStateNormal];
    self.rootViewController.view.hidden = !self.rootViewController.view.isHidden;
    [[AZZTouchesCollector sharedInstance] pauseCollect:!self.rootViewController.view.hidden];
    if (self.rootViewController.view.isHidden) {
        self.hidden = YES;
        self.hidden = NO;
    } else {
        [self makeKeyAndVisible];
    }
}

- (void)collectionStart:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.button.layer.backgroundColor = [UIColor redColor].CGColor;
        [self.button setTitle:title forState:UIControlStateNormal];
    });
}

- (void)becomeKeyWindow {
    NSLog(@"becomeKeyWindow");
}

- (void)resignKeyWindow {
    NSLog(@"resignKeyWindow");
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.rootViewController.view.isHidden) {
        return [self.button pointInside:[self.button convertPoint:point fromView:self] withEvent:event] ? self.button : nil;
    } else {
        return [self.button pointInside:[self.button convertPoint:point fromView:self] withEvent:event] ? self.button : [super hitTest:point withEvent:event];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

- (void)panGrestureRecognized:(UIPanGestureRecognizer *)panGr {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGPoint translation = [panGr translationInView:keyWindow];
    if (panGr.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = self.button.center;
    }
    self.button.center = CGPointMake(self.originalCenter.x + translation.x, self.originalCenter.y + translation.y);
    
    if (panGr.state == UIGestureRecognizerStateEnded) {
        CGRect screenBounds = self.bounds;
        [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.button.center.x > CGRectGetWidth(screenBounds) / 2.0) {
                self.button.center = CGPointMake(CGRectGetMaxX(screenBounds), self.button.center.y);
            } else {
                self.button.center = CGPointMake(0, self.button.center.y);
            }
        } completion:nil];
    }
}

- (NSMutableDictionary<NSString *,NSNumber *> *)batterValues {
    if (!_batterValues) {
        _batterValues = @{}.mutableCopy;
    }
    return _batterValues;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)currentBatterValues {
    if (!_currentBatterValues) {
        _currentBatterValues = @{}.mutableCopy;
    }
    return _currentBatterValues;
}

@end
