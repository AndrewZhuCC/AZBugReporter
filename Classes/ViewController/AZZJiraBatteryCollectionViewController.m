//
//  AZZJiraBatteryCollectionViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2017/1/11.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "AZZJiraBatteryCollectionViewController.h"
#import "AZZWindow.h"

#import <Masonry/Masonry.h>

@interface AZZJiraBatteryCollectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbBattery;
@property (nonatomic, copy) NSArray *arrBattery;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *dicBattery;

@end

@implementation AZZJiraBatteryCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConstraints];
    self.dicBattery = [AZZWindow sharedInstance].batterValues;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConstraints {
    [self.tbBattery mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dicBattery.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Battery"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Battery"];
    }
    NSString *className = self.arrBattery[indexPath.row];
    NSNumber *numLevel = self.dicBattery[className];
    float level = [numLevel floatValue];
    cell.textLabel.text = className;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", level];
    return cell;
}

#pragma mark - Properties

- (UITableView *)tbBattery {
    if (!_tbBattery) {
        _tbBattery = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbBattery.delegate = self;
        _tbBattery.dataSource = self;
        _tbBattery.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tbBattery.allowsSelection = NO;
        [self.view addSubview:_tbBattery];
    }
    return _tbBattery;
}

- (void)setDicBattery:(NSDictionary<NSString *,NSNumber *> *)dicBattery {
    _dicBattery = [dicBattery copy];
    self.arrBattery = _dicBattery.allKeys;
    [self.tbBattery reloadData];
}

@end
