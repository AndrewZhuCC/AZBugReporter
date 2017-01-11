//
//  AZZJiraIssueDetailViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/27.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraIssueDetailViewController.h"
#import "AZZJiraAttachmentListViewController.h"
#import "AZZJiraIssueEditTransitionViewController.h"
#import "AZZJiraFileAttachmentViewController.h"
#import "MWPhotoBrowser.h"

#import "AZZJiraUserView.h"
#import "AZZJiraCommentsView.h"
#import "AZZJiraBasicCell.h"

#import "AZZJiraIssueModel.h"
#import "AZZJiraIssueTransitionModel.h"

#import "AZZJiraClient.h"

#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define IssueDetailViewsPadding 8.f

@interface AZZJiraIssueDetailViewController () <UITableViewDelegate, UITableViewDataSource, MWPhotoBrowserDelegate, AZZJiraFileAttachmentDelegate>

@property (nonatomic, strong) AZZJiraIssueModel *model;
@property (nonatomic, copy) NSArray<AZZJiraIssueTransitionModel *> *transitions;

@property (nonatomic, strong) UIScrollView *svMainView;

@property (nonatomic, strong) UILabel *lbAssignee;
@property (nonatomic, strong) AZZJiraUserView *uvAssignee;

@property (nonatomic, strong) UILabel *lbReporter;
@property (nonatomic, strong) AZZJiraUserView *uvReporter;

@property (nonatomic, strong) UIButton *btnAssignMe;
@property (nonatomic, strong) UIButton *btnAttachments;
@property (nonatomic, strong) UIButton *btnAddComment;
@property (nonatomic, strong) UIButton *btnAddAttachments;

@property (nonatomic, strong) UILabel *lbSolution;

@property (nonatomic, strong) UILabel *lbEnvironment;
@property (nonatomic, strong) UITextView *txvEnvironment;

@property (nonatomic, strong) UILabel *lbDescription;
@property (nonatomic, strong) UITextView *txvDescription;

@property (nonatomic, strong) UIButton *btnSelectAssignableUser;
@property (nonatomic, strong) UITableView *tbAssignableUsers;
@property (nonatomic, strong) UIButton *btnBackground;
@property (nonatomic, copy) NSArray<AZZJiraUserModel *> *assignableUsers;

@property (nonatomic, strong) AZZJiraCommentsView *commentsView;

@property (nonatomic, strong) MWPhotoBrowser *albumBrowser;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *albumFetchResult;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedAlbumPhotos;

@property (nonatomic, strong) NSArray<MWPhoto *> *browserPhotos;
@property (nonatomic, strong) NSMutableArray<MWPhoto *> *selectedPhotos;
@property (nonatomic, strong) NSMutableArray<AZZJiraFileNode *> *selectedFiles;

@property (nonatomic, strong) AZZJiraFileNode *rootNode;

@end

@implementation AZZJiraIssueDetailViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.albumBrowser = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.issueKey) {
        self.issueKey = self.issueKey;
    }
}

