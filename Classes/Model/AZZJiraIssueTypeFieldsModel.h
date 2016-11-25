//
//  AZZJiraIssueTypeFieldsModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraIssueTypeFieldsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign, readonly) BOOL required;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *items;
@property (nonatomic, copy, readonly) NSString *system;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL hasDefaultValue;
@property (nonatomic, copy, readonly) NSArray<NSDictionary *> *allowedValues;
@property (nonatomic, copy, readonly) NSString *autoCompleteUrl;

+ (instancetype)getIssueTypeFieldsModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraIssueTypeFieldsModel *> *)getIssueTypeFieldsModelsWithArray:(NSArray *)array;
+ (NSDictionary<NSString *, AZZJiraIssueTypeFieldsModel *> *)getFieldsDictionaryWithDictionary:(NSDictionary *)dic;

@end
