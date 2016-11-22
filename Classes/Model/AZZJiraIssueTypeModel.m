//
//  AZZJiraIssueTypeModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueTypeModel.h"

@implementation AZZJiraIssueTypeModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"          : @"self",
             @"idNumber"         : @"id",
             @"name"             : @"name",
             @"modelDescription" : @"description",
             @"iconUrl"          : @"iconUrl",
             };
}

+ (instancetype)getIssueTypeModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

@end
