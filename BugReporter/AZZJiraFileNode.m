//
//  AZZJiraFileNode.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/6.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraFileNode.h"

@interface AZZJiraFileNode ()

@property (nonatomic, copy) NSURL *filePath;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, copy) NSArray<AZZJiraFileNode *> *subpaths;

@end

@implementation AZZJiraFileNode

+ (instancetype)fileNodeWithRootFilePath:(NSString *)rootPath {
    AZZJiraFileNode *fileNode = [[AZZJiraFileNode alloc] init];
    fileNode.filePath = [NSURL fileURLWithPath:rootPath];
    
    if (![fileNode.filePath isFileURL]) {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL directory = NO;
    if (![fileManager fileExistsAtPath:rootPath isDirectory:&directory]) {
        return nil;
    }
    fileNode.isDirectory = directory;
    return fileNode;
}

- (NSArray<AZZJiraFileNode *> *)subpaths {
    if (!_subpaths) {
        if (self.isDirectory) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSMutableArray *tempArray = [NSMutableArray array];
            NSError *error = nil;
            NSString *rootPath = [self.filePath absoluteString];
            NSArray *subPaths = [fileManager subpathsOfDirectoryAtPath:rootPath error:&error];
            if (!error) {
                for (NSString *subpath in subPaths) {
                    AZZJiraFileNode *subNode = [AZZJiraFileNode fileNodeWithRootFilePath:[[NSURL fileURLWithPath:subpath relativeToURL:self.filePath] absoluteString]];
                    [tempArray addObject:subNode];
                }
                _subpaths = [tempArray copy];
            } else {
                NSLog(@"create node at path: %@ error:%@", rootPath, error);
                return nil;
            }
        } else {
            return nil;
        }
    }
    return _subpaths;
}

@end
