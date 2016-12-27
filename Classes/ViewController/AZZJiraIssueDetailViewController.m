//
//  AZZJiraIssueDetailViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/27.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueDetailViewController.h"
#import "AZZJiraAttachmentListViewController.h"

#import "AZZJiraIssueModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define IssueDetailViewsPadding 8.f

@interface AZZJiraIssueDetailViewController ()

@property (nonatomic, strong) AZZJiraIssueModel *model;

@property (nonatomic, strong) UILabel *lbAssignee;
@property (nonatomic, strong) UIImageView *ivAssignee;
@property (nonatomic, strong) UILabel *lbAssigneeName;

@property (nonatomic, strong) UILabel *lbReporter;
@property (nonatomic, strong) UIImageView *ivReporter;
@property (nonatomic, strong) UILabel *lbReporterName;

@property (nonatomic, strong) UIButton *btnAssignMe;
@property (nonatomic, strong) UIButton *btnAttachments;

@property (nonatomic, strong) UILabel *lbSolution;

@property (nonatomic, strong) UILabel *lbEnvironment;
@property (nonatomic, strong) UITextView *txvEnvironment;

@property (nonatomic, strong) UILabel *lbDescription;
@property (nonatomic, strong) UITextView *txvDescription;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AZZJiraIssueDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.lbAssignee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.f + IssueDetailViewsPadding);
        make.left.equalTo(self.view).with.offset(IssueDetailViewsPadding);
        make.height.mas_equalTo(40);
    }];
    [self.lbReporter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbAssignee);
        make.left.equalTo(self.lbAssignee.mas_right).with.offset(IssueDetailViewsPadding);
        make.right.equalTo(self.view).with.offset(-IssueDetailViewsPadding);
        make.size.equalTo(self.lbAssignee);
    }];
    [self.ivAssignee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbAssignee);
        make.centerY.equalTo(self.lbAssigneeName);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.lbAssigneeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivAssignee.mas_right);
        make.top.equalTo(self.lbAssignee.mas_bottom).with.offset(5.f);
        make.right.equalTo(self.lbAssignee);
        make.height.equalTo(self.lbAssignee);
    }];
    [self.ivReporter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbReporter);
        make.centerY.equalTo(self.lbReporterName);
        make.size.equalTo(self.ivAssignee);
    }];
    [self.lbReporterName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivReporter.mas_right);
        make.size.and.top.equalTo(self.lbAssigneeName);
    }];
    [self.btnAssignMe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbAssigneeName.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.centerX.equalTo(self.lbAssignee);
        make.width.equalTo(self.lbAssignee);
        make.height.mas_equalTo(30);
    }];
    [self.btnAttachments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbReporterName.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.centerX.equalTo(self.lbReporter);
        make.size.equalTo(self.btnAssignMe);
    }];
    [self.lbSolution mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnAssignMe.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.left.equalTo(self.lbAssignee);
        make.right.equalTo(self.lbReporter);
        make.height.mas_equalTo(40);
    }];
    CGSize environmentSize = [self.lbEnvironment sizeThatFits:CGSizeMake(CGFLOAT_MAX, 40)];
    [self.lbEnvironment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbSolution.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.size.mas_equalTo(environmentSize);
        make.left.equalTo(self.lbAssignee);
    }];
    [self.txvEnvironment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbEnvironment.mas_right).with.offset(5.f);
        make.right.equalTo(self.lbReporter);
        make.top.equalTo(self.lbEnvironment);
        make.height.mas_equalTo(80);
    }];
    [self.lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.and.left.equalTo(self.lbEnvironment);
        make.top.equalTo(self.txvEnvironment.mas_bottom).with.offset(IssueDetailViewsPadding);
    }];
    [self.txvDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.lbSolution);
        make.top.equalTo(self.lbDescription.mas_bottom).with.offset(5.f);
        make.bottom.equalTo(self.view).with.offset(-IssueDetailViewsPadding);
    }];
}

#pragma mark - Actions

- (void)btnAssignMeClicked:(UIButton *)button {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"分配" message:@"确认分配给你？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showHudWithTitle:nil detail:nil];
        __weak typeof(self) wself = self;
        [[AZZJiraClient sharedInstance] requestAssignIssue:self.model.key success:^(NSHTTPURLResponse *response, id responseObject) {
            [wself showHudWithTitle:@"成功" detail:nil];
            [wself.hud hideAnimated:YES afterDelay:2.f];
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            [wself showHudWithTitle:@"Error" detail:[responseObject description]];
            [wself.hud hideAnimated:YES afterDelay:3.f];
            NSLog(@"Assign to me error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
    }];
    [alertController addAction:confirm];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)btnAttachmentsClicked:(UIButton *)button {
    AZZJiraAttachmentListViewController *vc = [AZZJiraAttachmentListViewController new];
    vc.issueModel = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Properties

- (UILabel *)lbAssignee {
    if (!_lbAssignee) {
        _lbAssignee = [UILabel new];
        _lbAssignee.font = [UIFont systemFontOfSize:15];
        _lbAssignee.text = @"经办人:";
        [self.view addSubview:_lbAssignee];
    }
    return _lbAssignee;
}

- (UIImageView *)ivAssignee {
    if (!_ivAssignee) {
        _ivAssignee = [UIImageView new];
        _ivAssignee.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_ivAssignee];
    }
    return _ivAssignee;
}

- (UILabel *)lbAssigneeName {
    if (!_lbAssigneeName) {
        _lbAssigneeName = [UILabel new];
        [self.view addSubview:_lbAssigneeName];
    }
    return _lbAssigneeName;
}

- (UILabel *)lbReporter {
    if (!_lbReporter) {
        _lbReporter = [UILabel new];
        _lbReporter.font = [UIFont systemFontOfSize:15];
        _lbReporter.text = @"报告人:";
        [self.view addSubview:_lbReporter];
    }
    return _lbReporter;
}

- (UIImageView *)ivReporter {
    if (!_ivReporter) {
        _ivReporter = [UIImageView new];
        _ivReporter.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_ivReporter];
    }
    return _ivReporter;
}

