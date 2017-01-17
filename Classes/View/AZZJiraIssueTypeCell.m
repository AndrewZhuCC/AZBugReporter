//
//  AZZJiraIssueTypeCell.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/23.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueTypeCell.h"
#import "AZZJiraIssueTypeModel.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraIssueTypeCell ()

@property (nonatomic, strong) AZZJiraIssueTypeModel *model;

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *lbName;
@property (nonatomic, strong) UILabel *lbDescription;

@end

@implementation AZZJiraIssueTypeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraIssueTypeModel *)model {
    AZZJiraIssueTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    if (!cell) {
        cell = [[AZZJiraIssueTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self.class)];
    }
    [cell setupWithModel:model];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.icon.image = nil;
    self.lbName.text = nil;
    self.lbDescription.text = nil;
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(self.lbName);
        make.left.equalTo(self.contentView).with.offset(8);
    }];
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(8);
        make.left.equalTo(self.icon.mas_right).with.offset(20);
        make.height.mas_equalTo(40);
    }];
    [self.lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbName).with.offset(-5);
        make.right.equalTo(self.contentView).with.offset(-20);
        make.top.equalTo(self.lbName.mas_bottom);
        make.bottom.equalTo(self.contentView).with.offset(-12);
    }];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupWithModel:(AZZJiraIssueTypeModel *)model {
    self.model = model;
    
    self.lbName.text = model.name;
    self.lbDescription.text = model.modelDescription;
    
    __weak typeof(self) wself = self;
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"layout-placeholder" ofType:@"png"];
    [self.icon sd_setImageWithURL:model.iconUrl placeholderImage:[UIImage imageWithContentsOfFile:imagePath] options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && [model isEqual:wself.model]) {
            wself.icon.image = image;
        } else if (error) {
            NSLog(@"download issue type icon url: %@ error: %@", imageURL, error);
        }
    }];
}

#pragma mark - View

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)lbName {
    if (!_lbName) {
        _lbName = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbName.backgroundColor = [UIColor clearColor];
        _lbName.textColor = [UIColor blackColor];
        [self.contentView addSubview:_lbName];
    }
    return _lbName;
}

- (UILabel *)lbDescription {
    if (!_lbDescription) {
        _lbDescription = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbDescription.backgroundColor = [UIColor clearColor];
        _lbDescription.textColor = [UIColor blackColor];
        _lbDescription.font = [UIFont systemFontOfSize:15.f];
        _lbDescription.numberOfLines = 0;
        [self.contentView addSubview:_lbDescription];
    }
    return _lbDescription;
}

@end
