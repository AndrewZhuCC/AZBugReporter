//
//  AZZJiraUserModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraUserModel.h"

@implementation AZZJiraUserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"         : @"self",
             @"name"            : @"name",
             @"emailAddress"    : @"emailAddress",
             @"avatarUrls"      : @"avatarUrls",
             @"displayName"     : @"displayName",
             @"active"          : @"active",
             };
}

+ (instancetype)getUserModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

@end
