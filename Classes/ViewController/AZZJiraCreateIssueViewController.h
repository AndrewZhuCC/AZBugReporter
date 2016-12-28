//
//  AZZJiraCreateIssueViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraBaseViewController.h"

@class AZZJiraIssueTypeModel, AZZJiraProjectsModel;

@interface AZZJiraCreateIssueViewController : AZZJiraBaseViewController

@property (nonatomic, strong) AZZJiraProjectsModel *projectModel;
@property (nonatomic, strong) AZZJiraIssueTypeModel *issueTypeModel;

@end
