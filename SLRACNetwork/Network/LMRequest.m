//
//  LMRequest.m
//  lmps-driver
//
//  Created on 17/4/5.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "LMRequest.h"
#import "LMRequestProxy.h"
#import "LMRequestGlobalParams.h"

static NSDictionary *methodTypeDict;

@interface LMRequest()

@property (nonatomic, strong) LMRequestProxy *proxy;
@property (nonatomic, strong) id responseData;
@property (nonatomic, assign) NSInteger requestID;

@end

@implementation LMRequest

+ (void)initialize {
    methodTypeDict = @{
                @(LMRequestTypePost): @"POST",
                @(LMRequestTypeGet): @"GET",
                @(LMRequestTypeDelete): @"DELETE",
                @(LMRequestTypePatch): @"PATCH",
                @(LMRequestTypePut): @"PUT",
            };
}

+ (instancetype)requestWithPath:(NSString *)path {
    return [self requestWithPath:path type:LMRequestTypePost];
}

+ (instancetype)requestWithPath:(NSString *)path type:(LMRequestType)type {
    LMRequest *request = [[self alloc] init];
    request.path = path;
    request.requestType = type;
    return request;
}

- (instancetype)init {
    if (self = [super init]) {
        _proxy = [LMRequestProxy sharedInstance];
        
        // default value
        _isResponseJsonable = YES;
        _showErrorMessage = YES;
        _showLoading = YES;
        _baseUrl = BASE_URL;
    }
    return self;
}

#pragma mark - Getter
- (BOOL)isReachable {
    return self.proxy.isReachable;
}

#pragma mark - 网络操作
- (NSInteger)load {
    // 不用判断datasource是否为空 也不用判断是否实现了方法
    NSDictionary *params = [self.dataSource lm_paramsForRequest:self];
    if (params == nil) {
        params = @{};
    }
    return [self requestWithParams:params];
}

- (NSInteger)requestWithParams:(NSDictionary *)params {
    NSInteger requestID = -1;
    if ([self lm_willLoadWithParams:&params]) {
        NSMutableDictionary *finalParams = [[LMRequestGlobalParams globalParams] mutableCopy];
        [finalParams addEntriesFromDictionary:@{@"params": params.copy}];
        NSString *method = methodTypeDict[@(self.requestType)];
        NSURLRequest *request = [LMRequestProxy requestWithMethod:method baseUrl:self.baseUrl path:self.path params:finalParams];
        WeakSelf
        requestID = [self.proxy loadRequest:request finished:^(LMRequestResult *result) {
            StrongWeakSelf
            [stSelf requestDidFinished:result];
        }];
    }
    self.requestID = requestID;
    return self.requestID;
}


#pragma mark - api callbacks
- (void)requestDidFinished:(LMRequestResult *)result {
    [self lm_willProcessResult:result];
    
    [self.delegate lm_request:self didFinished:result];
    
    if (result.error == nil) {
        [self _requestDidSuccess:result];
    } else {
        [self _requestDidFail:result];
    }
    
    [self lm_didProcessResult:result];
}

- (void)_requestDidSuccess:(LMRequestResult *)result {
    DLog(@"%@ %@ ==> success: %@", self.path, result.requestParams, self.responseData);
    if (self.isResponseJsonable) {
        if (result.responseDic) {
            self.responseData = result.responseDic;
        }
    } else {
        self.responseData = [result.responseData copy];
    }
    if (self.isShowLoading) {
        [SVProgressHUD popActivity];
    }
}

- (void)_requestDidFail:(LMRequestResult *)result {
    DLog(@"%@ %@ ==> error: %@", self.path, result.requestParams, result.error);
    // 如果需要，显示错误对话框
    if (self.isShowErrorMessage) {
        [SVProgressHUD showErrorWithStatus:result.error.message];
    } else if (self.isShowLoading) {
        [SVProgressHUD popActivity];
    }
    // 特殊code处理
//    if (error.code == LMRequestResponseCodeNeedLogin) {
//
//
//        if (self.isShowErrorMessage) {
//            [SVProgressHUD showInfoWithStatus:@"会话超时或已在其他设备登录，请重新登录"];
//        }
//    }

//    [self afterPerformFailWithError:error];
}

- (id)fetchData {
    return [self.responseData mutableCopy];
}

- (void)cancel {
    // 请求取消后 AF会直接回调error
    if (self.requestID > 0) {
        [self.proxy cancelRequestWithRequestId:@(self.requestID)];
    }
}

#pragma mark - 子类处理

- (void)lm_willProcessResult:(LMRequestResult *)result {
    if ([self.interceptor respondsToSelector:@selector(lm_request:willProcessResult:)]) {
        [self.interceptor lm_request:self willProcessResult:result];
    }
}

- (void)lm_didProcessResult:(LMRequestResult *)result {
    
}

- (BOOL)lm_willLoadWithParams:(NSDictionary *__autoreleasing *)params {
    BOOL canLoad = YES;
    if ([self.interceptor respondsToSelector:@selector(lm_request:willLoadWithParams:)]) {
        canLoad = [self.interceptor lm_request:self willLoadWithParams:params];
    }
    if (canLoad) {
        if (self.isShowLoading) {
            [SVProgressHUD show];
        }
    }
    return canLoad;
}

@end
