//
//  AZZJiraIssueStatusModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueStatusModel.h"

@implementation AZZJiraIssueStatusModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"          : @"self",
             @"modelDescription" : @"modelDescription",
             @"iconUrl"          : @"iconUrl",
             @"name"             : @"name",
             @"idNumber"         : @"id",
             };
}

+ (instancetype)getIssueStatusModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

@end
