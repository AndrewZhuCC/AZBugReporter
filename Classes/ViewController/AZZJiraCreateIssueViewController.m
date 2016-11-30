//
//  AZZJiraCreateIssueViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraCreateIssueViewController.h"

#import "AZZJiraCreateIssueFieldCell.h"

#import "AZZJiraIssueTypeFieldsModel.h"
#import "AZZJiraProjectsModel.h"
#import "AZZJiraIssueTypeModel.h"
#import "AZZJiraCreateIssueInputModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>

@interface AZZJiraCreateIssueViewController () <UITableViewDelegate, UITableViewDataSource, AZZJiraCreateIssueFieldCellDelegate>

@property (nonatomic, strong) UITableView *tvInputs;

@property (nonatomic, copy) NSDictionary<NSString *, AZZJiraIssueTypeFieldsModel *> *fieldsModels;
@property (nonatomic, copy) NSArray *allModelKeys;

@property (nonatomic, strong) AZZJiraCreateIssueInputModel *inputModel;

@end

@implementation AZZJiraCreateIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    [self setupNavigationItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestCreateIssueFieldsWithProjectKey:self.projectModel.key issueTypeId:self.issueTypeModel.idNumber success:^(NSHTTPURLResponse *response, id responseObject) {
        NSDictionary *jsonDic = responseObject[@"projects"][0][@"issuetypes"][0][@"fields"];
        wself.fieldsModels = [AZZJiraIssueTypeFieldsModel getFieldsDictionaryWithDictionary:jsonDic];
        [wself.tvInputs reloadData];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"request create issue fields failed: %@", error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupConstraints {
    [self.tvInputs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNavigationItem {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createIssueButtonTapped:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)createIssueButtonTapped:(id)sender {
    [[AZZJiraClient sharedInstance] requestCreateIssueWith:self.inputModel success:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"create issue success:%@", responseObject);
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"create issue fail:%@", error);
        NSLog(@"responseObject: %@", responseObject);
    }];
}

#pragma mark - FieldValue

- (void)fieldOfCell:(AZZJiraCreateIssueFieldCell *)cell filledWithValue:(id)value type:(AZZJiraIssueFieldAllowedType)type system:(NSString *)system {
    
    if ([system isEqualToString:@"labels"]) {
        [self.inputModel setValue:@[value] forKey:system];
        return;
    }
    
    switch (type) {
        case AZZJiraFieldType_Version:
        case AZZJiraFieldType_Component:
        {
            [self.inputModel setValue:@[value] forKey:system];
            break;
        }
        case AZZJiraFieldType_Priority:
        case AZZJiraFieldType_User:
        case AZZJiraFieldType_Default:
        {
            [self.inputModel setValue:value forKey:system];
            break;
        }
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allModelKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueTypeFieldsModel *model = self.fieldsModels[self.allModelKeys[indexPath.row]];
    AZZJiraCreateIssueFieldCell *cell = [AZZJiraCreateIssueFieldCell cellWithTableView:tableView model:model delegate:self value:[self.inputModel valueForKey:model.system]];
    cell.projectModel = self.projectModel;
    return cell;
}

- (void)setFieldsModels:(NSDictionary<NSString *,AZZJiraIssueTypeFieldsModel *> *)fieldsModels {
    _fieldsModels = [fieldsModels copy];
    NSArray *sortedKeys = @[@"summary", @"priority", @"duedate", @"components", @"versions", @"fixVersions", @"assignee", @"reporter", @"environment", @"description", @"attachment", @"labels"];
    NSMutableArray *tempKeys = [fieldsModels.allKeys mutableCopy];
    [tempKeys removeObjectsInArray:@[@"issuetype", @"project", @"timetracking"]];
    self.allModelKeys = [tempKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger idx1 = [sortedKeys indexOfObject:obj1];
        NSInteger idx2 = [sortedKeys indexOfObject:obj2];
        if (idx1 == NSNotFound && idx2 == NSNotFound) {
            NSLog(@"key not found:%@ ,%@", obj1, obj2);
            return NSOrderedSame;
        }
        if (idx1 == NSNotFound) {
            NSLog(@"key not found:%@", obj1);
            return NSOrderedDescending;
        }
        if (idx2 == NSNotFound) {
            NSLog(@"key not found:%@", obj2);
            return NSOrderedAscending;
        }
        if (idx1 > idx2) {
            return NSOrderedDescending;
        } else if (idx1 == idx2) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueTypeFieldsModel *model = self.fieldsModels[self.allModelKeys[indexPath.row]];
    __weak typeof(self) wself = self;
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([AZZJiraCreateIssueFieldCell class]) cacheByKey:model.system configuration:^(AZZJiraCreateIssueFieldCell *cell) {
        [cell setupWithModel:model value:nil];
        cell.projectModel = wself.projectModel;
    }];
}

#pragma mark - Views

- (UITableView *)tvInputs {
    if (!_tvInputs) {
        _tvInputs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvInputs.delegate = self;
        _tvInputs.dataSource = self;
        _tvInputs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tvInputs.allowsSelection = NO;
        [_tvInputs registerClass:[AZZJiraCreateIssueFieldCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraCreateIssueFieldCell class])];
        [self.view addSubview:_tvInputs];
    }
    return _tvInputs;
}

- (AZZJiraCreateIssueInputModel *)inputModel {
    if (!_inputModel) {
        _inputModel = [[AZZJiraCreateIssueInputModel alloc] init];
        _inputModel.project = self.projectModel;
        _inputModel.issuetype = self.issueTypeModel;
    }
    return _inputModel;
}

@end
