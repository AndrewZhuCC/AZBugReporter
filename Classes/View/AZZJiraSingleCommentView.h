//
//  AZZJiraSingleCommentView.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraIssueCommentModel;

@interface AZZJiraSingleCommentView : UIView

@property (nonatomic, strong) AZZJiraIssueCommentModel *model;

+ (instancetype)commentViewWithModel:(AZZJiraIssueCommentModel *)model;

@end
