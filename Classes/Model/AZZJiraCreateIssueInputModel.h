//
//  AZZJiraCreateIssueInputModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "AZZJiraProjectsModel.h"
#import "AZZJiraIssueTypeModel.h"
#import "AZZJiraUserModel.h"
#import "AZZJiraIssuePriorityModel.h"
#import "AZZJiraIssueVersionModel.h"
#import "AZZJiraComponentModel.h"
#import "AZZJiraIssueAttachment.h"

@interface AZZJiraCreateIssueInputModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSDictionary *update;
@property (nonatomic, copy) AZZJiraProjectsModel *project;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) AZZJiraIssueTypeModel *issuetype;
@property (nonatomic, copy) AZZJiraUserModel *assignee;
@property (nonatomic, copy) AZZJiraUserModel *reporter;
@property (nonatomic, copy) NSDate *duedate;
@property (nonatomic, copy) AZZJiraIssuePriorityModel *priority;
@property (nonatomic, copy) NSArray *labels;
@property (nonatomic, copy) NSArray<AZZJiraIssueVersionModel *> *versions;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, copy) NSString *modelDescription;
@property (nonatomic, copy) NSArray<AZZJiraIssueVersionModel *> *fixVersions;
@property (nonatomic, copy) NSArray<AZZJiraComponentModel *> *components;
@property (nonatomic, copy) NSArray<AZZJiraIssueAttachment *> *attachment;

- (NSDictionary *)getJSONModel;

@end
