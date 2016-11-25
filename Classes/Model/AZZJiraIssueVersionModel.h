//
//  AZZJiraIssueVersionModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraIssueVersionModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *modelDescription;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL archived;
@property (nonatomic, assign, readonly) BOOL released;

+ (instancetype)getIssueVersionModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraIssueVersionModel *> *)getVersionModelsFromArray:(NSArray *)array;

@end
