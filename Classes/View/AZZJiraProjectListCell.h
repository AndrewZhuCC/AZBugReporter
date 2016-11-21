//
//  AZZJiraProjectListCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/21.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraProjectsModel;

@interface AZZJiraProjectListCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraProjectsModel *)model;

@end
