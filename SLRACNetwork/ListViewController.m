//
//  ListViewController.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import "ListViewController.h"
#import "UITableView+Lmps.h"
#import "LMNetwork.h"
#import "ListViewModel.h"

@interface ListViewController () <UITableViewDataSource>

@property (nonatomic, strong) ListViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    [self.viewModel.listRequest refresh];
}

#pragma mark -
#pragma mark ---------UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ClassName(UITableViewCell) forIndexPath:indexPath];
    return cell;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [UITableView lm_tableViewWithStyle:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:ClassName(UITableViewCell)];
        _tableView.dataSource = self;
        [_tableView lm_bindRefreshingWithListRequest:self.viewModel.listRequest];
    }
    return _tableView;
}

@end
