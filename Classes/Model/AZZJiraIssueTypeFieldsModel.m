//
//  AZZJiraIssueTypeFieldsModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueTypeFieldsModel.h"

@implementation AZZJiraIssueTypeFieldsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"required"        : @"required",
             @"type"            : @"schema.type",
             @"items"           : @"schema.items",
             @"system"          : @"schema.system",
             @"name"            : @"name",
             @"hasDefaultValue" : @"hasDefaultValue",
             @"autoCompleteUrl" : @"autoCompleteUrl",
             @"allowedValues"   : @"allowedValues"
             };
}

+ (instancetype)getIssueTypeFieldsModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraIssueTypeFieldsModel *> *)getIssueTypeFieldsModelsWithArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

+ (NSDictionary<NSString *, AZZJiraIssueTypeFieldsModel *> *)getFieldsDictionaryWithDictionary:(NSDictionary *)dic {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in dic) {
        NSDictionary *jsonDic = dic[key];
        AZZJiraIssueTypeFieldsModel *model = [self getIssueTypeFieldsModelWithDictionary:jsonDic];
        if (model) {
            result[key] = model;
        }
    }
    return [result copy];
}

@end
