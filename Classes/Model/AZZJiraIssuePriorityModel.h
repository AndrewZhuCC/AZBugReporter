//
//  AZZJiraIssuePriorityModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraIssuePriorityModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSURL *iconUrl;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *idNumber;

+ (instancetype)getIssuePriorityModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraIssuePriorityModel *> *)getIssuePriorityModelsWithArray:(NSArray *)array;

@end
