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
#import <Photos/Photos.h>

@interface AZZJiraClient ()

@property (nonatomic, strong) AFJSONRequestSerializer *postSerializer;

@property (nonatomic, strong) AZZJiraUserModel *selfModel;

@end

@implementation AZZJiraClient

+ (instancetype)sharedInstance {
    static AZZJiraClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:AZZJiraClientAPIBaseURL]];
        instance.requestSerializer.timeoutInterval = 15;
        [(AFJSONResponseSerializer *)instance.responseSerializer setRemovesKeysWithNullValues:YES];
        instance.postSerializer = [AFJSONRequestSerializer serializer];
        instance.postSerializer.timeoutInterval = 15;
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
        case AZZRequestMethodType_Put:
        {
            request = [self.postSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:param error:&serializationError];
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
            [self requestJSONOfMyselfSuccess:^(NSHTTPURLResponse *response, id responseObject) {
                self.selfModel = [AZZJiraUserModel getUserModelWithDictionary:responseObject];
            } fail:nil];
        }
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)requestLogoutSuccess:(AZZJiraSuccessBlock)success
                                       failure:(AZZJiraFailBlock)failure {
    NSError *serializerError = nil;
    NSURLRequest *request = [self.postSerializer requestWithMethod:@"DELETE" URLString:AZZJiraClientLoginURL parameters:nil error:&serializerError];
    
    if (serializerError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializerError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 204) {
            if (success) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    success((NSHTTPURLResponse *)response, responseObject);
                });
            }
            self.selfModel = nil;
        } else {
            if (failure) {
                dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure((NSHTTPURLResponse *)response, responseObject, error);
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
                                            searchText:(NSString *)searchText
                                                 start:(NSUInteger)start
                                             maxResult:(NSUInteger)maxResult
                                               success:(AZZJiraSuccessBlock)success
                                                  fail:(AZZJiraFailBlock)fail {
    NSMutableDictionary *tempParameter = [NSMutableDictionary dictionary];
    if (searchText.length > 0) {
        [tempParameter setObject:[NSString stringWithFormat:@"project = %@ AND text ~ %@", key, searchText] forKey:@"jql"];
    } else {
        [tempParameter setObject:[NSString stringWithFormat:@"project = %@ AND resolution = Unresolved", key] forKey:@"jql"];
    }
    NSDictionary *parameter = [tempParameter copy];
    return [self requestWithURL:@"search" method:AZZRequestMethodType_Get parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
}

- (NSURLSessionDataTask *)requestIssueByIssueKey:(NSString *)key
                                         success:(AZZJiraSuccessBlock)success
                                            fail:(AZZJiraFailBlock)fail {
    return [self requestWithURL:[NSString stringWithFormat:@"issue/%@", key] method:AZZRequestMethodType_Get parameter:nil body:nil uploadProgress:nil downloadProgress:nil success:success failure:fail];
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
                                                   issueKey:(NSString *)issueKey
                                                    success:(AZZJiraSuccessBlock)success
                                                       fail:(AZZJiraFailBlock)fail {
    NSMutableDictionary *tempParameter = [NSMutableDictionary dictionary];
    if (project) {
        [tempParameter setObject:project forKey:@"project"];
    }
    if (userName) {
        [tempParameter setObject:userName forKey:@"username"];
    }
    if (issueKey) {
        [tempParameter setObject:issueKey forKey:@"issueKey"];
    }
    NSDictionary *parameter = [tempParameter copy];
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

- (NSURLSessionDataTask *)uploadImagesWithIssueID:(NSString *)issueID
                                           images:(NSArray<NSURL *> *)images
                                           assets:(NSArray<PHAsset *> *)assets
                                   uploadProgress:(AZZJiraProgressBlock)uploadProgressBlock
                                          success:(AZZJiraSuccessBlock)success
                                             fail:(AZZJiraFailBlock)failure {
    NSError *serializerError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:[NSString stringWithFormat:@"issue/%@/attachments", issueID] relativeToURL:self.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSURL *fileURL in images) {
            [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
        }
        if (assets) {
            [self appendAssets:assets to:formData];
        }
    } error:&serializerError];
    [request setValue:@"no-check" forHTTPHeaderField:@"X-Atlassian-Token"];
    
    if (serializerError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializerError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *dataTask = [self uploadTaskWithStreamedRequest:request progress:^(NSProgress *inProgress) {
        if (uploadProgressBlock) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                uploadProgressBlock(inProgress);
            });
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
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
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)requestAssignIssue:(NSString *)issueIDOrKey
                                    userName:(NSString *)userName
                                     success:(AZZJiraSuccessBlock)success
                                        fail:(AZZJiraFailBlock)failure {
    NSDictionary *parameters = nil;
    if (userName) {
        parameters = @{@"name" : userName};
    } else {
        parameters = @{@"name" : self.selfModel.name};
    }
    return [self requestWithURL:[NSString stringWithFormat:@"issue/%@/assignee", issueIDOrKey] method:AZZRequestMethodType_Put parameter:parameters body:nil uploadProgress:nil downloadProgress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)requestGetTransitionsByIssueIdOrKey:(NSString *)idOrKey
                                                      success:(AZZJiraSuccessBlock)success
                                                         fail:(AZZJiraFailBlock)failure {
    NSString *url = [NSString stringWithFormat:@"issue/%@/transitions", idOrKey];
    NSDictionary *parameters = @{@"expand" : @"transitions.fields"};
    return [self requestWithURL:url method:AZZRequestMethodType_Get parameter:parameters body:nil uploadProgress:nil downloadProgress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)requestDoTransitionWithIssueIdOrKey:(NSString *)issueId
                                                 transitionId:(NSString *)transitionId
                                                 resolutionId:(NSString *)resolutionId
                                                  commentBody:(NSString *)commentBody
                                                      success:(AZZJiraSuccessBlock)success
                                                         fail:(AZZJiraFailBlock)failure {
    NSDictionary *parameter = nil;
    if (resolutionId) {
        if (commentBody.length > 0) {
            parameter = @{
                          @"update" : @{
                                  @"comment" : @[
                                          @{
                                              @"add" : @{
                                                      @"body" : commentBody,
                                                      },
                                              }
                                          ],
                                  @"resolution" : @[
                                          @{
                                              @"set" : @{
                                                      @"id" : resolutionId,
                                                      },
                                              },
                                          ],
                                  },
                          @"transition" : transitionId,
                          };
        } else {
            parameter = @{
                          @"update" : @{
                                  @"resolution" : @[
                                          @{
                                              @"set" : @{
                                                      @"id" : resolutionId,
                                                      },
                                              },
                                          ],
                                  },
                          @"transition" : transitionId,
                          };
        }
    } else {
        parameter = @{
                      @"transition" : transitionId,
                      };
    }
    NSString *url = [NSString stringWithFormat:@"issue/%@/transitions", issueId];
    return [self requestWithURL:url method:AZZRequestMethodType_Post parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)requestAddCommentWithIssueIdOrKey:(NSString *)issueId
                                                commentBody:(NSString *)commentBody
                                                    success:(AZZJiraSuccessBlock)success
                                                       fail:(AZZJiraFailBlock)failure {
    NSDictionary *parameter = @{@"body" : commentBody};
    NSString *url = [NSString stringWithFormat:@"issue/%@/comment", issueId];
    return [self requestWithURL:url method:AZZRequestMethodType_Post parameter:parameter body:nil uploadProgress:nil downloadProgress:nil success:success failure:failure];
}

- (void)appendAssets:(NSArray<PHAsset *> *)assets to:(id<AFMultipartFormData>)formData {
    for (PHAsset *asset in assets) {
        UIImage *image = [self getImageFromAsset:asset];
        if (image) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:[self fileNameStringFromDate:asset.creationDate] mimeType:@"image/png"];
        }
    }
}

- (UIImage *)getImageFromAsset:(PHAsset *)asset {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    
    __block UIImage *myResult = nil;
    [imageManager requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        myResult = result;
    }];
    return myResult;
}

- (NSString *)fileNameStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
    return [[formatter stringFromDate:date] stringByAppendingPathExtension:@"png"];
}

@end
