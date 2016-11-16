//
//  ViewController.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/10.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abcd"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abcd"];
    }
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController) {
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *vc = [st instantiateViewControllerWithIdentifier:@"viewcontroller"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *vc = [st instantiateViewControllerWithIdentifier:@"viewcontroller"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

@end
