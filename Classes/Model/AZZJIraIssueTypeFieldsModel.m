//
//  AZZJIraIssueTypeFieldsModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJIraIssueTypeFieldsModel.h"

@implementation AZZJIraIssueTypeFieldsModel

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

+ (NSArray<AZZJIraIssueTypeFieldsModel *> *)getIssueTypeFieldsModelsWithArray:(NSArray *)array {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:nil];
}

@end
