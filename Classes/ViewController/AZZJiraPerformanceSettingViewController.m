//
//  AZZJiraPerformanceSettingViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/12/5.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "AZZJiraPerformanceSettingViewController.h"

#import <Masonry/Masonry.h>
#import "AZPerformanceMonitorMarco.h"

@interface AZZJiraPerformanceSettingViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tvMonitors;
@property (nonatomic, strong) NSArray<AZPerformanceMonitor *> *monitors;

@end

@implementation AZZJiraPerformanceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadMonitors];
}

- (void)setupConstraints {
    [self.tvMonitors mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - UITableViewDelegate

- (void)reloadMonitors {
    self.monitors = nil;
    [self.tvMonitors reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.monitors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monitorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monitorCell"];
    }
    
    if (![cell.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchButton;
        [switchButton addTarget:self action:@selector(switchButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    cell.accessoryView.tag = indexPath.row;
    [(UISwitch *)cell.accessoryView setOn:!self.monitors[indexPath.row].pause];
    
    AZPerformanceMonitorConfiguration *config = self.monitors[indexPath.row].config;
    switch (config.monitorType) {
        case MonitorType_CPU:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"MostUsage:%@%% TimeInterval:%@ms", @(config.cpuUsageToNotify), @(config.milliseconds)];
            break;
        }
        case MonitorType_RunLoop:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"NoResponse:%@ms Count:%@", @(config.milliseconds), @(config.countToNotify)];
            break;
        }
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[AZPerformanceMonitorManager sharedInstance] removeObserver:self.monitors[indexPath.row]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * self.monitors[indexPath.row].config.milliseconds * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self reloadMonitors];
        });
    }
}

#pragma mark - TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSArray *numbers = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @""];
    return [numbers containsObject:string];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (void)switchButtonValueChanged:(UISwitch *)switchButton {
    NSInteger index = switchButton.tag;
    self.monitors[index].pause = !switchButton.isOn;
}

- (void)addButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Monitor" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = wself;
        textField.placeholder = @"milliseconds";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = wself;
        textField.placeholder = @"usage for cpu, count for runloop";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }];
    
    __weak typeof(alertController) walert = alertController;
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger milliseconds = 0;
        NSInteger secondPara = 0;
        for (UITextField *textField in walert.textFields) {
            if (textField.text.length > 0) {
                if ([textField.placeholder isEqualToString:@"milliseconds"]) {
                    milliseconds = [textField.text integerValue];
                } else {
                    secondPara = [textField.text integerValue];
                }
            } else {
                return;
            }
        }
        switch (wself.monitorType) {
            case MonitorType_CPU:
            {
                ObserveCPU(secondPara, milliseconds)
                break;
            }
            case MonitorType_RunLoop:
            {
                ObserveRunLoop(secondPara, milliseconds)
                break;
            }
        }
        [wself reloadMonitors];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:doneAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Propertys

- (UITableView *)tvMonitors {
    if (!_tvMonitors) {
        _tvMonitors = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tvMonitors.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tvMonitors.delegate = self;
        _tvMonitors.dataSource = self;
        _tvMonitors.allowsSelection = NO;
        [self.view addSubview:_tvMonitors];
    }
    return _tvMonitors;
}

- (NSArray<AZPerformanceMonitor *> *)monitors {
    if (!_monitors) {
        _monitors = [[AZPerformanceMonitorManager sharedInstance] monitorsWithType:self.monitorType];
    }
    return _monitors;
}

@end
