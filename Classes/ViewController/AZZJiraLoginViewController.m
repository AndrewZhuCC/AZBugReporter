//
//  AZZJiraLoginViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraLoginViewController.h"
#import "AZZJiraClient.h"
#import "AZZJiraProjectsListViewController.h"

#import "AZZJiraConfiguration.h"

#import <Photos/Photos.h>

#import <Masonry/Masonry.h>
#import <SAMKeychain/SAMKeychain.h>

@interface AZZJiraLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfUserName;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UIButton *btnCommit;
@property (nonatomic, strong) UILabel *lbRememberPassword;
@property (nonatomic, strong) UISwitch *swRememberPassword;
@property (nonatomic, strong) UIButton *btnSelectUser;

@end

@implementation AZZJiraLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
       [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    });
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.viewControllers = @[self];
    self.title = @"Login";
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)commitButtonTapped:(UIButton *)sender {
    [self.tfUserName resignFirstResponder];
    [self.tfPassword resignFirstResponder];
    
    NSString *userName = self.tfUserName.text;
    NSString *password = self.tfPassword.text;
    
    if (userName.length == 0) {
        userName = @"";
    }
    if (password.length == 0) {
        password = @"";
    }
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestLoginWithUserName:userName password:password success:^(NSHTTPURLResponse *response, id responseObject) {
//        NSLog(@"success response:%@", responseObject);
        if (wself.swRememberPassword.isOn) {
            [SAMKeychain setPassword:wself.tfPassword.text forService:AZZJiraKeyChainService account:wself.tfUserName.text];
        }
        [wself showHudWithTitle:@"Success" detail:nil];
        AZZJiraProjectsListViewController *listVC = [AZZJiraProjectsListViewController new];
        [wself.navigationController pushViewController:listVC animated:YES];
    } failure:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
//        NSLog(@"fail response:%@ error:%@", responseObject, error);
        [wself showHudWithTitle:@"Error" detail:error.description hideAfterDelay:3.f];
    }];
    
    [self showHudWithTitle:nil detail:nil];
}

- (void)selectUserButtonTapped:(UIButton *)button {
    NSArray *accounts = [SAMKeychain accountsForService:AZZJiraKeyChainService];
    if (accounts.count > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Users" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) wself = self;
        for (NSDictionary *accountDic in accounts) {
            NSString *account = [accountDic objectForKey:@"acct"];
            NSString *password = [SAMKeychain passwordForService:AZZJiraKeyChainService account:account];
            UIAlertAction *action = [UIAlertAction actionWithTitle:account style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                wself.tfUserName.text = account;
                wself.tfPassword.text = password;
            }];
            [alertController addAction:action];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.tfUserName isFirstResponder]) {
        [self.tfPassword becomeFirstResponder];
    } else {
        [self.tfPassword resignFirstResponder];
    }
    return YES;
}

#pragma mark - Views

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tfUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(30);
        make.height.mas_equalTo(40);
    }];
    [self.tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.top.equalTo(self.tfUserName.mas_bottom).with.offset(40);
        make.width.equalTo(self.tfUserName);
        make.height.equalTo(self.tfUserName);
    }];
    [self.lbRememberPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tfPassword.mas_bottom).with.offset(40);
    }];
    [self.swRememberPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbRememberPassword.mas_right).with.offset(8);
        make.centerY.equalTo(self.lbRememberPassword);
    }];
    [self.btnSelectUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.swRememberPassword.mas_bottom).with.offset(40);
        make.width.mas_equalTo(200);
    }];
    [self.btnCommit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.btnSelectUser.mas_bottom).with.offset(20);
        make.width.mas_equalTo(200);
    }];
    
    NSArray *accounts = [SAMKeychain accountsForService:AZZJiraKeyChainService];
    if (accounts.count > 0) {
        NSString *account = [[accounts lastObject] objectForKey:@"acct"];
        NSString *password = [SAMKeychain passwordForService:AZZJiraKeyChainService account:account];
        self.tfUserName.text = account;
        self.tfPassword.text = password;
    }
}

- (UITextField *)tfUserName {
    if (!_tfUserName) {
        _tfUserName = [[UITextField alloc] initWithFrame:CGRectZero];
        _tfUserName.placeholder = @"Jira Username";
        _tfUserName.delegate = self;
        _tfUserName.backgroundColor = [UIColor colorWithRed:0.230 green:0.794 blue:0.999 alpha:1.000];
        _tfUserName.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:_tfUserName];
    }
    return _tfUserName;
}

- (UITextField *)tfPassword {
    if (!_tfPassword) {
        _tfPassword = [[UITextField alloc] initWithFrame:CGRectZero];
        _tfPassword.placeholder = @"Jira Password";
        _tfPassword.delegate = self;
        _tfPassword.backgroundColor = [UIColor colorWithRed:0.230 green:0.794 blue:0.999 alpha:1.000];
        _tfPassword.borderStyle = UITextBorderStyleRoundedRect;
        _tfPassword.secureTextEntry = YES;
        _tfPassword.rightViewMode = UITextFieldViewModeAlways;
        [self.view addSubview:_tfPassword];
    }
    return _tfPassword;
}

- (UIButton *)btnCommit {
    if (!_btnCommit) {
        _btnCommit = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnCommit addTarget:self action:@selector(commitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_btnCommit setTitle:@"Commit" forState:UIControlStateNormal];
        _btnCommit.layer.cornerRadius = 5;
        _btnCommit.layer.backgroundColor = [UIColor redColor].CGColor;
        [self.view addSubview:_btnCommit];
    }
    return _btnCommit;
}

- (UILabel *)lbRememberPassword {
    if (!_lbRememberPassword) {
        _lbRememberPassword = [[UILabel alloc] init];
        _lbRememberPassword.font = [UIFont systemFontOfSize:15];
        _lbRememberPassword.text = @"Remember Me";
        _lbRememberPassword.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_lbRememberPassword];
    }
    return _lbRememberPassword;
}

- (UISwitch *)swRememberPassword {
    if (!_swRememberPassword) {
        _swRememberPassword = [[UISwitch alloc] init];
        _swRememberPassword.on = YES;
        [self.view addSubview:_swRememberPassword];
    }
    return _swRememberPassword;
}

- (UIButton *)btnSelectUser {
    if (!_btnSelectUser) {
        _btnSelectUser = [[UIButton alloc] init];
        [_btnSelectUser setTitle:@"Select User" forState:UIControlStateNormal];
        [_btnSelectUser addTarget:self action:@selector(selectUserButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _btnSelectUser.enabled = ([SAMKeychain accountsForService:AZZJiraKeyChainService].count > 0);
        _btnSelectUser.layer.cornerRadius = 5;
        _btnSelectUser.layer.backgroundColor = [UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1.000].CGColor;
        [self.view addSubview:_btnSelectUser];
    }
    return _btnSelectUser;
}

@end