- (void)setupConstraints {
    [self.svMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.lbAssignee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.svMainView).with.offset(IssueDetailViewsPadding);
        make.left.equalTo(self.svMainView).with.offset(IssueDetailViewsPadding);
        make.width.equalTo(self.view).with.multipliedBy(0.5f).with.offset(- 1.5f * IssueDetailViewsPadding);
        make.height.mas_equalTo(40);
    }];
    [self.lbReporter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbAssignee);
        make.left.equalTo(self.lbAssignee.mas_right).with.offset(IssueDetailViewsPadding);
        make.right.equalTo(self.svMainView).with.offset(-IssueDetailViewsPadding);
        make.size.equalTo(self.lbAssignee);
    }];
    [self.uvAssignee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.lbAssignee);
        make.top.equalTo(self.lbAssignee.mas_bottom);
    }];
    [self.uvReporter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.lbReporter);
        make.centerY.equalTo(self.uvAssignee);
    }];
    [self.btnAssignMe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uvAssignee.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.centerX.equalTo(self.lbAssignee);
        make.width.equalTo(self.lbAssignee);
        make.height.mas_equalTo(30);
    }];
    [self.btnAttachments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uvReporter.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.centerX.equalTo(self.lbReporter);
        make.size.equalTo(self.btnAssignMe);
    }];
    [self.btnAddComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.and.left.and.right.equalTo(self.btnAssignMe);
        make.top.equalTo(self.btnAssignMe.mas_bottom).with.offset(IssueDetailViewsPadding);
    }];
    [self.btnAddAttachments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.and.left.and.right.equalTo(self.btnAttachments);
        make.top.equalTo(self.btnAttachments.mas_bottom).with.offset(IssueDetailViewsPadding);
    }];
    [self.lbSolution mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnAddComment.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.left.equalTo(self.lbAssignee);
        make.right.equalTo(self.lbReporter);
        make.height.mas_equalTo(40);
    }];
    CGSize environmentSize = [self.lbEnvironment sizeThatFits:CGSizeMake(CGFLOAT_MAX, 40)];
    [self.lbEnvironment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbSolution.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.size.mas_equalTo(environmentSize);
        make.left.equalTo(self.lbAssignee);
    }];
    [self.txvEnvironment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lbEnvironment.mas_right).with.offset(5.f);
        make.right.equalTo(self.lbReporter);
        make.top.equalTo(self.lbEnvironment);
        make.height.mas_equalTo(80);
    }];
    [self.lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.and.left.equalTo(self.lbEnvironment);
        make.top.equalTo(self.txvEnvironment.mas_bottom).with.offset(IssueDetailViewsPadding);
    }];
    [self.txvDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.lbSolution);
        make.top.equalTo(self.lbDescription.mas_bottom).with.offset(5.f);
        make.height.mas_equalTo(100);
    }];
    [self.commentsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.txvDescription.mas_bottom).with.offset(IssueDetailViewsPadding);
        make.bottom.equalTo(self.svMainView).with.offset(-IssueDetailViewsPadding);
        make.left.equalTo(self.lbAssignee);
        make.right.equalTo(self.lbReporter);
    }];
    [self.btnSelectAssignableUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.uvAssignee);
        make.center.equalTo(self.uvAssignee);
    }];
    [self.btnBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tbAssignableUsers mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.uvAssignee);
        make.top.equalTo(self.uvAssignee.mas_bottom);
        make.height.mas_equalTo(200.f);
    }];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"状态修改" style:UIBarButtonItemStylePlain target:self action:@selector(rightNavigateItemCliecked:)];
    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark - Actions

