//
//  MyTestButton.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/11.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "MyTestButton.h"

@implementation MyTestButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touches began");
}

@end
