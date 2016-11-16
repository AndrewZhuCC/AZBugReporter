//
//  AZZTouchesCollector.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/11.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZTouchesCollector.h"
#import "UIWindow+SendEvent.h"

@interface AZZTouchesCollector ()

@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation AZZTouchesCollector

+ (instancetype)sharedInstance {
    static AZZTouchesCollector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AZZTouchesCollector alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchesNotification:) name:AZZTouchesDidSentByUIWindow object:nil];
        [self createTimer];
    }
    return self;
}

- (void)createTimer {
    _ioQueue = dispatch_queue_create("com.andrew.touchesCollectorIO", DISPATCH_QUEUE_SERIAL);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _ioQueue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC, 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(_timer, ^{
        [wself moveImagesPerMinute];
    });
    dispatch_resume(_timer);
}

#pragma mark - Notification

- (void)touchesNotification:(NSNotification *)notification {
    dispatch_async(self.ioQueue, ^{
        NSDictionary *dic = [notification userInfo];
        NSArray *touches = [dic objectForKey:@"touches"];
        [self saveImage:[self screenShotWithTouches:touches]];
    });
}

#pragma mark - SnapShot

- (UIImage *)screenShotWithTouches:(NSArray *)touches {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(window.bounds.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    [statusBar.layer renderInContext:context];
    for (AZZTouch *touch in touches) {
        CGPoint point = touch.locationInKeyWindow;
        UIColor *color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        switch (touch.phase) {
            case UITouchPhaseBegan:
                color = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
                break;
            case UITouchPhaseMoved:
                color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
                break;
            default:
                break;
        }
        CGContextAddEllipseInRect(context, CGRectMake(point.x - 8, point.y - 8, 16, 16));
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)saveImage:(UIImage *)image {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filesPath = [documentPath stringByAppendingPathComponent:@"TouchesSnapShots"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (!([fm fileExistsAtPath:filesPath isDirectory:&isDirectory] && isDirectory)) {
        [fm createDirectoryAtPath:filesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
    NSString *imagePath = [filesPath stringByAppendingPathComponent:[[formatter stringFromDate:currentDate] stringByAppendingString:@".png"]];
    
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

#pragma mark - File Management

- (void)moveImagesPerMinute {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filesPath = [documentPath stringByAppendingPathComponent:@"TouchesSnapShots"];
    NSString *bakFilesPath = [documentPath stringByAppendingPathComponent:@"TouchesSnapShots_bak"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL bakIsDirectory;
    BOOL isDirectory;
    if ([fm fileExistsAtPath:filesPath isDirectory:&isDirectory] && isDirectory) {
        NSError *error;
        if ([fm fileExistsAtPath:bakFilesPath isDirectory:&bakIsDirectory] && bakIsDirectory) {
            if (![fm removeItemAtPath:bakFilesPath error:&error]) {
                NSLog(@"remove bak images error:%@", error);
            }
        }
        if (![fm moveItemAtPath:filesPath toPath:bakFilesPath error:&error]) {
            NSLog(@"move images to bak folder error:%@", error);
        }
    }
    
}

@end
