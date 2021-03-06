//
//  AZZJiraIssueTransitionModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueTransitionModel.h"

@implementation AZZJiraIssueTransitionModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"idNumber"    : @"id",
             @"name"        : @"name",
             @"to"          : @"to",
             @"fields"      : @"fields",
             };
}

+ (instancetype)getTransitionModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraIssueTransitionModel *> *)getTransitionModelsWithJSONArray:(NSArray *)array {
    NSError *error;
    NSArray *result = [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:&error];
    if (error) {
        NSLog(@"model error:%@", error);
    }
    return result;
}

#pragma mark - Transformers

+ (NSValueTransformer *)toJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraIssueStatusModel class]];
}

+ (NSValueTransformer *)fieldsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        return [AZZJiraIssueTypeFieldsModel getFieldsDictionaryWithDictionary:value];
    } reverseBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableDictionary *tempResult = [value mutableCopy];
        for (NSString *key in value) {
            AZZJiraIssueTypeFieldsModel *model = value[key];
            NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:model error:nil];
            [tempResult setObject:dic forKey:key];
        }
        return [tempResult copy];
    }];
}

@end
