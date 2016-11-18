//
//  AZZWindow.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/10.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZWindow.h"
#import "UIWindow+SendEvent.h"

#import "AZZJiraLoginViewController.h"

@interface AZZWindow ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIPanGestureRecognizer *panGrestureRecognizer;
@property (nonatomic, assign) CGPoint originalCenter;

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
    self.windowLevel = UIWindowLevelStatusBar + 1.f;
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
}

- (void)buttonTapped:(UIButton *)button {
    NSLog(@"button tapped");
    self.rootViewController.view.hidden = !self.rootViewController.view.isHidden;
    self.hidden = YES;
    self.hidden = NO;
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
        return [self.button pointInside:[self.button convertPoint:point fromView:self] withEvent:event] ? self.button : [self.rootViewController.view hitTest:point withEvent:event];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"azz window touches began");
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

@end
