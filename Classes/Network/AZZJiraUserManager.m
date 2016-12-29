//
//  AZZJiraUserManager.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/29.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraUserManager.h"

#import "AZZJiraConfiguration.h"
#import <CommonCrypto/CommonDigest.h>

#import <SAMKeychain/SAMKeychain.h>

@interface AZZJiraUserManager ()

@property (nonatomic, strong) NSArray *allUserNames;

@end

@implementation AZZJiraUserManager

+ (AZZJiraUserManager *)sharedInstance {
    static AZZJiraUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AZZJiraUserManager alloc] init];
    });
    return instance;
}

- (NSArray<NSString *> *)allUserNames {
    if (!_allUserNames) {
        NSArray *accounts = [SAMKeychain accountsForService:AZZJiraKeyChainService];
        NSMutableArray *results = [NSMutableArray array];
        if (accounts.count > 0) {
            for (NSDictionary *accountDic in accounts) {
                NSString *account = [accountDic objectForKey:@"acct"];
                [results addObject:account];
            };
        }
        _allUserNames = [results copy];
    }
    return _allUserNames;
}

+ (NSArray *)allUserNames {
    return [[self sharedInstance] allUserNames];
}

+ (void)setPassword:(NSString *)password forUserName:(NSString *)account {
    [SAMKeychain setPassword:password forService:AZZJiraKeyChainService account:account];
    [self sharedInstance].allUserNames = nil;
}

+ (NSString *)passwordForUserName:(NSString *)account {
    return [SAMKeychain passwordForService:AZZJiraKeyChainService account:account];
}

+ (void)setLastLoginUserName:(NSString *)account {
    NSString *md5UserName = [self md5:account];
    [[NSUserDefaults standardUserDefaults] setObject:md5UserName forKey:AZZJiraSettingsLastLoginUser];
}

+ (NSString *)lastLoginUserName {
    NSString *md5UserName = [[NSUserDefaults standardUserDefaults] stringForKey:AZZJiraSettingsLastLoginUser];
    if (md5UserName) {
        for (NSString *userName in self.allUserNames) {
            if ([md5UserName isEqualToString:[self md5:userName]]) {
                return userName;
            }
        }
    }
    return nil;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