- (UILabel *)lbReporterName {
    if (!_lbReporterName) {
        _lbReporterName = [UILabel new];
        [self.view addSubview:_lbReporterName];
    }
    return _lbReporterName;
}

- (UIButton *)btnAssignMe {
    if (!_btnAssignMe) {
        _btnAssignMe = [UIButton new];
        [_btnAssignMe setTitle:@"分配给我" forState:UIControlStateNormal];
        [_btnAssignMe setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAssignMe setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAssignMe.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAssignMe.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAssignMe.layer.cornerRadius = 5.f;
        [_btnAssignMe addTarget:self action:@selector(btnAssignMeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnAssignMe];
    }
    return _btnAssignMe;
}

- (UIButton *)btnAttachments {
    if (!_btnAttachments) {
        _btnAttachments = [UIButton new];
        [_btnAttachments setTitle:@"附件" forState:UIControlStateNormal];
        [_btnAttachments setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAttachments setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAttachments.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAttachments.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAttachments.layer.cornerRadius = 5.f;
        [_btnAttachments addTarget:self action:@selector(btnAttachmentsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnAttachments];
    }
    return _btnAttachments;
}

- (UILabel *)lbSolution {
    if (!_lbSolution) {
        _lbSolution = [UILabel new];
        [self.view addSubview:_lbSolution];
    }
    return _lbSolution;
}

- (UILabel *)lbEnvironment {
    if (!_lbEnvironment) {
        _lbEnvironment = [UILabel new];
        _lbEnvironment.text = @"环境:";
        [self.view addSubview:_lbEnvironment];
    }
    return _lbEnvironment;
}

- (UITextView *)txvEnvironment {
    if (!_txvEnvironment) {
        _txvEnvironment = [UITextView new];
        _txvEnvironment.editable = NO;
        _txvEnvironment.layer.borderWidth = 1.f;
        _txvEnvironment.layer.borderColor = [UIColor blackColor].CGColor;
        _txvEnvironment.layer.cornerRadius = 5.f;
        [self.view addSubview:_txvEnvironment];
    }
    return _txvEnvironment;
}

- (UILabel *)lbDescription {
    if (!_lbDescription) {
        _lbDescription = [UILabel new];
        _lbDescription.text = @"描述:";
        [self.view addSubview:_lbDescription];
    }
    return _lbDescription;
}

- (UITextView *)txvDescription {
    if (!_txvDescription) {
        _txvDescription = [UITextView new];
        _txvDescription.editable = NO;
        _txvDescription.layer.borderWidth = 1.f;
        _txvDescription.layer.borderColor = [UIColor blackColor].CGColor;
        _txvDescription.layer.cornerRadius = 5.f;
        [self.view addSubview:_txvDescription];
    }
    return _txvDescription;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

- (void)setIssueKey:(NSString *)issueKey {
    _issueKey = [issueKey copy];
    if (issueKey) {
        __weak typeof(self) wself = self;
        [[AZZJiraClient sharedInstance] requestIssueByIssueKey:issueKey success:^(NSHTTPURLResponse *response, id responseObject) {
            AZZJiraIssueModel *model = [AZZJiraIssueModel getIssueModelWithDictionary:responseObject];
            typeof(wself) sself = wself;
            if (model && sself) {
                sself.model = model;
            }
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get issue model error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
    }
}

- (void)setModel:(AZZJiraIssueModel *)model {
    _model = model;
    if (model) {
        [self.view class];
        self.title = model.key;
        
        if (model.assignee) {
            NSURL *assigneeUrl = [NSURL URLWithString:model.assignee.avatarUrls[@"48x48"]];
            [self.ivAssignee sd_setImageWithURL:assigneeUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageRetryFailed | SDWebImageHandleCookies];
            self.lbAssigneeName.text = model.assignee.displayName;
        } else {
            self.ivAssignee.image = [UIImage imageNamed:@"layout-placeholder"];
            self.lbAssigneeName.text = @"未分配";
        }
        
        NSURL *reporterUrl = [NSURL URLWithString:model.reporter.avatarUrls[@"48x48"]];
        [self.ivReporter sd_setImageWithURL:reporterUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageRetryFailed | SDWebImageHandleCookies];
        self.lbReporterName.text = model.reporter.displayName;
        
        if (model.resolution) {
            self.lbSolution.text = [NSString stringWithFormat:@"解决结果: %@", model.resolution.name];
        } else {
            self.lbSolution.text = @"解决结果: 未解决";
        }
        self.txvEnvironment.text = model.environment;
        self.txvDescription.text = model.modelDescription;
        
        self.btnAttachments.enabled = (self.model.attachment.count != 0);
        self.btnAssignMe.enabled = ![self.model.assignee isEqual:[AZZJiraClient sharedInstance].selfModel];
    }
}

- (void)showHudWithTitle:(NSString *)title detail:(NSString *)detail {
    if (title || detail) {
        self.hud.mode = MBProgressHUDModeText;
    } else {
        self.hud.mode = MBProgressHUDModeIndeterminate;
    }
    self.hud.label.text = title;
    self.hud.detailsLabel.text = detail;
    [self.hud showAnimated:YES];
}

@end
