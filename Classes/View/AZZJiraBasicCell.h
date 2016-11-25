//
//  AZZJiraBasicCell.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/25.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZZJiraBasicCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView labelText:(NSString *)labelText imageURL:(NSString *)imageUrl;
- (void)setupWithLabelText:(NSString *)labelText imageURL:(NSString *)imageURL;

@end
