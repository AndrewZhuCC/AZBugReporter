//
//  AZZJiraIssueAttachment.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@class AZZJiraUserModel;

@interface AZZJiraIssueAttachment : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, copy, readonly) AZZJiraUserModel *author;
@property (nonatomic, copy, readonly) NSDate *created;
@property (nonatomic, assign, readonly) NSUInteger size;
@property (nonatomic, copy, readonly) NSString *mimetype;
@property (nonatomic, copy, readonly) NSURL *content;
@property (nonatomic, copy, readonly) NSURL *thumbnail;

+ (instancetype)getIssueAttachmentModelWithDictionary:(NSDictionary *)dic;

@end
