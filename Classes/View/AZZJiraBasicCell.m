//
//  AZZJiraBasicCell.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraBasicCell.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraBasicCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *lbName;

@end

@implementation AZZJiraBasicCell

+ (instancetype)cellWithTableView:(UITableView *)tableView labelText:(NSString *)labelText imageURL:(NSString *)imageUrl {
    AZZJiraBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[AZZJiraBasicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
    }
    [cell setupWithLabelText:labelText imageURL:imageUrl];
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
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
        make.width.equalTo(self.icon.mas_height);
    }];
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupWithLabelText:(NSString *)labelText imageURL:(NSString *)imageURL {
    self.lbName.text = labelText;
    NSURL *imageUrl = [NSURL URLWithString:imageURL];
    if (imageUrl) {
        __weak typeof(self) wself = self;
        [self.icon sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([imageUrl isEqual:imageURL]) {
                wself.icon.image = image;
                [wself.icon setNeedsLayout];
            }
        }];
    }
}

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

@end
