//
//  AZZJiraCreateIssueViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/24.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraCreateIssueViewController.h"

#import "AZZJiraCreateIssueFieldCell.h"

#import "AZZJiraIssueTypeFieldsModel.h"
#import "AZZJiraProjectsModel.h"
#import "AZZJiraIssueTypeModel.h"
#import "AZZJiraCreateIssueInputModel.h"
#import "AZZJiraFileAttachmentViewController.h"

#import "AZZJiraClient.h"

#import "MWPhotoBrowser.h"

#import <Masonry/Masonry.h>
#import "UITableView+FDTemplateLayoutCell.h"

@interface AZZJiraCreateIssueViewController () <UITableViewDelegate, UITableViewDataSource, AZZJiraCreateIssueFieldCellDelegate, MWPhotoBrowserDelegate, AZZJiraFileAttachmentDelegate>

@property (nonatomic, strong) UITableView *tvInputs;

@property (nonatomic, copy) NSDictionary<NSString *, AZZJiraIssueTypeFieldsModel *> *fieldsModels;
@property (nonatomic, copy) NSArray *allModelKeys;

@property (nonatomic, strong) MWPhotoBrowser *albumBrowser;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *albumFetchResult;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedAlbumPhotos;

@property (nonatomic, strong) NSArray<MWPhoto *> *browserPhotos;
@property (nonatomic, strong) NSMutableArray<MWPhoto *> *selectedPhotos;
@property (nonatomic, strong) NSMutableArray<AZZJiraFileNode *> *selectedFiles;

@property (nonatomic, strong) AZZJiraCreateIssueInputModel *inputModel;

@end

@implementation AZZJiraCreateIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    [self setupNavigationItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestCreateIssueFieldsWithProjectKey:self.projectModel.key issueTypeId:self.issueTypeModel.idNumber success:^(NSHTTPURLResponse *response, id responseObject) {
        NSDictionary *jsonDic = responseObject[@"projects"][0][@"issuetypes"][0][@"fields"];
        wself.fieldsModels = [AZZJiraIssueTypeFieldsModel getFieldsDictionaryWithDictionary:jsonDic];
        [wself.tvInputs reloadData];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"request create issue fields failed: %@", error);
    }];
    
    self.albumBrowser = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupConstraints {
    [self.tvInputs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNavigationItem {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createIssueButtonTapped:)];
    UIBarButtonItem *photosButton = [[UIBarButtonItem alloc] initWithTitle:@"attachment" style:UIBarButtonItemStylePlain target:self action:@selector(attachmentButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[right, photosButton];
}

#pragma mark - Actions

- (void)createIssueButtonTapped:(id)sender {
    [self.tvInputs endEditing:NO];
    [self showHudWithTitle:nil detail:nil];
    __weak typeof(self) wself = self;
    [[AZZJiraClient sharedInstance] requestCreateIssueWith:self.inputModel success:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"create issue success:%@", responseObject);
        if (wself) {
            typeof(wself) sself = wself;
            if (sself.selectedPhotos.count > 0 || sself.selectedFiles.count > 0 || sself.selectedAlbumPhotos.count > 0) {
                [wself uploadAttachmentsWithIssueID:responseObject[@"id"]];
            } else {
                [wself.navigationController popViewControllerAnimated:YES];
            }
        }
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"create issue fail:%@", error);
        NSLog(@"responseObject: %@", responseObject);
        if (wself) {
            NSMutableString *tempString = [NSMutableString string];
            for (NSString *key in responseObject[@"errors"]) {
                if (tempString.length > 0) {
                    [tempString appendString:@"\n"];
                }
                [tempString appendFormat:@"%@: %@", key, responseObject[@"errors"][key]];
            }
            [wself showHudWithTitle:@"Error" detail:[tempString copy] hideAfterDelay:3.f];
        }
    }];
}

- (void)uploadAttachmentsWithIssueID:(NSString *)issueId {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (MWPhoto *photo in self.selectedPhotos) {
        [tempArray addObject:photo.photoURL];
    }
    for (AZZJiraFileNode *fileNode in self.selectedFiles) {
        [tempArray addObject:fileNode.filePath];
    }
    
    [[AZZJiraClient sharedInstance] uploadImagesWithIssueID:issueId images:[tempArray copy] assets:[self selectedPhotoAssets] uploadProgress:^(NSProgress *progress) {
        self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self.hud.progress = progress.completedUnitCount / progress.totalUnitCount;
        [self.hud showAnimated:YES];
    } success:^(NSHTTPURLResponse *response, id responseObject) {
        [self.navigationController popViewControllerAnimated:YES];
    } fail:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"upload fail: %@", error);
        NSLog(@"responseObject: %@", responseObject);
        [self showHudWithTitle:@"Error" detail:error.localizedDescription hideAfterDelay:3.f];
    }];
}

