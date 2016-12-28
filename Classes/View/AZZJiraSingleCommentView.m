//
//  AZZJiraSingleCommentView.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraSingleCommentView.h"

#import "AZZJiraUserView.h"

#import "AZZJiraIssueCommentModel.h"
#import "AZZJiraUserModel.h"

#import <Masonry/Masonry.h>

@interface AZZJiraSingleCommentView ()

@property (nonatomic, strong) AZZJiraUserView *uvCreater;
@property (nonatomic, strong) UILabel *lbDate;
@property (nonatomic, strong) UILabel *lbBody;
@property (nonatomic, strong) UIView *separator;

@end

@implementation AZZJiraSingleCommentView

+ (instancetype)commentViewWithModel:(AZZJiraIssueCommentModel *)model {
    AZZJiraSingleCommentView *instance = [AZZJiraSingleCommentView new];
    instance.model = model;
    [instance.uvCreater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(instance).with.offset(5.f);
    }];
    [instance.lbDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.and.centerY.equalTo(instance.uvCreater);
        make.right.equalTo(instance).with.offset(-5.f);
        make.left.equalTo(instance.uvCreater.mas_right).with.offset(5.f);
    }];
    [instance.lbBody mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(instance.lbDate.mas_bottom).with.offset(5.f);
        make.left.equalTo(instance.uvCreater);
        make.right.equalTo(instance.lbDate);
    }];
    [instance.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(instance.lbBody.mas_bottom).with.offset(3.f);
        make.bottom.equalTo(instance).with.offset(-1.f);
        make.height.mas_equalTo(1);
        make.left.equalTo(instance).with.offset(15.f);
        make.right.equalTo(instance);
    }];
    return instance;
}

- (AZZJiraUserView *)uvCreater {
    if (!_uvCreater) {
        _uvCreater = [AZZJiraUserView userViewWithModel:self.model.author];
        [self addSubview:_uvCreater];
    }
    return _uvCreater;
}

- (UILabel *)lbDate {
    if (!_lbDate) {
        _lbDate = [UILabel new];
        _lbDate.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:_lbDate];
    }
    return _lbDate;
}

- (UILabel *)lbBody {
    if (!_lbBody) {
        _lbBody = [UILabel new];
        _lbBody.numberOfLines = 0;
        [self addSubview:_lbBody];
    }
    return _lbBody;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor blackColor];
        [self addSubview:_separator];
    }
    return _separator;
}

- (void)setModel:(AZZJiraIssueCommentModel *)model {
    _model = model;
    if (model) {
        self.uvCreater.model = model.author;
        self.lbDate.text = [NSDateFormatter localizedStringFromDate:model.created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        self.lbBody.text = model.body;
    }
}

@end
