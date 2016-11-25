//
//  AZZJiraCreateIssueFieldCell.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraCreateIssueFieldCell.h"
#import "AZZJiraBasicCell.h"

#import "AZZJiraIssueTypeFieldsModel.h"
#import "AZZJiraIssuePriorityModel.h"
#import "AZZJiraComponentModel.h"
#import "AZZJiraIssueVersionModel.h"
#import "AZZJiraUserModel.h"

#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, AZZJiraIssueFieldAllowedType) {
    AZZJiraFieldType_Default,
    AZZJiraFieldType_Priority,
    AZZJiraFieldType_Component,
    AZZJiraFieldType_Version,
    AZZJiraFieldType_User,
};

@interface AZZJiraCreateIssueFieldCell () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AZZJiraIssueTypeFieldsModel *model;

@property (nonatomic, copy) NSArray *items;

@property (nonatomic, strong) UILabel *lbFieldTitle;
@property (nonatomic, strong) UITextField *tfInput;

@property (nonatomic, strong) UITableView *tbSelector;
@property (nonatomic, strong) UIToolbar *inputToolBar;

@property (nonatomic, assign) AZZJiraIssueFieldAllowedType type;

@end

@implementation AZZJiraCreateIssueFieldCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeFieldsModel *)model {
    AZZJiraCreateIssueFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    if (!cell) {
        cell = [[AZZJiraCreateIssueFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.class)];
    }
    [cell setupWithModel:model];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupConstraints];
        _type = AZZJiraFieldType_Default;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.lbFieldTitle.text = nil;
    self.lbFieldTitle.textColor = [UIColor blackColor];
    self.tfInput.text = nil;
    self.tfInput.inputView = nil;
    self.tfInput.inputAccessoryView = nil;
}

- (void)setupConstraints {
    [self.lbFieldTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(8);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    [self.tfInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbFieldTitle.mas_right).with.offset(5);
        make.centerY.equalTo(self.lbFieldTitle);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.height.equalTo(self.lbFieldTitle);
    }];
}

- (void)setupWithModel:(AZZJiraIssueTypeFieldsModel *)model {
    self.model = model;
    self.lbFieldTitle.text = self.model.name;
    if (self.model.required) {
        self.lbFieldTitle.textColor = [UIColor redColor];
    }
    if (self.model.allowedValues.count > 0 || self.model.autoCompleteUrl.length > 0) {
        self.tfInput.inputView = self.tbSelector;
        self.tfInput.inputAccessoryView = self.inputToolBar;
    }
    if (self.model.allowedValues.count > 0) {
        if ([self.model.type isEqualToString:@"priority"] || [self.model.items isEqualToString:@"priority"]) {
            self.items = [AZZJiraIssuePriorityModel getIssuePriorityModelsWithArray:self.model.allowedValues];
            self.type = AZZJiraFieldType_Priority;
        } else if ([self.model.type isEqualToString:@"component"] || [self.model.items isEqualToString:@"component"]) {
            self.items = [AZZJiraComponentModel getComponentModelsWithArray:self.model.allowedValues];
            self.type = AZZJiraFieldType_Component;
        } else if ([self.model.type isEqualToString:@"version"] || [self.model.items isEqualToString:@"version"]) {
            self.items = [AZZJiraIssueVersionModel getVersionModelsFromArray:self.model.allowedValues];
            self.type = AZZJiraFieldType_Version;
        } else if ([self.model.type isEqualToString:@"user"] || [self.model.items isEqualToString:@"user"]) {
            self.items = [AZZJiraUserModel getUserModelsFromArray:self.model.allowedValues];
            self.type = AZZJiraFieldType_User;
        }
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.allowedValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraBasicCell *cell = nil;
    switch (self.type) {
        case AZZJiraFieldType_Priority:
        {
            AZZJiraIssuePriorityModel *model = self.items[indexPath.row];
            cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:model.name imageURL:[model.iconUrl absoluteString]];
            break;
        }
        case AZZJiraFieldType_Version:
        {
            AZZJiraIssueVersionModel *model = self.items[indexPath.row];
            cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:model.name imageURL:nil];
            break;
        }
        case AZZJiraFieldType_Component:
        {
            AZZJiraComponentModel *model = self.items[indexPath.row];
            cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:model.name imageURL:nil];
            break;
        }
        case AZZJiraFieldType_User:
        {
            AZZJiraUserModel *model = self.items[indexPath.row];
            cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:model.displayName imageURL:model.avatarUrls[@"48x48"]];
            break;
        }
        case AZZJiraFieldType_Default:
        {
            break;
        }
    }
    return cell;
}

#pragma mark - Views

- (UILabel *)lbFieldTitle {
    if (!_lbFieldTitle) {
        _lbFieldTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbFieldTitle.backgroundColor = [UIColor clearColor];
        _lbFieldTitle.textColor = [UIColor blackColor];
        _lbFieldTitle.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_lbFieldTitle];
    }
    return _lbFieldTitle;
}

- (UITextField *)tfInput {
    if (!_tfInput) {
        _tfInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _tfInput.delegate = self;
        _tfInput.borderStyle = UITextBorderStyleRoundedRect;
        [self.contentView addSubview:_tfInput];
    }
    return _tfInput;
}

- (UITableView *)tbSelector {
    if (!_tbSelector) {
        _tbSelector = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120) style:UITableViewStylePlain];
        _tbSelector.delegate = self;
        _tbSelector.dataSource = self;
        _tbSelector.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tbSelector;
}

- (UIToolbar *)inputToolBar {
    if (!_inputToolBar) {
        _inputToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(toolBarCancelClicked:)];
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(toolBarDoneClicked:)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _inputToolBar.items = @[cancelItem, item, doneItem];
    }
    return _inputToolBar;
}

#pragma mark - ToolBar Actions

- (void)toolBarDoneClicked:(id)sender {
    [self.tfInput resignFirstResponder];
}

- (void)toolBarCancelClicked:(id)sender {
    [self.tfInput resignFirstResponder];
}

@end
