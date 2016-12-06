//
//  AZZJiraFileNode.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/6.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZZJiraFileNode : NSObject

@property (nonatomic, copy, readonly) NSURL *filePath;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, copy, readonly) NSArray<AZZJiraFileNode *> *subpaths;

+ (instancetype)fileNodeWithRootFilePath:(NSString *)rootPath;

@end
