//
//  AZZJiraFileAttachmentViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/6.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraFileAttachmentViewController.h"

#import <Masonry/Masonry.h>

@interface AZZJiraFileAttachmentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tvFileNodes;

@end

@implementation AZZJiraFileAttachmentViewController

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
    [self.tvFileNodes mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender {
    if ([self.delegate conformsToProtocol:@protocol(AZZJiraFileAttachmentDelegate)]) {
        [self.delegate fileAttachmentDidTappedDoneButton];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNode.subpaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileNodeCell"];
    AZZJiraFileNode *fileNode = self.fileNode.subpaths[indexPath.row];
    cell.textLabel.text = fileNode.fileName;
    if (fileNode.isDirectory) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraFileNode *fileNode = self.fileNode.subpaths[indexPath.row];
    if (fileNode.isDirectory) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        AZZJiraFileAttachmentViewController *vc = [[AZZJiraFileAttachmentViewController alloc] init];
        vc.fileNode = fileNode;
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if ([self.delegate conformsToProtocol:@protocol(AZZJiraFileAttachmentDelegate)]) {
            [self.delegate fileAttachmentDidSelect:fileNode selected:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraFileNode *fileNode = self.fileNode.subpaths[indexPath.row];
    if (!fileNode.isDirectory) {
        if ([self.delegate conformsToProtocol:@protocol(AZZJiraFileAttachmentDelegate)]) {
            [self.delegate fileAttachmentDidSelect:fileNode selected:NO];
        }
    }
}

#pragma mark - Propertys

- (UITableView *)tvFileNodes {
    if (!_tvFileNodes) {
        _tvFileNodes = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvFileNodes.delegate = self;
        _tvFileNodes.dataSource = self;
        _tvFileNodes.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tvFileNodes.allowsMultipleSelection = YES;
        [_tvFileNodes registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fileNodeCell"];
        [self.view addSubview:_tvFileNodes];
    }
    return _tvFileNodes;
}

- (void)setFileNode:(AZZJiraFileNode *)fileNode {
    _fileNode = fileNode;
    self.title = fileNode.fileName;
    if (self.view) {
        [self.tvFileNodes reloadData];
    }
}

@end
