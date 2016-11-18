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

#import <AFNetworking/UIKit+AFNetworking.h>
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface AZZJiraProjectsListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<AZZJiraProjectsModel *> *projects;

@property (nonatomic, strong) UITableView *tbProjects;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AZZJiraProjectsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.viewControllers = @[self];
    self.title = @"Projects";
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestProjectsListSuccess:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"success:\n%@", responseObject);
        wself.projects = [AZZJiraProjectsModel getProjectsModelsWithJSONArray:responseObject];
        [wself.hud hideAnimated:YES];
        [wself.tbProjects reloadData];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"fail:\n%@", responseObject);
        wself.hud.label.text = error.description;
        wself.hud.mode = MBProgressHUDModeText;
        [wself.hud hideAnimated:YES afterDelay:3.0];
    }];
    
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = nil;
    [self.hud showAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews {
    [self.tbProjects mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"projectList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    AZZJiraProjectsModel *project = self.projects[indexPath.row];
    NSString *avatarURLString = project.avatarUrls[@"48x48"];
    if (avatarURLString.length > 0) {
        NSURL *avatarURL = [NSURL URLWithString:avatarURLString];
        if (avatarURL) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:avatarURL];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            __weak typeof(tableView) tbv = tableView;
            __weak typeof(cell) wcell = cell;
            [cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"layout-placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                wcell.imageView.image = image;
                [tbv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            }];
        }
    }
    cell.textLabel.text = project.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Views 

- (UITableView *)tbProjects {
    if (!_tbProjects) {
        _tbProjects = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbProjects.delegate = self;
        _tbProjects.dataSource = self;
        _tbProjects.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_tbProjects];
    }
    return _tbProjects;
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
