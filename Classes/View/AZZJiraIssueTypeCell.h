//
//  AZZJiraIssueTypeCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueTypeModel;

@interface AZZJiraIssueTypeCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeModel *)model;
- (void)setupWithModel:(AZZJiraIssueTypeModel *)model;

@end
