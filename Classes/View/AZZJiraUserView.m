//
//  AZZJiraUserView.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraUserView.h"

#import "AZZJiraUserModel.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraUserView ()

@property (nonatomic, strong) UIImageView *ivIcon;
@property (nonatomic, strong) UILabel *lbName;

@end

@implementation AZZJiraUserView

+ (instancetype)userViewWithModel:(AZZJiraUserModel *)model {
    AZZJiraUserView *instance = [[AZZJiraUserView alloc] init];
    instance.model = model;
    [instance.ivIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40.f, 40.f));
        make.left.and.top.equalTo(instance).with.offset(3.f);
        make.bottom.equalTo(instance).with.offset(-3.f);
    }];
    [instance.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(instance.ivIcon.mas_right).with.offset(3.f);
        make.height.and.centerY.equalTo(instance.ivIcon);
        make.right.equalTo(instance).with.offset(-3.f);
    }];
    return instance;
}

- (UIImageView *)ivIcon {
    if (!_ivIcon) {
        _ivIcon = [UIImageView new];
        _ivIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_ivIcon];
    }
    return _ivIcon;
}

- (UILabel *)lbName {
    if (!_lbName) {
        _lbName = [UILabel new];
        [self addSubview:_lbName];
    }
    return _lbName;
}

- (void)setModel:(AZZJiraUserModel *)model {
    _model = model;
    if (model) {
        self.lbName.text = model.displayName;
        NSURL *assigneeUrl = [NSURL URLWithString:model.avatarUrls[@"48x48"]];
        [self.ivIcon sd_setImageWithURL:assigneeUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageRetryFailed | SDWebImageHandleCookies];
    } else {
        self.ivIcon.image = [UIImage imageNamed:@"layout-placeholder"];
        self.lbName.text = @"未分配";
    }
}

@end
