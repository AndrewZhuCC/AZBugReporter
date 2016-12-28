//
//  AZZJiraIssueAttachment.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueAttachment.h"
#import "AZZJiraUserModel.h"

@implementation AZZJiraIssueAttachment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"selfUrl"   : @"self",
             @"idNumber"  : @"id",
             @"filename"  : @"filename",
             @"author"    : @"author",
             @"created"   : @"created",
             @"size"      : @"size",
             @"mimetype"  : @"mimeType",
             @"content"   : @"content",
             @"thumbnail" : @"thumbnail"
             };
}

+ (instancetype)getIssueAttachmentModelWithDictionary:(NSDictionary *)dic {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dic error:nil];
}

+ (NSValueTransformer *)authorJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[AZZJiraUserModel class]];
}

+ (NSValueTransformer *)createdJSONTransformer {
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

@end