- (void)rightNavigateItemCliecked:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    /*
    // 暂时不启用编辑 Issue 功能
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:edit];
    */
    for (AZZJiraIssueTransitionModel *model in self.transitions) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:model.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BOOL needPush = NO;
            for (NSString *key in model.fields) {
                AZZJiraIssueTypeFieldsModel *fieldsModel = model.fields[key];
                if (fieldsModel.required) {
                    needPush = YES;
                    break;
                }
            }
            if (needPush) {
                AZZJiraIssueEditTransitionViewController *vc = [AZZJiraIssueEditTransitionViewController new];
                vc.issueId = self.issueKey;
                vc.transition = model;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self showConfirmAlertWithTitle:@"Action" message:[NSString stringWithFormat:@"确认执行[%@]操作吗？", model.name] confirmBlock:^{
                    [self showHudWithTitle:nil detail:nil];
                    [[AZZJiraClient sharedInstance] requestDoTransitionWithIssueIdOrKey:self.model.idNumber transitionId:model.idNumber resolutionId:nil commentBody:nil success:^(NSHTTPURLResponse *response, id responseObject) {
                        [self showHudWithTitle:@"成功" detail:nil hideAfterDelay:2.f];
                        self.issueKey = self.issueKey;
                    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                        [self showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
                        NSLog(@"do transition error:%@", error);
                        NSLog(@"responseObject:%@", responseObject);
                    }];
                }];
            }
        }];
        [alertController addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)btnAssignMeClicked:(UIButton *)button {
    [self showConfirmAlertWithTitle:@"分配" message:@"确认分配给你？" confirmBlock:^{
        [self showHudWithTitle:nil detail:nil];
        __weak typeof(self) wself = self;
        [[AZZJiraClient sharedInstance] requestAssignIssue:self.model.key userName:nil success:^(NSHTTPURLResponse *response, id responseObject) {
            [wself showHudWithTitle:@"成功" detail:nil hideAfterDelay:2.f];
            wself.issueKey = wself.issueKey;
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            [wself showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
            NSLog(@"Assign to me error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
    }];
}

- (void)btnAttachmentsClicked:(UIButton *)button {
    AZZJiraAttachmentListViewController *vc = [AZZJiraAttachmentListViewController new];
    vc.issueModel = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnAddCommentClicked:(UIButton *)button {
    AZZJiraIssueEditTransitionViewController *vc = [AZZJiraIssueEditTransitionViewController new];
    vc.issueId = self.issueKey;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnAddAttachmentsClicked:(UIButton *)button {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Attachment" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.browserPhotos.count != 0) {
        UIAlertAction *photosAction = [UIAlertAction actionWithTitle:@"Touch Snaps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayNavArrows = YES;
            browser.displaySelectionButtons = YES;
            
            [self.navigationController pushViewController:browser animated:YES];
        }];
        [alertController addAction:photosAction];
    }
    
    UIAlertAction *photoAlbumActon = [UIAlertAction actionWithTitle:@"Photo Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController pushViewController:self.albumBrowser animated:YES];
    }];
    [alertController addAction:photoAlbumActon];
    
    
    UIAlertAction *filesAction = [UIAlertAction actionWithTitle:@"File System" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AZZJiraFileNode *rootNode = self.rootNode;
        AZZJiraFileAttachmentViewController *vc = [[AZZJiraFileAttachmentViewController alloc] init];
        vc.delegate = self;
        vc.fileNode = rootNode;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertController addAction:filesAction];
    
    if (self.selectedFiles.count > 0 || self.selectedPhotos.count > 0 || self.selectedAlbumPhotos.count > 0) {
        UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"上传" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self showHudWithTitle:nil detail:nil];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (MWPhoto *photo in self.selectedPhotos) {
                [tempArray addObject:photo.photoURL];
            }
            for (AZZJiraFileNode *fileNode in self.selectedFiles) {
                [tempArray addObject:fileNode.filePath];
            }
            
            [[AZZJiraClient sharedInstance] uploadImagesWithIssueID:self.issueKey images:[tempArray copy] assets:[self selectedPhotoAssets] uploadProgress:^(NSProgress *progress) {
                self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                self.hud.progress = progress.completedUnitCount / progress.totalUnitCount;
                [self.hud show:YES];
            } success:^(NSHTTPURLResponse *response, id responseObject) {
                [self showHudWithTitle:@"上传附件成功" detail:nil hideAfterDelay:2.f];
                self.issueKey = self.issueKey;
                [self.selectedAlbumPhotos removeAllObjects];
                [self.selectedPhotos removeAllObjects];
                [self.selectedFiles removeAllObjects];
            } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                NSLog(@"upload fail: %@", error);
                NSLog(@"responseObject: %@", responseObject);
                [self showHudWithTitle:@"Error" detail:error.localizedDescription hideAfterDelay:3.f];
            }];
        }];
        [alertController addAction:uploadAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)btnSelectAssignableUserClicked:(UIButton *)button {
    CGRect originFrame = self.tbAssignableUsers.frame;
    CGRect toFrame = originFrame;
    toFrame.size.height = 0;
    self.tbAssignableUsers.frame = toFrame;
    self.tbAssignableUsers.hidden = NO;
    self.btnBackground.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.tbAssignableUsers.frame = originFrame;
        self.btnBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }];
}

