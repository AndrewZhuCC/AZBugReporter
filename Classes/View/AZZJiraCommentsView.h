//
//  AZZJiraCommentsView.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueCommentModel;

@interface AZZJiraCommentsView : UIView

@property (nonatomic, copy) NSArray<AZZJiraIssueCommentModel *> *commentModels;
+ (instancetype)commentsViewWithModels:(NSArray<AZZJiraIssueCommentModel *> *)models;

@end
