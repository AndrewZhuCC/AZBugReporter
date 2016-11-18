//
//  AZZJiraLoginViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraLoginViewController.h"
#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>

@interface AZZJiraLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfUserName;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UIButton *btnCommit;

@end

@implementation AZZJiraLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    [[AZZJiraClient sharedInstance] requestLoginWithUserName:userName password:password success:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"success response:%@", responseObject);
    } failure:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"fail response:%@ error:%@", responseObject, error);
    }];
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

@end
