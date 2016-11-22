//
//  AZZJiraProjectsModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraProjectsModel.h"

@implementation AZZJiraProjectsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"         : @"self",
             @"idNumber"        : @"id",
             @"key"             : @"key",
             @"name"            : @"name",
             @"avatarUrls"      : @"avatarUrls",
             @"projectCategory" : @"projectCategory",
             };
}

+ (instancetype)getProjectsModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraProjectsModel *> *)getProjectsModelsWithJSONArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

@end
