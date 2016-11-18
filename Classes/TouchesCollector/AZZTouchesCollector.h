//
//  AZZTouchesCollector.h
//  BugReporter
//
//  Created by 朱安智 on 2016/11/11.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZZTouchesCollector : NSObject

+ (instancetype)sharedInstance;

- (void)pauseCollect:(BOOL)pause;

@end
