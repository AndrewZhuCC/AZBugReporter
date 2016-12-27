//
//  AZZJiraAttachmentListViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/27.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraAttachmentListViewController.h"
#import "AZZJiraLogPreviewViewController.h"

#import "AZZJiraFileNode.h"

#import "AZZJiraIssueModel.h"

#import <Masonry/Masonry.h>

#define AZZJiraAttachmentListID @"azzjiraattid"

@interface AZZJiraAttachmentListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tvAttachments;

@end

@implementation AZZJiraAttachmentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tvAttachments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.issueModel.attachment.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AZZJiraAttachmentListID forIndexPath:indexPath];
    AZZJiraIssueAttachment *model = self.issueModel.attachment[indexPath.row];
    cell.textLabel.text = model.filename;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AZZJiraIssueAttachment *model = self.issueModel.attachment[indexPath.row];
    AZZJiraFileNode *fileNode = [AZZJiraFileNode fileNodeWithURL:model.content];
    AZZJiraLogPreviewViewController *vc = [AZZJiraLogPreviewViewController new];
    vc.fileNode = fileNode;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Properties

- (UITableView *)tvAttachments {
    if (!_tvAttachments) {
        _tvAttachments = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvAttachments.delegate = self;
        _tvAttachments.dataSource = self;
        [_tvAttachments registerClass:[UITableViewCell class] forCellReuseIdentifier:AZZJiraAttachmentListID];
        [self.view addSubview:_tvAttachments];
    }
    return _tvAttachments;
}

- (void)setIssueModel:(AZZJiraIssueModel *)issueModel {
    _issueModel = issueModel;
    [self.view class];
    if (issueModel) {
        [self.tvAttachments reloadData];
    }
}

@end
