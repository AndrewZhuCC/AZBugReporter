//
//  AZZJiraComponentModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraComponentModel.h"

@implementation AZZJiraComponentModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"      : @"self",
             @"idNumber"     : @"id",
             @"name"         : @"name",
             };
}

+ (instancetype)getComponentModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraComponentModel *> *)getComponentModelsWithArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

@end
