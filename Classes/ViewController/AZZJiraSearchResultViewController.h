//
//  AZZJiraSearchResultViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2017/1/10.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface AZZJiraSearchResultViewController : UITableViewController

@property (nonatomic, strong) MBProgressHUD *hud;

- (void)showHudWithTitle:(NSString *)title detail:(NSString *)detail;
- (void)hideHudAfterDelay:(NSTimeInterval)delay;
- (void)showHudWithTitle:(NSString *)title detail:(NSString *)detail hideAfterDelay:(NSTimeInterval)delay;
- (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message confirmBlock:(void (^)())confirmBlock;


@end
