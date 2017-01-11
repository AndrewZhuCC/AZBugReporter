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
#import "AZZJiraProjectsModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>

@interface AZZJiraCreateIssueFieldCell () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate>

@property (nonatomic, strong) AZZJiraIssueTypeFieldsModel *model;

@property (nonatomic, copy) NSArray *items;

@property (nonatomic, strong) UILabel *lbFieldTitle;
@property (nonatomic, strong) UITextField *tfInput;

@property (nonatomic, strong) UIButton *listButton;

@property (nonatomic, strong) UITableView *tbSelector;
@property (nonatomic, strong) UIToolbar *inputToolBar;

@property (nonatomic, assign) AZZJiraIssueFieldAllowedType type;

@property (nonatomic, strong) NSMutableSet *xmlElementsValue;

@end

@implementation AZZJiraCreateIssueFieldCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeFieldsModel *)model delegate:(id<AZZJiraCreateIssueFieldCellDelegate>)delegate value:(id)value {
    AZZJiraCreateIssueFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    if (!cell) {
        cell = [[AZZJiraCreateIssueFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.class)];
    }
    cell.delegate = delegate;
    [cell setupWithModel:model value:value];
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
    [self.listButton removeFromSuperview];
    self.listButton = nil;
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

- (void)setupWithModel:(AZZJiraIssueTypeFieldsModel *)model value:(id)value {
    self.model = model;
    self.lbFieldTitle.text = self.model.name;
    if (self.model.required) {
        self.lbFieldTitle.textColor = [UIColor redColor];
    }
    
    if (self.model.allowedValues.count > 0) {
        self.tfInput.inputView = self.tbSelector;
        self.tfInput.inputAccessoryView = self.inputToolBar;
    }
    
    if (self.model.autoCompleteUrl.length > 0 || [self.system isEqualToString:@"attachment"]) {
        [self.listButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-8);
        }];
    }
    
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
    
    switch (self.type) {
        case AZZJiraFieldType_Priority:
        {
            if (value) {
                AZZJiraIssuePriorityModel *model = value;
                self.tfInput.text = model.name;
            }
            break;
        }
        case AZZJiraFieldType_Version:
        {
            if (value) {
                if ([value isKindOfClass:[NSArray class]]) {
                    NSArray<AZZJiraIssueVersionModel *> *models = value;
                    if (models.count > 0) {
                        self.tfInput.text = models[0].name;
                    }
                }
            }
            break;
        }
        case AZZJiraFieldType_Component:
        {
            if (value) {
                if ([value isKindOfClass:[NSArray class]]) {
                    NSArray<AZZJiraComponentModel *> *models = value;
                    if (models.count > 0) {
                        self.tfInput.text = models[0].name;
                    }
                }
            }
            break;
        }
        case AZZJiraFieldType_User:
        {
            if (value) {
                AZZJiraUserModel *model = value;
                self.tfInput.text = model.displayName;
            }
            break;
        }
        case AZZJiraFieldType_Default:
        {
            if (value) {
                if ([self.system isEqualToString:@"labels"]) {
                    self.tfInput.text = value[0];
                } else {
                    self.tfInput.text = value;
                }
            }
            break;
        }
    }
}

- (NSString *)system {
    return self.model.system;
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    switch (self.type) {
        case AZZJiraFieldType_Default:
        {
            if ([self.delegate conformsToProtocol:@protocol(AZZJiraCreateIssueFieldCellDelegate)] && !self.tfInput.inputView) {
                [self.delegate fieldOfCell:self filledWithValue:textField.text type:AZZJiraFieldType_Default system:self.system];
            }
            break;
        }
        default:
        {
            break;
        }
    }
    return YES;
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
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
            cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:self.items[indexPath.row] imageURL:nil];
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - XML Parser Delegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSArray *uselessChars = @[@"<", @">", @"b", @"/b"];
    if (![uselessChars containsObject:string]) {
        [self.xmlElementsValue addObject:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([self.system isEqualToString:@"labels"]) {
        self.items = [self.xmlElementsValue allObjects];
        if (self.tfInput.inputView == self.tbSelector) {
            [self.tbSelector reloadData];
        }
    }
    
    self.xmlElementsValue = nil;
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
        _tbSelector = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220) style:UITableViewStylePlain];
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

