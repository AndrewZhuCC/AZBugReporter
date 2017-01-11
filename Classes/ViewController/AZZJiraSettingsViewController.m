//
//  AZZJiraSettingsViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/5.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraSettingsViewController.h"
#import "AZZJiraConfiguration.h"
#import "AZZJiraPerformanceSettingViewController.h"
#import "AZZJiraBatteryCollectionViewController.h"

#import "AZPerformanceMonitorManager.h"

#import <Masonry/Masonry.h>
#import <NEShakeGestureManager.h>

typedef NS_ENUM(NSUInteger, AZZJiraSettingsCell) {
    AZZJiraSettings_NetworkEye = 0,
    AZZJiraSettings_Battery,
    AZZJiraSettings_TouchCollector,
    AZZJiraSettings_PerformanceSwitch,
    AZZJiraSettings_PerformanceCPU,
    AZZJiraSettings_PerformanceRunLoop,
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tvSettings reloadData];
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
    switch (indexPath.row) {
        case AZZJiraSettings_TouchCollector:
        {
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
            break;
        }
        case  AZZJiraSettings_NetworkEye:
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Network Eye";
            break;
        }
        case AZZJiraSettings_Battery:
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Battery Usage";
            break;
        }
        case AZZJiraSettings_PerformanceSwitch:
        {
            if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
                cell.accessoryView.tag = indexPath.row;
                cell.textLabel.text = @"PerformanceMonitor Enable";
            } else {
                UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchButton.tag = indexPath.row;
                [switchButton addTarget:self action:@selector(switchActionValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchButton;
                cell.textLabel.text = @"PerformanceMonitor Enable";
            }
            [(UISwitch *)cell.accessoryView setOn:[self performanceEnable]];
            break;
        }
        case AZZJiraSettings_PerformanceCPU:
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"CPU Monitor";
            break;
        }
        case AZZJiraSettings_PerformanceRunLoop:
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"RunLoop Monitor";
            break;
        }
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case AZZJiraSettings_NetworkEye:
        {
            [[NEShakeGestureManager defaultManager] presentInformationViewController];
            break;
        }
        case AZZJiraSettings_Battery:
        {
            AZZJiraBatteryCollectionViewController *vc = [AZZJiraBatteryCollectionViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case AZZJiraSettings_PerformanceCPU:
        {
            AZZJiraPerformanceSettingViewController *vc = [[AZZJiraPerformanceSettingViewController alloc] init];
            vc.monitorType = MonitorType_CPU;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            case AZZJiraSettings_PerformanceRunLoop:
        {
            AZZJiraPerformanceSettingViewController *vc = [[AZZJiraPerformanceSettingViewController alloc] init];
            vc.monitorType = MonitorType_RunLoop;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Actions

- (void)switchActionValueChanged:(UISwitch *)switchButton {
    switch (switchButton.tag) {
        case AZZJiraSettings_TouchCollector:
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:switchButton.isOn forKey:AZZJiraSettingsTouchCollectSwitch];
            break;
        }
        case AZZJiraSettings_PerformanceSwitch:
        {
            [[AZPerformanceMonitorManager sharedInstance] pauseForIO:!switchButton.isOn];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Propertys

- (BOOL)performanceEnable {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[[AZPerformanceMonitorManager sharedInstance] monitorsWithType:MonitorType_RunLoop]];
    [tempArray addObjectsFromArray:[[AZPerformanceMonitorManager sharedInstance] monitorsWithType:MonitorType_CPU]];
    for (AZPerformanceMonitor *monitor in tempArray) {
        if (!monitor.isPaused) {
            return YES;
        }
    }
    return NO;
}

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
