//
//  AZZJiraCommentsView.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraCommentsView.h"
#import "AZZJiraSingleCommentView.h"

#import "AZZJiraIssueCommentModel.h"

#import <Masonry/Masonry.h>

@interface AZZJiraCommentsView ()

@property (nonatomic, strong) NSMutableArray<UIView *> *commentViews;

@end

@implementation AZZJiraCommentsView

+ (instancetype)commentsViewWithModels:(NSArray<AZZJiraIssueCommentModel *> *)models {
    AZZJiraCommentsView *instance = [AZZJiraCommentsView new];
    instance.commentModels = models;
    return instance;
}

- (void)setCommentModels:(NSArray<AZZJiraIssueCommentModel *> *)commentModels {
    _commentModels = [commentModels copy];
    for (UIView *view in self.commentViews) {
        [view removeFromSuperview];
    }
    [self.commentViews removeAllObjects];
    if (_commentModels.count > 0) {
        UILabel *label = [UILabel new];
        label.text = @"备注:";
        [self addSubview:label];
        [self.commentViews addObject:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(self).with.offset(5.f);
            make.right.equalTo(self).with.offset(-5.f);
            make.height.mas_equalTo(40);
        }];
        for (AZZJiraIssueCommentModel *model in _commentModels) {
            AZZJiraSingleCommentView *commentView = [AZZJiraSingleCommentView commentViewWithModel:model];
            UIView *topView = [self.commentViews lastObject];
            [self addSubview:commentView];
            [self.commentViews addObject:commentView];
            [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(topView);
                make.top.equalTo(topView.mas_bottom);
            }];
        }
        [[self.commentViews lastObject] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
        }];
    }
}

- (NSMutableArray *)commentViews {
    if (!_commentViews) {
        _commentViews = [NSMutableArray array];
    }
    return _commentViews;
}

@end
