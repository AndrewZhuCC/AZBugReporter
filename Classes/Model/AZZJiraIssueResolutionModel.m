//
//  AZZJiraIssueResolutionModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueResolutionModel.h"

@implementation AZZJiraIssueResolutionModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"          : @"self",
             @"idNumber"         : @"id",
             @"modelDescription" : @"modelDescription",
             @"name"             : @"name",
             };
}

+ (instancetype)getIssueResolutionModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

@end
