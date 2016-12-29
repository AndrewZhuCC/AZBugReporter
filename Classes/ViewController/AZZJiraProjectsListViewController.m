//
//  AZZJiraProjectsListViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraProjectsListViewController.h"
#import "AZZJiraClient.h"
#import "AZZJiraProjectsModel.h"
#import "AZZJiraProjectListCell.h"
#import "AZZJiraIssueListViewController.h"
#import "AZZJiraSettingsViewController.h"
#import "AZZJiraLoginViewController.h"

#import <AFNetworking/UIKit+AFNetworking.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraProjectsListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<AZZJiraProjectsModel *> *projects;

@property (nonatomic, strong) UITableView *tbProjects;

@end

@implementation AZZJiraProjectsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.viewControllers = @[self];
    self.title = @"Projects";
    [self setupSubviews];
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestProjectsListSuccess:^(NSHTTPURLResponse *response, id responseObject) {
        wself.projects = [AZZJiraProjectsModel getProjectsModelsWithJSONArray:responseObject];
        [wself hideHudAfterDelay:0];
        [wself.tbProjects reloadData];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        [wself showHudWithTitle:@"Error" detail:error.description hideAfterDelay:3.f];
    }];
    
    [self showHudWithTitle:nil detail:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews {
    [self.tbProjects mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Actions

- (void)logoutButtonTapped:(id)sender {
    [self showHudWithTitle:nil detail:nil];
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestLogoutSuccess:^(NSHTTPURLResponse *response, id responseObject) {
        AZZJiraLoginViewController *vc = [[AZZJiraLoginViewController alloc] init];
        [wself.navigationController pushViewController:vc animated:YES];
    } failure:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        [wself showHudWithTitle:@"Error" detail:error.description hideAfterDelay:3.f];
    }];
}

- (void)settingButtonTapped:(UIButton *)button {
    AZZJiraSettingsViewController *vc = [[AZZJiraSettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AZZJiraProjectListCell cellWithTableView:tableView model:self.projects[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AZZJiraIssueListViewController *vc = [[AZZJiraIssueListViewController alloc] init];
    vc.projectModel = self.projects[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Views 

- (UITableView *)tbProjects {
    if (!_tbProjects) {
        _tbProjects = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbProjects.delegate = self;
        _tbProjects.dataSource = self;
        _tbProjects.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tbProjects registerClass:[AZZJiraProjectListCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraProjectListCell class])];
        [self.view addSubview:_tbProjects];
    }
    return _tbProjects;
}

@end
