//
//  AZZJiraUserManager.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/29.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZZJiraUserManager : NSObject

@property (nonatomic, strong, readonly) NSArray *allUserNames;

+ (AZZJiraUserManager *)sharedInstance;

+ (NSArray *)allUserNames;

+ (void)setPassword:(NSString *)password forUserName:(NSString *)account;
+ (NSString *)passwordForUserName:(NSString *)account;

+ (void)setLastLoginUserName:(NSString *)account;
+ (NSString *)lastLoginUserName;

@end
