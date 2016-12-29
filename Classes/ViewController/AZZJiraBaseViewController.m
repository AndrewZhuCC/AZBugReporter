//
//  AZZJiraBaseViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraBaseViewController.h"

@interface AZZJiraBaseViewController ()

@end

@implementation AZZJiraBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

#pragma mark - Tools

- (void)showHudWithTitle:(NSString *)title detail:(NSString *)detail {
    if (title || detail) {
        self.hud.mode = MBProgressHUDModeText;
    } else {
        self.hud.mode = MBProgressHUDModeIndeterminate;
    }
    self.hud.labelText = title;
    self.hud.detailsLabelText = detail;
    [self.hud show:YES];
}

- (void)hideHudAfterDelay:(NSTimeInterval)delay {
    if (delay == 0) {
        [self.hud hide:YES];
    } else {
        [self.hud hide:YES afterDelay:delay];
    }
}

- (void)showHudWithTitle:(NSString *)title detail:(NSString *)detail hideAfterDelay:(NSTimeInterval)delay {
    [self showHudWithTitle:title detail:detail];
    [self hideHudAfterDelay:delay];
}

- (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message confirmBlock:(void (^)())confirmBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmBlock();
    }];
    [alertController addAction:confirm];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