- (void)btnBackgroundClicked:(UIButton *)button {
    CGRect originFrame = self.tbAssignableUsers.frame;
    CGRect toFrame = originFrame;
    toFrame.size.height = 0;
    [UIView animateWithDuration:0.3f animations:^{
        self.tbAssignableUsers.frame = toFrame;
        self.btnBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        self.tbAssignableUsers.hidden = YES;
        self.btnBackground.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.tbAssignableUsers.frame = originFrame;
    }];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assignableUsers.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraUserModel *model = self.assignableUsers[indexPath.row];
    if ([model isEqual:self.model.assignee]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraUserModel *model = self.assignableUsers[indexPath.row];
    AZZJiraBasicCell *cell = [AZZJiraBasicCell cellWithTableView:tableView labelText:model.displayName imageURL:model.avatarUrls[@"48x48"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AZZJiraUserModel *model = self.assignableUsers[indexPath.row];
    if ([model isEqual:self.model.assignee]) {
        return;
    }
    
    [self btnBackgroundClicked:nil];
    [self showConfirmAlertWithTitle:@"分配" message:[NSString stringWithFormat:@"确定分配给 %@ ?", model.displayName] confirmBlock:^{
        [self showHudWithTitle:nil detail:nil];
        [[AZZJiraClient sharedInstance] requestAssignIssue:self.issueKey userName:model.name success:^(NSHTTPURLResponse *response, id responseObject) {
            [self showHudWithTitle:@"成功" detail:nil hideAfterDelay:2.f];
            self.issueKey = self.issueKey;
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            [self showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
            NSLog(@"assign user error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
    }];
}

#pragma mark - AZZJiraFileAttachment

- (BOOL)fileAttachmentIsSelected:(AZZJiraFileNode *)fileNode {
    return [self.selectedFiles containsObject:fileNode];
}

- (void)fileAttachmentDidSelect:(AZZJiraFileNode *)fileNode selected:(BOOL)selected {
    if (fileNode) {
        if (selected) {
            [self.selectedFiles addObject:fileNode];
        } else {
            [self.selectedFiles removeObject:fileNode];
        }
    }
}

- (void)fileAttachmentDidTappedDoneButton {
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (photoBrowser == self.albumBrowser) {
        return self.albumFetchResult.count;
    } else {
        return self.browserPhotos.count;
    }
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (photoBrowser == self.albumBrowser) {
        return [MWPhoto photoWithAsset:[self.albumFetchResult objectAtIndex:index] targetSize:[UIScreen mainScreen].bounds.size];
    } else {
        return self.browserPhotos[index];
    }
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (photoBrowser == self.albumBrowser) {
        return [MWPhoto photoWithAsset:[self.albumFetchResult objectAtIndex:index] targetSize:CGSizeMake(100, 100)];
    } else {
        return self.browserPhotos[index];
    }
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    if (photoBrowser == self.albumBrowser) {
        return [self.selectedAlbumPhotos containsObject:@(index)];
    } else {
        return [self.selectedPhotos containsObject:self.browserPhotos[index]];
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    if (photoBrowser == self.albumBrowser) {
        if (selected) {
            [self.selectedAlbumPhotos addObject:@(index)];
        } else {
            [self.selectedAlbumPhotos removeObject:@(index)];
        }
    } else {
        if (selected) {
            [self.selectedPhotos addObject:self.browserPhotos[index]];
        } else {
            [self.selectedPhotos removeObject:self.browserPhotos[index]];
        }
    }
}

#pragma mark - Properties

- (UIScrollView *)svMainView {
    if (!_svMainView) {
        _svMainView = [UIScrollView new];
        [self.view addSubview:_svMainView];
    }
    return _svMainView;
}

- (UILabel *)lbAssignee {
    if (!_lbAssignee) {
        _lbAssignee = [UILabel new];
        _lbAssignee.font = [UIFont systemFontOfSize:15];
        _lbAssignee.text = @"经办人:";
        [self.svMainView addSubview:_lbAssignee];
    }
    return _lbAssignee;
}

- (AZZJiraUserView *)uvAssignee {
    if (!_uvAssignee) {
        _uvAssignee = [AZZJiraUserView userViewWithModel:nil];
        [self.svMainView addSubview:_uvAssignee];
    }
    return _uvAssignee;
}

- (UILabel *)lbReporter {
    if (!_lbReporter) {
        _lbReporter = [UILabel new];
        _lbReporter.font = [UIFont systemFontOfSize:15];
        _lbReporter.text = @"报告人:";
        [self.svMainView addSubview:_lbReporter];
    }
    return _lbReporter;
}

- (AZZJiraUserView *)uvReporter {
    if (!_uvReporter) {
        _uvReporter = [AZZJiraUserView userViewWithModel:nil];
        [self.svMainView addSubview:_uvReporter];
    }
    return _uvReporter;
}

- (UIButton *)btnAssignMe {
    if (!_btnAssignMe) {
        _btnAssignMe = [UIButton new];
        [_btnAssignMe setTitle:@"分配给我" forState:UIControlStateNormal];
        [_btnAssignMe setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAssignMe setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAssignMe.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAssignMe.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAssignMe.layer.cornerRadius = 5.f;
        [_btnAssignMe addTarget:self action:@selector(btnAssignMeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.svMainView addSubview:_btnAssignMe];
    }
    return _btnAssignMe;
}

- (UIButton *)btnAttachments {
    if (!_btnAttachments) {
        _btnAttachments = [UIButton new];
        [_btnAttachments setTitle:@"附件" forState:UIControlStateNormal];
        [_btnAttachments setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAttachments setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAttachments.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAttachments.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAttachments.layer.cornerRadius = 5.f;
        [_btnAttachments addTarget:self action:@selector(btnAttachmentsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.svMainView addSubview:_btnAttachments];
    }
    return _btnAttachments;
}

- (UIButton *)btnAddComment {
    if (!_btnAddComment) {
        _btnAddComment = [UIButton new];
        [_btnAddComment setTitle:@"添加备注" forState:UIControlStateNormal];
        [_btnAddComment setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAddComment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAddComment.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAddComment.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAddComment.layer.cornerRadius = 5.f;
        [_btnAddComment addTarget:self action:@selector(btnAddCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.svMainView addSubview:_btnAddComment];
    }
    return _btnAddComment;
}

- (UIButton *)btnAddAttachments {
    if (!_btnAddAttachments) {
        _btnAddAttachments = [UIButton new];
        [_btnAddAttachments setTitle:@"添加附件" forState:UIControlStateNormal];
        [_btnAddAttachments setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_btnAddAttachments setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _btnAddAttachments.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _btnAddAttachments.layer.backgroundColor = [UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000].CGColor;
        _btnAddAttachments.layer.cornerRadius = 5.f;
        [_btnAddAttachments addTarget:self action:@selector(btnAddAttachmentsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.svMainView addSubview:_btnAddAttachments];
    }
    return _btnAddAttachments;
}

- (UILabel *)lbSolution {
    if (!_lbSolution) {
        _lbSolution = [UILabel new];
        [self.svMainView addSubview:_lbSolution];
    }
    return _lbSolution;
}

- (UILabel *)lbEnvironment {
    if (!_lbEnvironment) {
        _lbEnvironment = [UILabel new];
        _lbEnvironment.text = @"环境:";
        [self.svMainView addSubview:_lbEnvironment];
    }
    return _lbEnvironment;
}

- (UITextView *)txvEnvironment {
    if (!_txvEnvironment) {
        _txvEnvironment = [UITextView new];
        _txvEnvironment.editable = NO;
        _txvEnvironment.layer.borderWidth = 1.f;
        _txvEnvironment.layer.borderColor = [UIColor blackColor].CGColor;
        _txvEnvironment.layer.cornerRadius = 5.f;
        [self.svMainView addSubview:_txvEnvironment];
    }
    return _txvEnvironment;
}

- (UILabel *)lbDescription {
    if (!_lbDescription) {
        _lbDescription = [UILabel new];
        _lbDescription.text = @"描述:";
        [self.svMainView addSubview:_lbDescription];
    }
    return _lbDescription;
}

- (UITextView *)txvDescription {
    if (!_txvDescription) {
        _txvDescription = [UITextView new];
        _txvDescription.editable = NO;
        _txvDescription.layer.borderWidth = 1.f;
        _txvDescription.layer.borderColor = [UIColor blackColor].CGColor;
        _txvDescription.layer.cornerRadius = 5.f;
        [self.svMainView addSubview:_txvDescription];
    }
    return _txvDescription;
}

- (UIButton *)btnSelectAssignableUser {
    if (!_btnSelectAssignableUser) {
        _btnSelectAssignableUser = [UIButton new];
        _btnSelectAssignableUser.backgroundColor = [UIColor clearColor];
        [_btnSelectAssignableUser addTarget:self action:@selector(btnSelectAssignableUserClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnSelectAssignableUser];
    }
    return _btnSelectAssignableUser;
}

- (UITableView *)tbAssignableUsers {
    if (!_tbAssignableUsers) {
        _tbAssignableUsers = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbAssignableUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tbAssignableUsers.delegate = self;
        _tbAssignableUsers.dataSource = self;
        _tbAssignableUsers.hidden = YES;
        _tbAssignableUsers.layer.cornerRadius = 5.f;
        [_tbAssignableUsers registerClass:[AZZJiraBasicCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraBasicCell class])];
        [self.btnBackground class];
        [self.view addSubview:_tbAssignableUsers];
    }
    return _tbAssignableUsers;
}

- (UIButton *)btnBackground {
    if (!_btnBackground) {
        _btnBackground = [UIButton new];
        _btnBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _btnBackground.hidden = YES;
        [_btnBackground addTarget:self action:@selector(btnBackgroundClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnBackground];
    }
    return _btnBackground;
}

- (AZZJiraCommentsView *)commentsView {
    if (!_commentsView) {
        _commentsView = [AZZJiraCommentsView commentsViewWithModels:self.model.comments];
        [self.svMainView addSubview:_commentsView];
    }
    return _commentsView;
}

- (void)setIssueKey:(NSString *)issueKey {
    _issueKey = [issueKey copy];
    if (issueKey) {
        __weak typeof(self) wself = self;
        [self showHudWithTitle:nil detail:nil];
        [[AZZJiraClient sharedInstance] requestIssueByIssueKey:issueKey success:^(NSHTTPURLResponse *response, id responseObject) {
            AZZJiraIssueModel *model = [AZZJiraIssueModel getIssueModelWithDictionary:responseObject];
            typeof(wself) sself = wself;
            if (model && sself) {
                sself.model = model;
                [sself hideHudAfterDelay:0];
            }
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            [wself showHudWithTitle:@"Error" detail:[responseObject description] hideAfterDelay:3.f];
            NSLog(@"get issue model error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
        [[AZZJiraClient sharedInstance] requestGetTransitionsByIssueIdOrKey:issueKey success:^(NSHTTPURLResponse *response, id responseObject) {
            NSArray *transitionsJson = [responseObject objectForKey:@"transitions"];
            self.transitions = [AZZJiraIssueTransitionModel getTransitionModelsWithJSONArray:transitionsJson];
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get issue transitions error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
        [[AZZJiraClient sharedInstance] requestAssignableUsersWithProject:nil userName:nil issueKey:issueKey success:^(NSHTTPURLResponse *response, id responseObject) {
            self.assignableUsers = [AZZJiraUserModel getUserModelsFromArray:responseObject];
            [self.tbAssignableUsers reloadData];
        } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"get assignable users error:%@", error);
            NSLog(@"responseObject:%@", responseObject);
        }];
    }
}

- (void)setModel:(AZZJiraIssueModel *)model {
    _model = model;
    if (model) {
        [self.view class];
        self.title = model.key;
        
        self.uvAssignee.model = model.assignee;
        self.uvReporter.model = model.reporter;
        
        if (model.resolution) {
            self.lbSolution.text = [NSString stringWithFormat:@"解决结果: %@", model.resolution.name];
        } else {
            self.lbSolution.text = @"解决结果: 未解决";
        }
        self.txvEnvironment.text = model.environment;
        self.txvDescription.text = model.modelDescription;
        
        self.btnAttachments.enabled = (self.model.attachment.count != 0);
        self.btnAssignMe.enabled = ![self.model.assignee isEqual:[AZZJiraClient sharedInstance].selfModel];
        
        self.commentsView.commentModels = model.comments;
    }
}

- (NSArray *)browserPhotos {
    if (!_browserPhotos) {
        _browserPhotos = [NSArray array];
        NSMutableArray *tempArray = [NSMutableArray array];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filesPath = [documentPath stringByAppendingPathComponent:@"TouchesSnapShots"];
        NSString *bakFilesPath = [documentPath stringByAppendingPathComponent:@"TouchesSnapShots_bak"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDirectory;
        for (NSString *dirPath in @[filesPath, bakFilesPath]) {
            if ([fm fileExistsAtPath:dirPath isDirectory:&isDirectory] && isDirectory) {
                NSArray *subPaths = [fm subpathsAtPath:dirPath];
                for (NSString *filePath in subPaths) {
                    NSURL *fileURL = [NSURL fileURLWithPath:filePath relativeToURL:[NSURL fileURLWithPath:dirPath]];
                    MWPhoto *photo = [[MWPhoto alloc] initWithURL:fileURL];
                    [tempArray addObject:photo];
                }
            }
        }
        _browserPhotos = [tempArray copy];
    }
    return _browserPhotos;
}

- (NSMutableArray<MWPhoto *> *)selectedPhotos {
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (NSMutableArray<AZZJiraFileNode *> *)selectedFiles {
    if (!_selectedFiles) {
        _selectedFiles = [NSMutableArray array];
    }
    return _selectedFiles;
}

- (MWPhotoBrowser *)albumBrowser {
    if (!_albumBrowser) {
        _albumBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _albumBrowser.delegate = self;
        _albumBrowser.displayNavArrows = YES;
        _albumBrowser.displaySelectionButtons = YES;
    }
    return _albumBrowser;
}

- (PHFetchResult<PHAsset *> *)albumFetchResult {
    if (!_albumFetchResult) {
        _albumFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    }
    return _albumFetchResult;
}

- (NSMutableArray<NSNumber *> *)selectedAlbumPhotos {
    if (!_selectedAlbumPhotos) {
        _selectedAlbumPhotos = [NSMutableArray array];
    }
    return _selectedAlbumPhotos;
}

- (NSArray<PHAsset *> *)selectedPhotoAssets {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSNumber *index in self.selectedAlbumPhotos) {
        PHAsset *asset = [self.albumFetchResult objectAtIndex:[index unsignedIntegerValue]];
        [tempArray addObject:asset];
    }
    return [tempArray copy];
}

- (AZZJiraFileNode *)rootNode {
    if (!_rootNode) {
        NSString *rootPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByDeletingLastPathComponent];
        _rootNode = [AZZJiraFileNode fileNodeWithRootFilePath:rootPath];
    }
    return _rootNode;
}


@end
