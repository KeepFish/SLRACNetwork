//
//  ViewController.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/10.
//  Copyright © 2020 sl. All rights reserved.
//

#import "ViewController.h"
#import "UserRequest.h"

@interface ViewController () <LMRequestDataSource>

@property (nonatomic, strong) UserRequest *updateUserInfoRequest;

@end

@implementation ViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    
    WeakSelf
    [self.updateUserInfoRequest.executionSignal subscribeNext:^(LMRequestResult *result) {
        StrongWeakSelf
        // 直接拿到dic
        NSDictionary *dic = [stSelf.updateUserInfoRequest fetchData];
        // 通过result
        NSDictionary *dic2 = result.responseDic;
    }];
    [self.updateUserInfoRequest.requestErrorSignal subscribeNext:^(LMRequestResult *result) {
        // 处理错误
    }];
}

- (void)update {
    [self.updateUserInfoRequest.requestCommand execute:nil];
}

- (NSDictionary *)lm_paramsForRequest:(LMRequest *)request {
    return @{
        @"name": @"张三"
    };
}

- (UserRequest *)updateUserInfoRequest {
    if (_updateUserInfoRequest == nil) {
        _updateUserInfoRequest = [UserRequest requestForUpdateUserInfo];
        _updateUserInfoRequest.dataSource = self;
    }
    return _updateUserInfoRequest;
}
@end
