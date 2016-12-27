//
//  AZZJiraFileNode.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/6.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AZZJiraPreviewFileType) {
    AZZJiraPreviewType_None,
    AZZJiraPreviewType_Text,
    AZZJiraPreviewType_Image,
};

@interface AZZJiraFileNode : NSObject

@property (nonatomic, copy, readonly) NSURL *filePath;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, copy, readonly) NSArray<AZZJiraFileNode *> *subpaths;
@property (nonatomic, copy, readonly) NSString *fileName;

@property (nonatomic, assign, readonly) BOOL viewable;
@property (nonatomic, assign, readonly) AZZJiraPreviewFileType previewType;

+ (instancetype)fileNodeWithRootFilePath:(NSString *)rootPath;
+ (instancetype)fileNodeWithURL:(NSURL *)fileUrl;

@end
