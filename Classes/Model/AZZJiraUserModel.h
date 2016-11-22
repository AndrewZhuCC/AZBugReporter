//
//  AZZJiraUserModel.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AZZJiraUserModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *selfUrl;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *emailAddress;
@property (nonatomic, copy, readonly) NSDictionary *avatarUrls;
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, assign, readonly) BOOL active;

+ (instancetype)getUserModelWithDictionary:(NSDictionary *)dic;

@end
