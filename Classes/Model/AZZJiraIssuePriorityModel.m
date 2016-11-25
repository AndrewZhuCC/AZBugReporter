//
//  AZZJiraIssuePriorityModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssuePriorityModel.h"

@implementation AZZJiraIssuePriorityModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"         : @"self",
             @"iconUrl"         : @"iconUrl",
             @"name"            : @"name",
             @"idNumber"        : @"id",
             };
}

+ (instancetype)getIssuePriorityModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraIssuePriorityModel *> *)getIssuePriorityModelsWithArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

@end
