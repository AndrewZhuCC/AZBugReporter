//
//  AZZJiraProjectsModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraProjectsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDictionary *avatarUrls;
@property (nonatomic, copy, readonly) NSDictionary *projectCategory;

+ (instancetype)getProjectsModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraProjectsModel *> *)getProjectsModelsWithJSONArray:(NSArray *)array;

@end
