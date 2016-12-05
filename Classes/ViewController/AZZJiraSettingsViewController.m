//
//  AZZJiraSettingsViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/5.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraSettingsViewController.h"
#import "AZZJiraConfiguration.h"

#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, AZZJiraSettingsCell) {
    AZZJiraSettings_TouchCollector = 0,
    AZZJiraSettings_CellCount,
};

@interface AZZJiraSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tvSettings;

@end

@implementation AZZJiraSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tvSettings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AZZJiraSettings_CellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingsCell"];
    }
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        cell.accessoryView.tag = indexPath.row;
        cell.textLabel.text = @"Collect Touches";
    } else {
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchButton.tag = indexPath.row;
        [switchButton addTarget:self action:@selector(switchActionValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchButton;
        cell.textLabel.text = @"Collect Touches";
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [(UISwitch *)cell.accessoryView setOn:[userDefaults boolForKey:AZZJiraSettingsTouchCollectSwitch]];
    return cell;
}

#pragma mark - Actions

- (void)switchActionValueChanged:(UISwitch *)switchButton {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:switchButton.isOn forKey:AZZJiraSettingsTouchCollectSwitch];
}

#pragma mark - Propertys

- (UITableView *)tvSettings {
    if (!_tvSettings) {
        _tvSettings = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvSettings.delegate = self;
        _tvSettings.dataSource = self;
        _tvSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_tvSettings];
    }
    return _tvSettings;
}

@end
