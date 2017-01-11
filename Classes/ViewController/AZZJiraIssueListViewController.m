//
//  AZZJiraIssueListViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueListViewController.h"
#import "AZZJiraSelectIssueTypeViewController.h"
#import "AZZJiraIssueDetailViewController.h"
#import "AZZJiraSearchResultViewController.h"

#import "AZZJiraIssueListTableViewCell.h"
#import "AZZJiraIssueModel.h"
#import "AZZJiraProjectsModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import <MJRefresh/MJRefresh.h>

@interface AZZJiraIssueListViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tbIssueList;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) AZZJiraSearchResultViewController *searchResultVC;
@property (nonatomic, copy) NSArray<AZZJiraIssueModel *> *searchResults;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.models.count == 0) {
        [self.tbIssueList.mj_header beginRefreshing];
    }
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
    [[AZZJiraClient sharedInstance] requestIssueListByProjectKey:self.projectModel.key searchText: nil start:self.models.count maxResult:50 success:^(NSHTTPURLResponse *response, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            wself.total = [[responseObject objectForKey:@"total"] unsignedIntegerValue];
            NSArray *issues = [responseObject objectForKey:@"issues"];
            if (!issues || wself.models.count >= wself.total) {
                [wself.tbIssueList.mj_footer endRefreshingWithNoMoreData];
                [wself.tbIssueList.mj_header endRefreshing];
            } else {
                [wself.models addObjectsFromArray:[AZZJiraIssueModel getIssueModelsWithJSONArray:issues]];
                [wself.tbIssueList.mj_footer endRefreshing];
                [wself.tbIssueList.mj_header endRefreshing];
                [wself.tbIssueList reloadData];
                wself.tbIssueList.allowsSelection = YES;
            }
        } else {
            NSLog(@"not dic");
        }
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"get issues fail with error: %@", error);
        NSLog(@"responseObject:%@", responseObject);
    }];
}

- (void)reloadIssuesByProjectKey {
    [self.models removeAllObjects];
    self.tbIssueList.allowsSelection = NO;
    [self requestIssuesByProjectKey];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tbIssueList) {
        return self.models.count;
    } else {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tbIssueList) {
        return [AZZJiraIssueListTableViewCell cellWithTableView:tableView model:self.models[indexPath.row]];
    } else {
        return [AZZJiraIssueListTableViewCell cellWithTableView:tableView model:self.searchResults[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AZZJiraIssueDetailViewController *vc = [AZZJiraIssueDetailViewController new];
    if (tableView == self.tbIssueList) {
        AZZJiraIssueModel *model = self.models[indexPath.row];
        vc.issueKey = model.key;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AZZJiraIssueModel *model = self.searchResults[indexPath.row];
        vc.issueKey = model.key;
        [self.searchResultVC dismissViewControllerAnimated:YES completion:^{
            [self didDismissSearchController:self.searchController];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueModel *model = self.models[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([AZZJiraIssueListTableViewCell class]) cacheByKey:model.idNumber configuration:^(AZZJiraIssueListTableViewCell *cell) {
        [cell setupWithModel:model];
    }];
}

#pragma mark - SearchControllerUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [[AZZJiraClient sharedInstance] requestIssueListByProjectKey:self.projectModel.key searchText:searchController.searchBar.text start:0 maxResult:100 success:^(NSHTTPURLResponse *response, id responseObject) {
        self.searchResults = [AZZJiraIssueModel getIssueModelsWithJSONArray:responseObject[@"issues"]];
        [self.searchResultVC.tableView reloadData];
        if (self.searchResults.count == 0) {
            [self.searchResultVC showHudWithTitle:@"No Results" detail:nil];
        } else {
            if (self.searchResultVC.hud.alpha != 0.f) {
                [self.searchResultVC hideHudAfterDelay:0];
            }
        }
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"search result error:%@", error);
        NSLog(@"responseObject:%@", responseObject);
    }];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    UIEdgeInsets originInsets = self.tbIssueList.contentInset;
    UIEdgeInsets scrollInsets = self.tbIssueList.scrollIndicatorInsets;
    CGFloat searchBarHeight = CGRectGetHeight(self.searchController.searchBar.frame);
    originInsets.top -= searchBarHeight;
    scrollInsets.top -= searchBarHeight;
    self.tbIssueList.contentInset = originInsets;
    self.tbIssueList.scrollIndicatorInsets = scrollInsets;
}

#pragma mark - Views

- (UITableView *)tbIssueList {
    if (!_tbIssueList) {
        _tbIssueList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbIssueList.delegate = self;
        _tbIssueList.dataSource = self;
        _tbIssueList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tbIssueList.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestIssuesByProjectKey)];
        _tbIssueList.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadIssuesByProjectKey)];
        _tbIssueList.tableHeaderView = self.searchController.searchBar;
        [_tbIssueList registerClass:[AZZJiraIssueListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraIssueListTableViewCell class])];
        [self.view addSubview:_tbIssueList];
    }
    return _tbIssueList;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultVC];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
    }
    return _searchController;
}

- (AZZJiraSearchResultViewController *)searchResultVC {
    if (!_searchResultVC) {
        _searchResultVC = [[AZZJiraSearchResultViewController alloc] initWithStyle:UITableViewStylePlain];
        _searchResultVC.tableView.delegate = self;
        _searchResultVC.tableView.dataSource = self;
        _searchResultVC.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchResultVC.automaticallyAdjustsScrollViewInsets = NO;
        _searchResultVC.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        [_searchResultVC.tableView registerClass:[AZZJiraIssueListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraIssueListTableViewCell class])];
    }
    return _searchResultVC;
}

- (NSMutableArray<AZZJiraIssueModel *> *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (NSArray<AZZJiraIssueModel *> *)searchResults {
    if (!_searchResults) {
        _searchResults = [NSArray array];
    }
    return _searchResults;
}

@end
