//
//  AZZJiraIssueEditTransitionViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueEditTransitionViewController.h"

#import "AZZJiraClient.h"

#import "AZZJiraIssueTransitionModel.h"
#import "AZZJiraIssueResolutionModel.h"

#import <Masonry/Masonry.h>

@interface AZZJiraIssueEditTransitionViewController ()

@property (nonatomic, strong) UITextView *tvCommentBody;
@property (nonatomic, strong) UIButton *btnTransition;

@property (nonatomic, strong) AZZJiraIssueResolutionModel *selectedResolution;

@end

@implementation AZZJiraIssueEditTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupContraints];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(commitButtonClicked:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupContraints {
    [self.tvCommentBody mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(10.f + 64.f);
        make.left.equalTo(self.view).with.offset(10.f);
        make.right.bottom.equalTo(self.view).with.offset(-10.f);
    }];
}

#pragma mark - Actions

- (void)commitButtonClicked:(id)sneder {
    [self.tvCommentBody resignFirstResponder];
    if (self.transition) {
        if (!self.selectedResolution) {
            [self showConfirmAlertWithTitle:@"未选择解决结果" message:nil confirmBlock:^{
                [self transitionButtonClicked:nil];
            }];
        } else {
            [self showHudWithTitle:nil detail:nil];
            [[AZZJiraClient sharedInstance] requestDoTransitionWithIssueIdOrKey:self.issueId transitionId:self.transition.idNumber resolutionId:self.selectedResolution.idNumber commentBody:self.tvCommentBody.text success:^(NSHTTPURLResponse *response, id responseObject) {
                [self showHudWithTitle:@"成功" detail:nil];
                [self.navigationController popViewControllerAnimated:YES];
            } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                [self showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
                NSLog(@"do transition error:%@", error);
                NSLog(@"responseObject:%@", responseObject);
            }];
        }
    } else {
        if (self.tvCommentBody.text.length > 0) {
            [self showHudWithTitle:nil detail:nil];
            [[AZZJiraClient sharedInstance] requestAddCommentWithIssueIdOrKey:self.issueId commentBody:self.tvCommentBody.text success:^(NSHTTPURLResponse *response, id responseObject) {
                [self showHudWithTitle:@"成功" detail:nil];
                [self.navigationController popViewControllerAnimated:YES];
            } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                [self showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
                NSLog(@"add comment error:%@" ,error);
                NSLog(@"responseObject:%@", responseObject);
            }];
        } else {
            [self showHudWithTitle:nil detail:@"No Text" hideAfterDelay:3.f];
        }
    }
}

- (void)transitionButtonClicked:(UIButton *)button {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Resolutions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<AZZJiraIssueResolutionModel *> *resolutions = nil;
    for (NSString *key in self.transition.fields) {
        AZZJiraIssueTypeFieldsModel *fieldsModel = self.transition.fields[key];
        if (fieldsModel.required && [fieldsModel.system isEqualToString:@"resolution"]) {
            NSArray *allowedJson = fieldsModel.allowedValues;
             resolutions = [AZZJiraIssueResolutionModel getIssueResolutionModelsWithArray:allowedJson];
            break;
        }
    }
    for (AZZJiraIssueResolutionModel *resolution in resolutions) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:resolution.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedResolution = resolution;
            [self.btnTransition setTitle:resolution.name forState:UIControlStateNormal];
        }];
        [alertController addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Properties

- (UITextView *)tvCommentBody {
    if (!_tvCommentBody) {
        _tvCommentBody = [UITextView new];
        _tvCommentBody.layer.borderWidth = 1.f;
        _tvCommentBody.layer.borderColor = [UIColor blackColor].CGColor;
        _tvCommentBody.layer.cornerRadius = 5.f;
        _tvCommentBody.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.view addSubview:_tvCommentBody];
    }
    return _tvCommentBody;
}

- (UIButton *)btnTransition {
    if (!_btnTransition) {
        _btnTransition = [UIButton new];
        [_btnTransition setTitle:@"解决结果" forState:UIControlStateNormal];
        [_btnTransition setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnTransition.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnTransition.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnTransition.layer.cornerRadius = 5.f;
        [_btnTransition addTarget:self action:@selector(transitionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnTransition];
    }
    return _btnTransition;
}

- (void)setTransition:(AZZJiraIssueTransitionModel *)transition {
    _transition = [transition copy];
    [self.view class];
    if (_transition) {
        [self.tvCommentBody mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.view).with.offset(10.f);
            make.right.equalTo(self.view).with.offset(-10.f);
        }];
        [self.btnTransition mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tvCommentBody.mas_bottom).with.offset(20.f);
            make.bottom.equalTo(self.view).with.offset(-20.f);
            make.size.mas_equalTo(CGSizeMake(100.f, 40.f));
            make.centerX.equalTo(self.tvCommentBody);
        }];
    } else {
        [self.btnTransition removeFromSuperview];
        [self setupContraints];
    }
}

@end
