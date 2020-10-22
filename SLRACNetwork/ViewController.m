//
//  ViewController.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/10.
//  Copyright © 2020 sl. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"
#import <SVProgressHUD.h>

@interface ViewController ()

@property (nonatomic, strong) ViewModel *viewModel;

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        [self setUpRac];
    }
    return self;
}

- (void)setUpRac {
    WeakSelf
    // 有关rac的操作建议写viewDidLoad或者init 保证只会订阅一次
    [self.viewModel.updateUserInfoRequest.successSignal subscribeNext:^(id  _Nullable x) {
        StrongWeakSelf
        DLog(@"model => %p \n name = %@", stSelf.viewModel.model, stSelf.viewModel.model.name);
        [SVProgressHUD showSuccessWithStatus:@"修改用户信息成功"];
    }];
    // 错误会自动弹框 一般就够了 需要自定义处理可以这样订阅
    [self.viewModel.updateUserInfoRequest.errorSignal subscribeNext:^(id  _Nullable x) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 这里model就有值了 或者通过观察model的值 然后进行UI更新等操作
    WeakSelf
    [self.viewModel.userInfoRequest.successSignal subscribeNext:^(id  _Nullable x) {
        StrongWeakSelf
        [SVProgressHUD showSuccessWithStatus:@"获取到用户信息"];
        DLog(@"model => %p \n name = %@", stSelf.viewModel.model, stSelf.viewModel.model.name);
    }];
    
    // 会在set方法触发的时候就sendnext 要注意
    [[RACObserve(self.viewModel, model) skip:1] subscribeNext:^(id  _Nullable x) {
        DLog(@"x => %p", x);
    }];
    [self.viewModel.userInfoRequest load];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateUserInfo];
}

- (void)updateUserInfo {
    self.viewModel.name = @"王五";
    self.viewModel.age = 11;
    [self.viewModel.updateUserInfoRequest load];
}

- (ViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [ViewModel new];
    }
    return _viewModel;
}

@end
