//
//  AZZJiraIssueListViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueListViewController.h"
#import "AZZJiraSelectIssueTypeViewController.h"

#import "AZZJiraIssueListTableViewCell.h"
#import "AZZJiraIssueModel.h"
#import "AZZJiraProjectsModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import <MJRefresh/MJRefresh.h>

@interface AZZJiraIssueListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbIssueList;

@property (nonatomic, strong) NSMutableArray<AZZJiraIssueModel *> *models;
@property (nonatomic, assign) NSUInteger total;

@end

@implementation AZZJiraIssueListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    [self setupCreateIssueButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestIssuesByProjectKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tbIssueList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.title = self.projectModel.name;
}

- (void)setupCreateIssueButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Create Issue" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - Actions

- (void)rightBarButtonItemClicked:(id)sender {
    AZZJiraSelectIssueTypeViewController *vc = [[AZZJiraSelectIssueTypeViewController alloc] init];
    vc.projectModel = self.projectModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Network

- (void)requestIssuesByProjectKey {
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestIssueListByProjectKey:self.projectModel.key start:self.models.count maxResult:50 success:^(NSHTTPURLResponse *response, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            wself.total = [[responseObject objectForKey:@"total"] unsignedIntegerValue];
            NSArray *issues = [responseObject objectForKey:@"issues"];
            if (!issues || wself.models.count >= wself.total) {
                [wself.tbIssueList.mj_footer endRefreshingWithNoMoreData];
            } else {
                [wself.models addObjectsFromArray:[AZZJiraIssueModel getIssueModelsWithJSONArray:issues]];
                [wself.tbIssueList.mj_footer endRefreshing];
                [wself.tbIssueList reloadData];
            }
        } else {
            NSLog(@"not dic");
        }
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"get issues fail with error: %@", error);
    }];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AZZJiraIssueListTableViewCell cellWithTableView:tableView model:self.models[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueModel *model = self.models[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([AZZJiraIssueListTableViewCell class]) cacheByKey:model.idNumber configuration:^(AZZJiraIssueListTableViewCell *cell) {
        [cell setupWithModel:model];
    }];
}

#pragma mark - Views

- (UITableView *)tbIssueList {
    if (!_tbIssueList) {
        _tbIssueList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbIssueList.delegate = self;
        _tbIssueList.dataSource = self;
        _tbIssueList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tbIssueList.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestIssuesByProjectKey)];
        [_tbIssueList registerClass:[AZZJiraIssueListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraIssueListTableViewCell class])];
        [self.view addSubview:_tbIssueList];
    }
    return _tbIssueList;
}

- (NSMutableArray<AZZJiraIssueModel *> *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

@end
