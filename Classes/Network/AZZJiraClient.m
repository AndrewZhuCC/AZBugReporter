//
//  AZZJiraClient.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/18.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraClient.h"
#import "AZZJiraConfiguration.h"

#import "AZZJiraCreateIssueInputModel.h"

@interface AZZJiraClient ()

@property (nonatomic, strong) AFJSONRequestSerializer *postSerializer;

@end

@implementation AZZJiraClient

+ (instancetype)sharedInstance {
    static AZZJiraClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:AZZJiraClientAPIBaseURL]];
        instance.requestSerializer.timeoutInterval = 60;
        [(AFJSONResponseSerializer *)instance.responseSerializer setRemovesKeysWithNullValues:YES];
        instance.postSerializer = [AFJSONRequestSerializer serializer];
    });
    return instance;
}

- (NSURLSessionDataTask *)requestWithURL:(NSString *)urlString
                                  method:(AZZRequestMethodType)method
                               parameter:(id)param
                                    body:(NSData *)body
                          uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                        downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
                                 success:(AZZJiraSuccessBlock)success
                                 failure:(AZZJiraFailBlock)failure {
    NSURLSessionDataTask *task;
    NSMutableURLRequest *request;
    
    NSError *serializationError = nil;
    switch (method) {
        case AZZRequestMethodType_Get:
        {
            request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:param error:&serializationError];
            break;
        }
        case AZZRequestMethodType_Post:
        {
            request = [self.postSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:param error:&serializationError];
            break;
        }
    }
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializationError);
            });
        }
        
        return nil;
    }
    
    if (body) {
        request.HTTPBody = body;
    }
    
    task = [self dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure((NSHTTPURLResponse *)response, responseObject, error);
                });
            }
        } else {
            if (success) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    success((NSHTTPURLResponse *)response, responseObject);
                });
            }
        }
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)requestLoginWithUserName:(NSString *)userName
                                          password:(NSString *)password
                                           success:(AZZJiraSuccessBlock)success
                                           failure:(AZZJiraFailBlock)failure {
    NSDictionary *param = @{@"username" : userName,
                            @"password" : password};
    NSError *serializerError = nil;
    NSURLRequest *request = [self.postSerializer requestWithMethod:@"POST" URLString:AZZJiraClientLoginURL parameters:param error:&serializerError];
    
    if (serializerError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializerError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure((NSHTTPURLResponse *)response, responseObject, error);
                });
            }
        } else {
            if (success) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    success((NSHTTPURLResponse *)response, responseObject);
                });
            }
        }
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)requestProjectsListSuccess:(AZZJiraSuccessBlock)success
                                                fail:(AZZJiraFailBlock)fail {
    return [self requestWithURL:@"project" method:AZZRequestMethodType_Get parameter:nil
                           body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestIssueListByProjectKey:(NSString *)key
                                               success:(AZZJiraSuccessBlock)success
                                                  fail:(AZZJiraFailBlock)fail {
    NSDictionary *parameter = @{@"jql" : [NSString stringWithFormat:@"project = %@ AND status in (产品需求阶段, 开发中, Reopened)", key]};
    return [self requestWithURL:@"search" method:AZZRequestMethodType_Get parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestCreateIssueMetaByProjectKey:(NSString *)key
                                                     success:(AZZJiraSuccessBlock)success
                                                        fail:(AZZJiraFailBlock)fail {
    NSDictionary *parameter = @{@"projectKeys" : key};
    return [self requestWithURL:@"issue/createmeta" method:AZZRequestMethodType_Get parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestCreateIssueFieldsWithProjectKey:(NSString *)key
                                                     issueTypeId:(NSString *)issueTypeId
                                                         success:(AZZJiraSuccessBlock)success
                                                            fail:(AZZJiraFailBlock)fail {
    NSDictionary *parameter = @{@"projectKeys"  : key,
                                @"issuetypeIds" : issueTypeId,
                                @"expand"       : @"projects.issuetypes.fields"};
    return [self requestWithURL:@"issue/createmeta" method:AZZRequestMethodType_Get parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestAssignableUsersWithProject:(NSString *)project
                                                   userName:(NSString *)userName
                                                    success:(AZZJiraSuccessBlock)success
                                                       fail:(AZZJiraFailBlock)fail {
    NSDictionary *parameter = @{@"project"  : project,
                                @"username" : userName};
    return [self requestWithURL:@"user/assignable/search" method:AZZRequestMethodType_Get parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestJSONOfMyselfSuccess:(AZZJiraSuccessBlock)success
                                                fail:(AZZJiraFailBlock)fail {
    return [self requestWithURL:@"myself" method:AZZRequestMethodType_Get parameter:nil body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestLabelsWithQuery:(NSString *)queryString
                                        Susscess:(AZZJiraSuccessBlock)success
                                            fail:(AZZJiraFailBlock)failure {
    if (!queryString) {
        queryString = @"";
    }
    NSDictionary *parameter = @{@"query" : queryString};
    NSError *serializerError = nil;
    NSURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:AZZJiraClientQueryLabels parameters:parameter error:&serializerError];
    
    if (serializerError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializerError);
            });
        }
        
        return nil;
    }
    
    AFXMLParserResponseSerializer *xmlSerializer = [AFXMLParserResponseSerializer serializer];
    AFHTTPResponseSerializer *origSerializer = self.responseSerializer;
    self.responseSerializer = xmlSerializer;
    __weak typeof(self) wself = self;
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure((NSHTTPURLResponse *)response, responseObject, error);
                });
            }
        } else {
            if (success) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    success((NSHTTPURLResponse *)response, responseObject);
                });
            }
        }
        wself.responseSerializer = origSerializer;
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)requestCreateIssueWith:(AZZJiraCreateIssueInputModel *)model
                                         success:(AZZJiraSuccessBlock)success
                                            fail:(AZZJiraFailBlock)failure {
    NSDictionary *parameters = [model getJSONModel];
    NSError *serializerError = nil;
    NSURLRequest *request = [self.postSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:@"issue" relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializerError];
    
    if (serializerError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializerError);
            });
        }
        
        return nil;
    }
    
    NSLog(@"create issue json:%@", parameters);
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure((NSHTTPURLResponse *)response, responseObject, error);
                });
            }
        } else {
            if (success) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    success((NSHTTPURLResponse *)response, responseObject);
                });
            }
        }
    }];
    
    [task resume];
    return task;
}

@end
