//
//  AZZJiraIssueStatusModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraIssueStatusModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *modelDescription;
@property (nonatomic, copy, readonly) NSURL *iconUrl;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *idNumber;

+ (instancetype)getIssueStatusModelWithDictionary:(NSDictionary *)dic;

@end
