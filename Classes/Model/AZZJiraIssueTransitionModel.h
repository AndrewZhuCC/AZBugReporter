//
//  AZZJiraIssueTransitionModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "AZZJiraIssueStatusModel.h"
#import "AZZJiraIssueTypeFieldsModel.h"

@interface AZZJiraIssueTransitionModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) AZZJiraIssueStatusModel *to;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, AZZJiraIssueTypeFieldsModel *> *fields;

+ (instancetype)getTransitionModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraIssueTransitionModel *> *)getTransitionModelsWithJSONArray:(NSArray *)array;

@end
