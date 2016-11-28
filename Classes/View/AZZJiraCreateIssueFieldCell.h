//
//  AZZJiraCreateIssueFieldCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueTypeFieldsModel;
@class AZZJiraCreateIssueFieldCell;
@class AZZJiraProjectsModel;

typedef NS_ENUM(NSUInteger, AZZJiraIssueFieldAllowedType) {
    AZZJiraFieldType_Default,
    AZZJiraFieldType_Priority,
    AZZJiraFieldType_Component,
    AZZJiraFieldType_Version,
    AZZJiraFieldType_User,
};

@protocol AZZJiraCreateIssueFieldCellDelegate <NSObject>

@required
- (void)fieldOfCell:(AZZJiraCreateIssueFieldCell *)cell filledWithValue:(id)value type:(AZZJiraIssueFieldAllowedType)type system:(NSString *)system;

@end

@interface AZZJiraCreateIssueFieldCell : UITableViewCell

@property (nonatomic, weak) id<AZZJiraCreateIssueFieldCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeFieldsModel *)model delegate:(id<AZZJiraCreateIssueFieldCellDelegate>)delegate value:(id)value;
- (void)setupWithModel:(AZZJiraIssueTypeFieldsModel *)model value:(id)value;

@property (nonatomic, strong, readonly) NSString *system;
@property (nonatomic, strong) AZZJiraProjectsModel *projectModel;

@end
