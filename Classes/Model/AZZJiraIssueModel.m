//
//  AZZJiraIssueModel.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueModel.h"

@implementation AZZJiraIssueModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"          : @"self",
             @"idNumber"         : @"id",
             @"key"              : @"key",
             @"summary"          : @"fields.summary",
             @"issueType"        : @"fields.issuetype",
             @"resolution"       : @"fields.resolution",
             @"fixVersions"      : @"fields.fixVersions",
             @"resolutiondate"   : @"fields.resolutiondate",
             @"creator"          : @"fields.creator",
             @"reporter"         : @"fields.reporter",
             @"created"          : @"fields.created",
             @"updated"          : @"fields.updated",
             @"modelDescription" : @"fields.description",
             @"priority"         : @"fields.priority",
             @"status"           : @"fields.status",
             @"assignee"         : @"fields.assignee",
             @"attachment"       : @"fields.attachment",
             @"project"          : @"fields.project",
             @"versions"         : @"fields.versions",
             @"lastViewed"       : @"fields.lastViewed",
             @"comments"         : @"fields.comment.comments",
             @"environment"      : @"fields.environment",
             };
}

+ (instancetype)getIssueModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSArray<AZZJiraIssueModel *> *)getIssueModelsWithJSONArray:(NSArray *)array {
    NSError *error;
    NSArray *result = [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:array error:&error];
    if (error) {
        NSLog(@"model error:%@", error);
    }
    return result;
}

#pragma mark - Transformers

+ (NSValueTransformer *)issueTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraIssueTypeModel class]];
}

+ (NSValueTransformer *)resolutionJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraIssueResolutionModel class]];
}

+ (NSValueTransformer *)fixVersionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AZZJiraIssueVersionModel class]];
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)reporterJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)priorityJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraIssuePriorityModel class]];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraIssueStatusModel class]];
}

+ (NSValueTransformer *)assigneeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)attachmentJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AZZJiraIssueAttachment class]];
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraProjectsModel class]];
}

+ (NSValueTransformer *)versionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AZZJiraIssueVersionModel class]];
}

+ (NSValueTransformer *)commentsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AZZJiraIssueCommentModel class]];
}

+ (NSValueTransformer *)resolutiondateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSValueTransformer *)lastViewedJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSValueTransformer *)updatedJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

@end
