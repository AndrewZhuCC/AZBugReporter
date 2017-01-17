//
//  AZZJiraProjectListCell.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/21.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraProjectListCell.h"
#import "AZZJiraProjectsModel.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraProjectListCell ()

@property (nonatomic, strong) UIImageView *projectIcon;
@property (nonatomic, strong) UILabel *projectName;

@property (nonatomic, strong) AZZJiraProjectsModel *model;

@end

@implementation AZZJiraProjectListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(AZZJiraProjectsModel *)model {
    AZZJiraProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[AZZJiraProjectListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
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
    self.projectIcon.image = nil;
    self.projectName.text = nil;
}

- (void)setupConstraints {
    [self.projectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
        make.width.equalTo(self.projectIcon.mas_height);
    }];
    [self.projectName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.projectIcon.mas_right).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupWithModel:(AZZJiraProjectsModel *)model {
    self.model = model;
    self.projectName.text = model.name;
    NSString *urlString = model.avatarUrls[@"48x48"];
    NSURL *imageUrl = [NSURL URLWithString:urlString];
    if (imageUrl) {
        __weak typeof(self) wself = self;
        NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"layout-placeholder" ofType:@"png"];
        [self.projectIcon sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageWithContentsOfFile:imagePath] options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([wself.model isEqual:model]) {
                wself.projectIcon.image = image;
                [wself.projectIcon setNeedsLayout];
            }
        }];
    }
}

- (UIImageView *)projectIcon {
    if (!_projectIcon) {
        _projectIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_projectIcon];
    }
    return _projectIcon;
}

- (UILabel *)projectName {
    if (!_projectName) {
        _projectName = [[UILabel alloc] initWithFrame:CGRectZero];
        _projectName.backgroundColor = [UIColor clearColor];
        _projectName.textColor = [UIColor blackColor];
        [self.contentView addSubview:_projectName];
    }
    return _projectName;
}

@end
