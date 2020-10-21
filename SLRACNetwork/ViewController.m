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
@property (nonatomic, assign) NSInteger count;
/** <#code#> */
@property (nonatomic, strong) RACCommand *commmand;

@end

@implementation ViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    
    WeakSelf
    [self.updateUserInfoRequest.successSignal subscribeNext:^(LMRequestResult *result) {
        StrongWeakSelf
        // 直接拿到dic
        NSDictionary *dic = [stSelf.updateUserInfoRequest fetchData];
        // 通过result
        NSDictionary *dic2 = result.responseDic;
    }];
    [self.updateUserInfoRequest.errorSignal subscribeNext:^(LMRequestResult *result) {
        // 处理错误
    }];
    self.commmand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            if (wkSelf.count == 3) {
                [subscriber sendError:[NSError errorWithDomain:@"321321" code:123 userInfo:nil]];
            } else {
                [subscriber sendNext:@(wkSelf.count++)];
            }
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    [[self.commmand.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.commmand execute:nil];
    [super touchesBegan:touches withEvent:event];
}

- (void)sss {
    
}

- (void)update {
    [self.updateUserInfoRequest load];
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
