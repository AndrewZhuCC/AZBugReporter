//
//  AZZJiraComponentModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraComponentModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *idNumber;
@property (nonatomic, copy, readonly) NSString *name;

+ (instancetype)getComponentModelWithDictionary:(NSDictionary *)dic;
+ (NSArray<AZZJiraComponentModel *> *)getComponentModelsWithArray:(NSArray *)array;

@end
