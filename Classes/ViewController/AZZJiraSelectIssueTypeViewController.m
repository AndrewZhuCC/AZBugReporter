//
//  AZZJiraSelectIssueTypeViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraSelectIssueTypeViewController.h"
#import "AZZJiraCreateIssueViewController.h"

#import "AZZJiraIssueTypeCell.h"

#import "AZZJiraIssueTypeModel.h"
#import "AZZJiraProjectsModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import "UITableView+FDTemplateLayoutCell.h"

@interface AZZJiraSelectIssueTypeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbIssues;
@property (nonatomic, copy) NSArray<AZZJiraIssueTypeModel *> *issueTypeModels;

@end

@implementation AZZJiraSelectIssueTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    self.title = @"Issue Types";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestCreateIssueMetaByProjectKey:self.projectModel.key success:^(NSHTTPURLResponse *response, id responseObject) {
        NSArray *jsonIssueTypes = [[[responseObject objectForKey:@"projects"] firstObject] objectForKey:@"issuetypes"];
        NSMutableArray *tempTypes = [NSMutableArray array];
        NSArray *models = [AZZJiraIssueTypeModel getIssueTypeModelsWithArray:jsonIssueTypes];
        for (AZZJiraIssueTypeModel *model in models) {
            if (!model.subtask) {
                [tempTypes addObject:model];
            }
        }
        wself.issueTypeModels = [tempTypes copy];
        [wself.tbIssues reloadData];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"select issue type fail with error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tbIssues mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.issueTypeModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AZZJiraIssueTypeCell cellWithTableView:tableView model:self.issueTypeModels[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueTypeModel *model = self.issueTypeModels[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([AZZJiraIssueTypeCell class]) cacheByKey:model.idNumber configuration:^(AZZJiraIssueTypeCell *cell) {
        [cell setupWithModel:model];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AZZJiraCreateIssueViewController *vc = [[AZZJiraCreateIssueViewController alloc] init];
    vc.projectModel = self.projectModel;
    vc.issueTypeModel = self.issueTypeModels[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Views

- (UITableView *)tbIssues {
    if (!_tbIssues) {
        _tbIssues = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbIssues.delegate = self;
        _tbIssues.dataSource = self;
        _tbIssues.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tbIssues registerClass:[AZZJiraIssueTypeCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraIssueTypeCell class])];
        [self.view addSubview:_tbIssues];
    }
    return _tbIssues;
}

@end
