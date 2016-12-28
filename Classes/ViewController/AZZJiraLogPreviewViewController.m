//
//  AZZJiraLogPreviewViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraLogPreviewViewController.h"

#import "AZZJiraFileNode.h"

#import <Masonry/Masonry.h>

#import <SDWebImage/UIImageView+WebCache.h>

@interface AZZJiraLogPreviewViewController ()

@property (nonatomic, strong) UITextView *tvPreview;
@property (nonatomic, strong) UIImageView *ivPreview;

@end

@implementation AZZJiraLogPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tvPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.ivPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Actions

- (void)loadLogToPreview {
    if (self.fileNode) {
        [self showHudWithTitle:nil detail:nil];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            NSError *error = nil;
            switch (self.fileNode.previewType) {
                    case AZZJiraPreviewType_Text:
                {
                    NSString *log = [NSString stringWithContentsOfURL:self.fileNode.filePath encoding:NSUTF8StringEncoding error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            self.tvPreview.text = log;
                            self.tvPreview.hidden = NO;
                            self.ivPreview.hidden = YES;
                            [self hideHudAfterDelay:0];
                        } else {
                            [self showHudWithTitle:@"Error" detail:error.localizedDescription hideAfterDelay:3.f];
                        }
                    });
                    break;
                }
                    case AZZJiraPreviewType_Image:
                {
                    __weak typeof(self) wself = self;
                    [self.ivPreview sd_setImageWithURL:self.fileNode.filePath placeholderImage:[UIImage imageNamed:@"layout-placeholder"] options:SDWebImageRetryFailed | SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            wself.ivPreview.hidden = NO;
                            wself.tvPreview.hidden = YES;
                            [wself hideHudAfterDelay:0];
                        } else {
                            [wself showHudWithTitle:@"Error" detail:nil hideAfterDelay:3.f];
                        }
                    }];
                    break;
                }
                    default:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                    break;
                }
            }
        });
    }
}

#pragma mark - Properties

- (void)setFileNode:(AZZJiraFileNode *)fileNode {
    _fileNode = fileNode;
    [self loadLogToPreview];
    if (_fileNode) {
        self.title = _fileNode.filePath.lastPathComponent;
    }
}

- (UITextView *)tvPreview {
    if (!_tvPreview) {
        _tvPreview = [[UITextView alloc] init];
        _tvPreview.editable = NO;
        [self.view addSubview:_tvPreview];
    }
    return _tvPreview;
}

- (UIImageView *)ivPreview {
    if (!_ivPreview) {
        _ivPreview = [[UIImageView alloc] init];
        _ivPreview.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_ivPreview];
    }
    return _ivPreview;
}

@end
