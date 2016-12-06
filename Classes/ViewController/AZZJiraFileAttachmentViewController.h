//
//  AZZJiraFileAttachmentViewController.h
//  BugReporter
//
//  Created by 朱安智 on 2016/12/6.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZZJiraFileNode.h"

@protocol AZZJiraFileAttachmentDelegate <NSObject>

@required
- (void)fileAttachmentDidSelect:(AZZJiraFileNode *)fileNode selected:(BOOL)selected;
- (void)fileAttachmentDidTappedDoneButton;

@end

@interface AZZJiraFileAttachmentViewController : UIViewController

@property (nonatomic, strong) AZZJiraFileNode *fileNode;
@property (nonatomic, weak) id<AZZJiraFileAttachmentDelegate> delegate;

@end
