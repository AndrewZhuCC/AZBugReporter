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
@property (nonatomic, assign) BOOL viewable;
@property (nonatomic, assign) AZZJiraPreviewFileType previewType;
@property (nonatomic, strong) NSError *subpathsError;

@end

@implementation AZZJiraFileNode

+ (instancetype)fileNodeWithRootFilePath:(NSString *)rootPath {
    AZZJiraFileNode *fileNode = [[AZZJiraFileNode alloc] init];
    fileNode.filePath = [NSURL fileURLWithPath:rootPath];
    NSArray *textPathExtensions = @[@"log", @"crash", @"txt"];
    NSArray *imagePathExtensions = @[@"png", @"jpeg", @"jpg"];
    if ([textPathExtensions containsObject:fileNode.filePath.pathExtension]) {
        fileNode.viewable = YES;
        fileNode.previewType = AZZJiraPreviewType_Text;
    } else if ([imagePathExtensions containsObject:fileNode.filePath.pathExtension]) {
        fileNode.viewable = YES;
        fileNode.previewType = AZZJiraPreviewType_Image;
    } else if ([fileNode.filePath.pathExtension isEqualToString:@"plist"]) {
        fileNode.viewable = YES;
        fileNode.previewType = AZZJiraPreviewType_Plist;
    } else {
        fileNode.viewable = NO;
        fileNode.previewType = AZZJiraPreviewType_None;
    }
    
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

+ (instancetype)fileNodeWithURL:(NSURL *)fileUrl {
    AZZJiraFileNode *fileNode = [[AZZJiraFileNode alloc] init];
    fileNode.filePath = fileUrl;
    
    NSArray *textPathExtensions = @[@"log", @"crash", @"txt"];
    NSArray *imagePathExtensions = @[@"png", @"jpeg", @"jpg"];
    if ([textPathExtensions containsObject:fileNode.filePath.pathExtension]) {
        fileNode.viewable = YES;
        fileNode.previewType = AZZJiraPreviewType_Text;
    } else if ([imagePathExtensions containsObject:fileNode.filePath.pathExtension]) {
        fileNode.viewable = YES;
        fileNode.previewType = AZZJiraPreviewType_Image;
    } else {
        fileNode.viewable = NO;
        fileNode.previewType = AZZJiraPreviewType_None;
    }
    
    fileNode.isDirectory = NO;
    return fileNode;
}

- (NSArray<AZZJiraFileNode *> *)subpaths {
    if (!_subpaths) {
        if (self.isDirectory) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSMutableArray *tempArray = [NSMutableArray array];
            NSError *error = nil;
            NSString *rootPath = [self.filePath path];
            NSArray *subPaths = [fileManager contentsOfDirectoryAtURL:self.filePath includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles error:&error];
            if (!error) {
                for (NSURL *subpath in subPaths) {
                    AZZJiraFileNode *subNode = [AZZJiraFileNode fileNodeWithRootFilePath:subpath.path];
                    [tempArray addObject:subNode];
                }
                _subpaths = [tempArray copy];
            } else {
                self.subpathsError = error;
                NSLog(@"create node at path: %@ error:%@", rootPath, error);
                return nil;
            }
        } else {
            return nil;
        }
    }
    return _subpaths;
}

- (NSString *)fileName {
    return [self.filePath lastPathComponent];
}

@end
