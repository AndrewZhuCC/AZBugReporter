//
//  AZZJiraUserView.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZJiraUserModel;

@interface AZZJiraUserView : UIView

@property (nonatomic, strong) AZZJiraUserModel *model;
@property (nonatomic, strong, readonly) UIImageView *ivIcon;
@property (nonatomic, strong, readonly) UILabel *lbName;

+ (instancetype)userViewWithModel:(AZZJiraUserModel *)model;

@end
