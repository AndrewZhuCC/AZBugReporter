//
//  AZZWindow.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/10.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZZWindow : UIWindow

+ (instancetype)sharedInstance;
- (void)collectionStart:(NSString *)title;
- (void)viewControllerDidAppear:(Class)vcClass;
- (void)viewControllerDidDisappear:(Class)vcClass;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *batterValues;

@end
