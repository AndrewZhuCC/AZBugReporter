//
//  AZZJiraCreateIssueViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueTypeModel, AZZJiraProjectsModel;

@interface AZZJiraCreateIssueViewController : UIViewController

@property (nonatomic, strong) AZZJiraProjectsModel *projectModel;
@property (nonatomic, strong) AZZJiraIssueTypeModel *issueTypeModel;

@end
