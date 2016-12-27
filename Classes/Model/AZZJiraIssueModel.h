//
//  AZZJiraIssueModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueTypeModel.h"
#import "AZZJiraUserModel.h"
#import "AZZJiraIssuePriorityModel.h"
#import "AZZJiraIssueStatusModel.h"
#import "AZZJiraIssueAttachment.h"
#import "AZZJiraProjectsModel.h"
#import "AZZJiraIssueVersionModel.h"
#import "AZZJiraIssueCommentModel.h"
#import "AZZJiraIssueResolutionModel.h"

#import <Mantle/Mantle.h>

@interface AZZJiraIssueModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *key;

@property (nonatomic, copy, readonly) NSString *summary;
@property (nonatomic, copy, readonly) AZZJiraIssueTypeModel *issueType;
@property (nonatomic, copy, readonly) AZZJiraIssueResolutionModel *resolution;
@property (nonatomic, copy, readonly) NSArray<AZZJiraIssueVersionModel *> *fixVersions;
@property (nonatomic, copy, readonly) NSDate *resolutiondate;
@property (nonatomic, copy, readonly) AZZJiraUserModel *creator;
@property (nonatomic, copy, readonly) AZZJiraUserModel *reporter;
@property (nonatomic, copy, readonly) NSDate *created;
@property (nonatomic, copy, readonly) NSDate *updated;
@property (nonatomic, copy, readonly) NSString *modelDescription;
@property (nonatomic, copy, readonly) AZZJiraIssuePriorityModel *priority;
@property (nonatomic, copy, readonly) AZZJiraIssueStatusModel *status;
@property (nonatomic, copy, readonly) AZZJiraUserModel *assignee;
@property (nonatomic, copy, readonly) NSArray<AZZJiraIssueAttachment *> *attachment;
@property (nonatomic, copy, readonly) AZZJiraProjectsModel *project;
@property (nonatomic, copy, readonly) NSArray<AZZJiraIssueVersionModel *> *versions;
@property (nonatomic, copy, readonly) NSDate *lastViewed;
@property (nonatomic, copy, readonly) NSArray<AZZJiraIssueCommentModel *> *comments;
@property (nonatomic, copy, readonly) NSString *environment;

+ (instancetype)getIssueModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraIssueModel *> *)getIssueModelsWithJSONArray:(NSArray *)array;

@end