- (UIButton *)listButton {
    if (!_listButton) {
        _listButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_listButton setImage:[UIImage imageNamed:@"azzglass"] forState:UIControlStateNormal];
        [_listButton addTarget:self action:@selector(listButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_listButton];
    }
    return _listButton;
}

- (NSMutableSet *)xmlElementsValue {
    if (!_xmlElementsValue) {
        _xmlElementsValue = [NSMutableSet set];
    }
    return _xmlElementsValue;
}

#pragma mark - ToolBar Actions

- (void)listButtonClicked:(UIButton *)button {
    self.tfInput.inputView = self.tbSelector;
    self.tfInput.inputAccessoryView = self.inputToolBar;
    
    __weak typeof(self) wself = self;
    if ([self.system isEqualToString:@"assignee"]) {
        [[AZZJiraClient sharedInstance] requestAssignableUsersWithProject:self.projectModel.key userName:self.tfInput.text issueKey:nil success:^(NSHTTPURLResponse *response, id responseObject) {
            if ([wself.system isEqualToString:@"assignee"]) {
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    NSArray *users = responseObject;
                    wself.items = [AZZJiraUserModel getUserModelsFromArray:users];
                    if (wself.tfInput.inputView == wself.tbSelector) {
                        [wself.tbSelector reloadData];
                    }
                }
            }
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get assignee failed: %@", error);
        }];
    } else if ([self.system isEqualToString:@"reporter"]) {
        [[AZZJiraClient sharedInstance] requestJSONOfMyselfSuccess:^(NSHTTPURLResponse *response, id responseObject) {
            if ([wself.system isEqualToString:@"reporter"]) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    AZZJiraUserModel *userModel = [AZZJiraUserModel getUserModelWithDictionary:responseObject];
                    wself.items = @[userModel];
                    if (wself.tfInput.inputView == wself.tbSelector) {
                        [wself.tbSelector reloadData];
                    }
                }
            }
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get self failed: %@", error);
        }];
    } else if ([self.system isEqualToString:@"labels"]) {
        [[AZZJiraClient sharedInstance] requestLabelsWithQuery:self.tfInput.text Susscess:^(NSHTTPURLResponse *response, NSXMLParser *responseObject) {
            if ([wself.system isEqualToString:@"labels"]) {
                responseObject.delegate = wself;
                [responseObject parse];
            }
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get labels failed: %@", error);
        }];
    }
    
    [self.tfInput resignFirstResponder];
    [self.tfInput becomeFirstResponder];
}

- (void)toolBarDoneClicked:(id)sender {
    NSIndexPath *indexPath = self.tbSelector.indexPathForSelectedRow;
    if (indexPath) {
        switch (self.type) {
            case AZZJiraFieldType_Priority:
            {
                AZZJiraIssuePriorityModel *model = self.items[indexPath.row];
                self.tfInput.text = model.name;
                break;
            }
            case AZZJiraFieldType_Version:
            {
                AZZJiraIssueVersionModel *model = self.items[indexPath.row];
                self.tfInput.text = model.name;
                break;
            }
            case AZZJiraFieldType_Component:
            {
                AZZJiraComponentModel *model = self.items[indexPath.row];
                self.tfInput.text = model.name;
                break;
            }
            case AZZJiraFieldType_User:
            {
                AZZJiraUserModel *model = self.items[indexPath.row];
                self.tfInput.text = model.displayName;
                break;
            }
            case AZZJiraFieldType_Default:
            {
                if (self.items.count >= indexPath.row + 1) {
                    self.tfInput.text = self.items[indexPath.row];
                }
                break;
            }
        }
        [self.tbSelector deselectRowAtIndexPath:indexPath animated:NO];
        if ([self.delegate conformsToProtocol:@protocol(AZZJiraCreateIssueFieldCellDelegate)]) {
            [self.delegate fieldOfCell:self filledWithValue:self.items[indexPath.row] type:self.type system:self.system];
        }
    }
    [self.tfInput resignFirstResponder];
    if (self.type == AZZJiraFieldType_Default || self.model.autoCompleteUrl.length > 0) {
        self.tfInput.inputView = nil;
        self.tfInput.inputAccessoryView = nil;
    }
}

- (void)toolBarCancelClicked:(id)sender {
    [self.tfInput resignFirstResponder];
    if (self.type == AZZJiraFieldType_Default || self.model.autoCompleteUrl.length > 0) {
        self.tfInput.inputView = nil;
        self.tfInput.inputAccessoryView = nil;
    }
}

@end
