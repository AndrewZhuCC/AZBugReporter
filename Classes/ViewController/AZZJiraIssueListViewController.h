//
//  AZZJiraIssueListViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraBaseViewController.h"

@class AZZJiraProjectsModel;

@interface AZZJiraIssueListViewController : AZZJiraBaseViewController

@property (nonatomic, strong) AZZJiraProjectsModel *projectModel;

@end
