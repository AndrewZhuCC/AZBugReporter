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
#import <MBProgressHUD/MBProgressHUD.h>

@interface AZZJiraLogPreviewViewController ()

@property (nonatomic, strong) UITextView *tvPreview;
@property (nonatomic, strong) UIImageView *ivPreview;
@property (nonatomic, strong) MBProgressHUD *hud;

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
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.label.text = nil;
        self.hud.detailsLabel.text = nil;
        [self.hud showAnimated:YES];
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
                            [self.hud hideAnimated:YES];
                        } else {
                            self.hud.mode = MBProgressHUDModeText;
                            self.hud.label.text = @"Error";
                            self.hud.detailsLabel.text = [error localizedFailureReason];
                            [self.hud hideAnimated:YES afterDelay:3.f];
                        }
                    });
                    break;
                }
                    case AZZJiraPreviewType_Image:
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:[self.fileNode.filePath path]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image) {
                            self.ivPreview.image = image;
                            self.ivPreview.hidden = NO;
                            self.tvPreview.hidden = YES;
                            [self.hud hideAnimated:YES];
                        } else {
                            self.hud.mode = MBProgressHUDModeText;
                            self.hud.label.text = @"Error";
                            self.hud.detailsLabel.text = nil;
                            [self.hud hideAnimated:YES afterDelay:3.f];
                        }
                    });
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

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.hidden = YES;
        [self.view addSubview:_hud];
    }
    return _hud;
}

@end
