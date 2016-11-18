//
//  AZZJiraClient.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, AZZRequestMethodType) {
    AZZRequestMethodType_Get = 0,
    AZZRequestMethodType_Post = 1,
};

@interface AZZJiraClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)requestLoginWithUserName:(NSString *)userName
                                          password:(NSString *)password
                                           success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                                           failure:(void (^)(NSHTTPURLResponse *response, id responseObject, NSError *error))failure;

@end
