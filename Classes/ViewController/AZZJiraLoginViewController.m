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
#import <MBProgressHUD/MBProgressHUD.h>
#import <SAMKeychain/SAMKeychain.h>

@interface AZZJiraLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfUserName;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UIButton *btnCommit;

@property (nonatomic, strong) MBProgressHUD *hud;

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
        [SAMKeychain setPassword:self.tfPassword.text forService:AZZJiraKeyChainService account:self.tfUserName.text];
        wself.hud.label.text = @"Success";
        AZZJiraProjectsListViewController *listVC = [AZZJiraProjectsListViewController new];
        [wself.navigationController pushViewController:listVC animated:YES];
    } failure:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
//        NSLog(@"fail response:%@ error:%@", responseObject, error);
        wself.hud.mode = MBProgressHUDModeText;
        wself.hud.label.text = error.description;
        [wself.hud hideAnimated:YES afterDelay:3.0];
    }];
    
    self.hud.label.text = nil;
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud showAnimated:YES];
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
    [self.btnCommit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tfPassword.mas_bottom).with.offset(40);
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

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.label.numberOfLines = 0;
        [self.view addSubview:_hud];
    }
    return _hud;
}

@end
