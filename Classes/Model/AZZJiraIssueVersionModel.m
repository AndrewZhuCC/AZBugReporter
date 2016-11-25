//
//  AZZJiraIssueVersionModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueVersionModel.h"

@implementation AZZJiraIssueVersionModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"          : @"self",
             @"idNumber"         : @"id",
             @"modelDescription" : @"modelDescription",
             @"name"             : @"name",
             @"archived"         : @"archived",
             @"released"         : @"released",
             };
}

+ (instancetype)getIssueVersionModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraIssueVersionModel *> *)getVersionModelsFromArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

@end
