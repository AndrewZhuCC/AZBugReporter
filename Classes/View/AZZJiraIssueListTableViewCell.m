//
//  AZZJiraIssueListTableViewCell.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueListTableViewCell.h"
#import "AZZJiraIssueModel.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraIssueListTableViewCell ()

@property (nonatomic, strong) AZZJiraIssueModel *model;

@property (nonatomic, strong) UIImageView *typeIcon;
@property (nonatomic, strong) UILabel *lbType;

@property (nonatomic, strong) UILabel *lbKey;

@property (nonatomic, strong) UILabel *lbSummary;

@property (nonatomic, strong) UIImageView *statusIcon;
@property (nonatomic, strong) UILabel *lbStatus;

@property (nonatomic, strong) UIImageView *priorityIcon;
@property (nonatomic, strong) UILabel *lbPriority;

@end

@implementation AZZJiraIssueListTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueModel *)model {
    AZZJiraIssueListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[AZZJiraIssueListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
    }
    [cell setupWithModel:model];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.typeIcon.image = nil;
    self.lbType.text = nil;
    self.lbKey.text = nil;
    self.lbSummary.text = nil;
    self.statusIcon.image = nil;
    self.lbStatus.text = nil;
    self.priorityIcon.image = nil;
    self.lbPriority.text = nil;
}

- (void)setupContraints {
    [self.lbKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(8);
        make.left.equalTo(self.contentView).with.offset(8);
        make.height.mas_equalTo(35);
    }];
    [self.lbType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.lbKey);
        make.centerY.equalTo(self.lbKey);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.width.mas_equalTo(80);
    }];
    [self.typeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lbType);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.right.equalTo(self.lbType.mas_left).with.offset(-5);
    }];
    [self.lbSummary mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbKey.mas_bottom).with.offset(5);
        make.left.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-10);
    }];
    [self.lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbSummary.mas_bottom).with.offset(5);
        make.left.equalTo(self.statusIcon.mas_right).with.offset(5);
        make.bottom.equalTo(self.contentView).with.offset(-8);
        make.height.equalTo(self.lbKey);
    }];
    [self.statusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbKey);
        make.size.equalTo(self.typeIcon);
        make.centerY.equalTo(self.lbStatus);
    }];
    [self.lbPriority mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-8);
        make.height.equalTo(self.lbStatus);
        make.width.equalTo(self.lbType);
        make.centerY.equalTo(self.lbStatus);
    }];
    [self.priorityIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.statusIcon);
        make.centerY.equalTo(self.statusIcon);
        make.right.equalTo(self.lbPriority.mas_left).with.offset(-5);
    }];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupWithModel:(AZZJiraIssueModel *)model {
    self.model = model;
    
    __weak typeof(self) wself = self;
    [self.typeIcon sd_setImageWithURL:self.model.issueType.iconUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([wself.model isEqual:model] && image) {
            wself.typeIcon.image = image;
        } else if (error) {
            NSLog(@"download type icon with url: %@ error: %@", imageURL, error);
        }
    }];
    self.lbType.text = self.model.issueType.name;
    
    self.lbKey.text = self.model.key;
    
    self.lbSummary.text = self.model.summary;
    
    [self.statusIcon sd_setImageWithURL:self.model.status.iconUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([wself.model isEqual:model] && image) {
            wself.statusIcon.image = image;
        } else if (error) {
            NSLog(@"download status icon with url: %@ error: %@", imageURL, error);
        }
    }];
    self.lbStatus.text = self.model.status.name;
    
    [self.priorityIcon sd_setImageWithURL:self.model.priority.iconUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([wself.model isEqual:model] && image) {
            wself.priorityIcon.image = image;
        } else if (error) {
            NSLog(@"download priority icon with url: %@ error: %@", imageURL, error);
        }
    }];
    self.lbPriority.text = self.model.priority.name;
}

#pragma mark - Views

- (UIImageView *)typeIcon {
    if (!_typeIcon) {
        _typeIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_typeIcon];
    }
    return _typeIcon;
}

- (UILabel *)lbType {
    if (!_lbType) {
        _lbType = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbType.font = [UIFont systemFontOfSize:15];
        _lbType.backgroundColor = [UIColor clearColor];
        _lbType.textColor = [UIColor blackColor];
        [self.contentView addSubview:_lbType];
    }
    return _lbType;
}

- (UILabel *)lbKey {
    if (!_lbKey) {
        _lbKey = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbKey.font = [UIFont systemFontOfSize:15];
        _lbKey.backgroundColor = [UIColor clearColor];
        _lbKey.textColor = [UIColor blackColor];
        [self.contentView addSubview:_lbKey];
    }
    return _lbKey;
}

- (UILabel *)lbSummary {
    if (!_lbSummary) {
        _lbSummary = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbSummary.backgroundColor = [UIColor clearColor];
        _lbSummary.layer.backgroundColor = [UIColor cyanColor].CGColor;
        _lbSummary.layer.cornerRadius = 5.f;
        _lbSummary.textColor = [UIColor blackColor];
        _lbSummary.numberOfLines = 0;
        [self.contentView addSubview:_lbSummary];
    }
    return _lbSummary;
}

- (UIImageView *)statusIcon {
    if (!_statusIcon) {
        _statusIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_statusIcon];
    }
    return _statusIcon;
}

- (UILabel *)lbStatus {
    if (!_lbStatus) {
        _lbStatus = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbStatus.font = [UIFont systemFontOfSize:15];
        _lbStatus.backgroundColor = [UIColor clearColor];
        _lbStatus.textColor = [UIColor blackColor];
        [self.contentView addSubview:_lbStatus];
    }
    return _lbStatus;
}

- (UIImageView *)priorityIcon {
    if (!_priorityIcon) {
        _priorityIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_priorityIcon];
    }
    return _priorityIcon;
}

- (UILabel *)lbPriority {
    if (!_lbPriority) {
        _lbPriority = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbPriority.font = [UIFont systemFontOfSize:15];
        _lbPriority.backgroundColor = [UIColor clearColor];
        _lbPriority.textColor = [UIColor blackColor];
        [self.contentView addSubview:_lbPriority];
    }
    return _lbPriority;
}

@end
