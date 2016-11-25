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

typedef void(^AZZJiraSuccessBlock)(NSHTTPURLResponse *response, id responseObject);
typedef void(^AZZJiraFailBlock)(NSHTTPURLResponse *response, id responseObject, NSError *error);

@interface AZZJiraClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)requestLoginWithUserName:(NSString *)userName
                                          password:(NSString *)password
                                           success:(AZZJiraSuccessBlock)success
                                           failure:(AZZJiraFailBlock)failure;

- (NSURLSessionDataTask *)requestProjectsListSuccess:(AZZJiraSuccessBlock)success
                                                fail:(AZZJiraFailBlock)fail;

- (NSURLSessionDataTask *)requestIssueListByProjectKey:(NSString *)key
                                               success:(AZZJiraSuccessBlock)success
                                                  fail:(AZZJiraFailBlock)fail;

- (NSURLSessionDataTask *)requestCreateIssueMetaByProjectKey:(NSString *)key
                                                     success:(AZZJiraSuccessBlock)success
                                                        fail:(AZZJiraFailBlock)fail;

- (NSURLSessionDataTask *)requestCreateIssueFieldsWithProjectKey:(NSString *)key
                                                     issueTypeId:(NSString *)issueTypeId
                                                         success:(AZZJiraSuccessBlock)success
                                                            fail:(AZZJiraFailBlock)fail;

@end