- (void)attachmentButtonTapped:(id)sender {
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
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        AZZJiraFileNode *rootNode = [AZZJiraFileNode fileNodeWithRootFilePath:rootPath];
        AZZJiraFileAttachmentViewController *vc = [[AZZJiraFileAttachmentViewController alloc] init];
        vc.delegate = self;
        vc.fileNode = rootNode;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertController addAction:filesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AZZJiraFileAttachment

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

#pragma mark - FieldValue

- (void)fieldOfCell:(AZZJiraCreateIssueFieldCell *)cell filledWithValue:(id)value type:(AZZJiraIssueFieldAllowedType)type system:(NSString *)system {
    
    if ([system isEqualToString:@"labels"]) {
        [self.inputModel setValue:@[value] forKey:system];
        return;
    }
    
    switch (type) {
        case AZZJiraFieldType_Version:
        case AZZJiraFieldType_Component:
        {
            [self.inputModel setValue:@[value] forKey:system];
            break;
        }
        case AZZJiraFieldType_Priority:
        case AZZJiraFieldType_User:
        case AZZJiraFieldType_Default:
        {
            [self.inputModel setValue:value forKey:system];
            break;
        }
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allModelKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueTypeFieldsModel *model = self.fieldsModels[self.allModelKeys[indexPath.row]];
    AZZJiraCreateIssueFieldCell *cell = [AZZJiraCreateIssueFieldCell cellWithTableView:tableView model:model delegate:self value:[self.inputModel valueForKey:model.system]];
    cell.projectModel = self.projectModel;
    return cell;
}

- (void)setFieldsModels:(NSDictionary<NSString *,AZZJiraIssueTypeFieldsModel *> *)fieldsModels {
    _fieldsModels = [fieldsModels copy];
    NSArray *sortedKeys = @[@"summary", @"priority", @"duedate", @"components", @"versions", @"fixVersions", @"assignee", @"reporter", @"environment", @"description", @"attachment", @"labels"];
    NSMutableArray *tempKeys = [fieldsModels.allKeys mutableCopy];
    [tempKeys removeObjectsInArray:@[@"issuetype", @"project", @"timetracking", @"attachment"]];
    self.allModelKeys = [tempKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger idx1 = [sortedKeys indexOfObject:obj1];
        NSInteger idx2 = [sortedKeys indexOfObject:obj2];
        if (idx1 == NSNotFound && idx2 == NSNotFound) {
            NSLog(@"key not found:%@ ,%@", obj1, obj2);
            return NSOrderedSame;
        }
        if (idx1 == NSNotFound) {
            NSLog(@"key not found:%@", obj1);
            return NSOrderedDescending;
        }
        if (idx2 == NSNotFound) {
            NSLog(@"key not found:%@", obj2);
            return NSOrderedAscending;
        }
        if (idx1 > idx2) {
            return NSOrderedDescending;
        } else if (idx1 == idx2) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AZZJiraIssueTypeFieldsModel *model = self.fieldsModels[self.allModelKeys[indexPath.row]];
    __weak typeof(self) wself = self;
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([AZZJiraCreateIssueFieldCell class]) cacheByKey:model.system configuration:^(AZZJiraCreateIssueFieldCell *cell) {
        [cell setupWithModel:model value:nil];
        cell.projectModel = wself.projectModel;
    }];
}

#pragma mark - Views

- (UITableView *)tvInputs {
    if (!_tvInputs) {
        _tvInputs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvInputs.delegate = self;
        _tvInputs.dataSource = self;
        _tvInputs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tvInputs.allowsSelection = NO;
        [_tvInputs registerClass:[AZZJiraCreateIssueFieldCell class] forCellReuseIdentifier:NSStringFromClass([AZZJiraCreateIssueFieldCell class])];
        [self.view addSubview:_tvInputs];
    }
    return _tvInputs;
}

- (AZZJiraCreateIssueInputModel *)inputModel {
    if (!_inputModel) {
        _inputModel = [[AZZJiraCreateIssueInputModel alloc] init];
        _inputModel.project = self.projectModel;
        _inputModel.issuetype = self.issueTypeModel;
    }
    return _inputModel;
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

@end
