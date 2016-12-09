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
typedef void(^AZZJiraProgressBlock)(NSProgress *progress);

@class AZZJiraCreateIssueInputModel, PHAsset;

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

- (NSURLSessionDataTask *)requestAssignableUsersWithProject:(NSString *)project
                                                   userName:(NSString *)userName
                                                    success:(AZZJiraSuccessBlock)success
                                                       fail:(AZZJiraFailBlock)fail;

- (NSURLSessionDataTask *)requestJSONOfMyselfSuccess:(AZZJiraSuccessBlock)success
                                                fail:(AZZJiraFailBlock)fail;

- (NSURLSessionDataTask *)requestLabelsWithQuery:(NSString *)queryString
                                        Susscess:(AZZJiraSuccessBlock)success
                                            fail:(AZZJiraFailBlock)failure;

- (NSURLSessionDataTask *)requestCreateIssueWith:(AZZJiraCreateIssueInputModel *)model
                                         success:(AZZJiraSuccessBlock)success
                                            fail:(AZZJiraFailBlock)failure;

- (NSURLSessionDataTask *)uploadImagesWithIssueID:(NSString *)issueID
                                           images:(NSArray<NSURL *> *)images
                                           assets:(NSArray<PHAsset *> *)assets
                                   uploadProgress:(AZZJiraProgressBlock)uploadProgressBlock
                                          success:(AZZJiraSuccessBlock)success
                                             fail:(AZZJiraFailBlock)failure;

@end
