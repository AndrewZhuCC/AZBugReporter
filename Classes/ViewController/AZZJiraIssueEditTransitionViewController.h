//
//  AZZJiraIssueEditTransitionViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraBaseViewController.h"

@class AZZJiraIssueTransitionModel;

@interface AZZJiraIssueEditTransitionViewController : AZZJiraBaseViewController

@property (nonatomic, copy) NSString *issueId;
@property (nonatomic, copy) AZZJiraIssueTransitionModel *transition;

@end
