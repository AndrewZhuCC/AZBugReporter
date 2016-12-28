//
//  AZZJiraCreateIssueInputModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraCreateIssueInputModel.h"
#import "MTLJSONAdapterWithoutNil.h"

@implementation AZZJiraCreateIssueInputModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"update"           : @"update",
             @"project"          : @"fields.project",
             @"summary"          : @"fields.summary",
             @"issuetype"        : @"fields.issuetype",
             @"assignee"         : @"fields.assignee",
             @"reporter"         : @"fields.reporter",
             @"priority"         : @"fields.priority",
             @"labels"           : @"fields.labels",
             @"versions"         : @"fields.versions",
             @"environment"      : @"fields.environment",
             @"modelDescription" : @"fields.description",
             @"fixVersions"      : @"fields.fixVersions",
             @"components"       : @"fields.components",
             @"attachment"        : @"fields.attachment",
             @"duedate"          : @"fields.duedate"
             };
}

- (NSDictionary *)getJSONModel {
    NSError *error;
    NSDictionary *result = [MTLJSONAdapterWithoutNil JSONDictionaryFromModel:self error:&error];
    if (error) {
        NSLog(@"input model getJSONModel error:%@", error);
    }
    return result;
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[AZZJiraProjectsModel class]];
}

+ (NSValueTransformer *)issuetypeJSONTransformer {
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[AZZJiraIssueTypeModel class]];
}

+ (NSValueTransformer *)assigneeJSONTransformer {
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)reporterJSONTransformer {
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)priorityJSONTransformer {
    return [MTLJSONAdapterWithoutNil dictionaryTransformerWithModelClass:[AZZJiraIssuePriorityModel class]];
}

+ (NSValueTransformer *)versionsJSONTransformer {
    return [MTLJSONAdapterWithoutNil arrayTransformerWithModelClass:[AZZJiraIssueVersionModel class]];
}

+ (NSValueTransformer *)fixVersionsJSONTransformer {
    return [MTLJSONAdapterWithoutNil arrayTransformerWithModelClass:[AZZJiraIssueVersionModel class]];
}

+ (NSValueTransformer *)componentsJSONTransformer {
    return [MTLJSONAdapterWithoutNil arrayTransformerWithModelClass:[AZZJiraComponentModel class]];
}

+ (NSValueTransformer *)attachmentJSONTransformer {
    return [MTLJSONAdapterWithoutNil arrayTransformerWithModelClass:[AZZJiraIssueAttachment class]];
}

+ (NSValueTransformer *)duedateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return dateFormatter;
}

- (id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        return self.modelDescription;
    } else {
        return [super valueForKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.modelDescription = value;
    } else {
        [super setValue:value forKey:key];
    }
}

@end
