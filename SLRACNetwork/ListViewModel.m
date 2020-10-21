//
//  ListViewModel.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import "ListViewModel.h"
#import "Url.h"

@interface ListViewModel () <LMRequestDataSource>

@end

@implementation ListViewModel

- (instancetype)init {
    if (self = [super init]){
        WeakSelf
        [self.listRequest.successSignal subscribeNext:^(id x) {
            StrongWeakSelf
            // 为true就是刷新 所以先清除所有数据
            if ([x boolValue]) {
                [stSelf.dataSource removeAllObjects];
            }
            
            // 转成模型数组 调用set方法 触发ListViewController中的RACObserve
            stSelf.dataSource = [stSelf.listRequest fetchData];
        }];
    }
    return self;
}

- (NSDictionary *)lm_paramsForRequest:(LMRequest *)request {
    return @{
        @"": @"3",
    };
}


- (LMListRequest *)listRequest {
    if (_listRequest == nil) {
        // 可以通过子类来构建 如UserRequest
        // 也可以直接调用LMListRequest LMRequest的构造方法
        _listRequest = [LMListRequest requestWithPath:LIST_URL];
        _listRequest.dataSource = self;
    }
    return _listRequest;
}
@end
