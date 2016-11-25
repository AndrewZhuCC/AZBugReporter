//
//  AZZJiraCreateIssueFieldCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueTypeFieldsModel;

@interface AZZJiraCreateIssueFieldCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeFieldsModel *)model;
- (void)setupWithModel:(AZZJiraIssueTypeFieldsModel *)model;

@end
