//
//  AZZJiraIssueListTableViewCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueModel;

@interface AZZJiraIssueListTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueModel *)model;
- (void)setupWithModel:(AZZJiraIssueModel *)model;

@end
