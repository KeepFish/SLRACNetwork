//
//  ViewModel.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/22.
//  Copyright © 2020 sl. All rights reserved.
//

#import "ViewModel.h"

@interface ViewModel () <LMRequestDataSource>

@end

@implementation ViewModel

- (instancetype)init {
    if (self = [super init]) {
        WeakSelf
        [self.updateUserInfoRequest.successSignal subscribeNext:^(LMRequestResult *result) {
            StrongWeakSelf
            // 直接拿到dic
//            NSDictionary *dic = [stSelf.updateUserInfoRequest fetchData];
            // 通过result
//            NSDictionary *dic2 = result.responseDic;
            // 构建model
            stSelf.model = [UserModel new];
            stSelf.model.name = stSelf.name ?: @"李四";
        }];
        [self.userInfoRequest.successSignal subscribeNext:^(LMRequestResult *result) {
            StrongWeakSelf
            stSelf.model = [UserModel new];
            stSelf.model.name = @"张三";
        }];

        [self.updateUserInfoRequest.errorSignal subscribeNext:^(LMRequestResult *result) {
            // 处理错误
        }];
    }
    return self;
}

- (NSDictionary *)lm_paramsForRequest:(LMRequest *)request {
    if (request == self.updateUserInfoRequest) {
        return @{
            @"name": self.name,
            @"age": @(self.age)
        };
    }
    return @{
        @"user_id": @"100086"
    };
}

- (UserRequest *)userInfoRequest {
    if (_userInfoRequest == nil) {
        _userInfoRequest = [UserRequest requestForGetUserInfo];
        _userInfoRequest.dataSource = self;
    }
    return _userInfoRequest;
}

- (UserRequest *)updateUserInfoRequest {
    if (_updateUserInfoRequest == nil) {
        _updateUserInfoRequest = [UserRequest requestForUpdateUserInfo];
        _updateUserInfoRequest.dataSource = self;
    }
    return _updateUserInfoRequest;
}

@end
