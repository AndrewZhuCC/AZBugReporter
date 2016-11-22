//
//  AZZJiraIssueCommentModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@class AZZJiraUserModel;

@interface AZZJiraIssueCommentModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) AZZJiraUserModel *author;
@property (nonatomic, copy, readonly) NSString *body;
@property (nonatomic, copy, readonly) AZZJiraUserModel *updateAuthor;
@property (nonatomic, copy, readonly) NSDate *created;
@property (nonatomic, copy, readonly) NSDate *updated;

+ (instancetype)getIssueCommentModelWithDictionary:(NSDictionary *)dic;

@end
