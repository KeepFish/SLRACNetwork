//
//  LMRequestProxy.m
//  lmps-driver
//
//  Created on 17/4/8.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import "LMRequestProxy.h"
#import "NSURLRequest+LMRequest.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "LMRequestResult.h"

@interface LMRequestProxy()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, assign) NSInteger recordedRequestId;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation LMRequestProxy

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LMRequestProxy *instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (BOOL)isReachable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - 网络请求方法

- (NSInteger)loadRequest:(NSURLRequest *)request finished:(LMNetworkFinishedBlock)finished {
    
    NSURLSessionDataTask *dataTask = nil;
    WeakSelf
    dataTask = [self.sessionManager dataTaskWithRequest:request
                                         uploadProgress:nil
                                       downloadProgress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSData *responseData = nil;
        NSNumber *requestId = @([dataTask taskIdentifier]);
        StrongWeakSelf
        [stSelf.dispatchTable removeObjectForKey:requestId];
        LMRequestError *lmError = nil;

        NSDictionary *dic;
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseData = responseObject;
            NSError *jsonError = nil;
            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError != nil) {
                lmError = [LMRequestError errorWithMessage:@"JSON解析失败" code:LMRequestResponseJSONSerializeFailed];
            }
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];
        
        if (error) {
            NSString *message = dic[@"message"];
            if (!message) {
                message = @"网络错误";
            }
            lmError = [LMRequestError errorWithMessage:message code:statusCode];
        } else if (statusCode < 200 || statusCode >= 300) {
            lmError = [LMRequestError errorWithMessage:@"网络错误" code:statusCode];
        }
        LMRequestResult *result = [LMRequestResult resultWithRequestId:requestId request:request data:responseData dic:dic headerDic:httpResponse.allHeaderFields error:lmError];

        if (finished) {
            finished(result);
        }
    }];
    
    NSInteger requestId = [dataTask taskIdentifier];
    
    self.dispatchTable[@(requestId)] = dataTask;
    [dataTask resume];
    return requestId;
}
#pragma mark - 取消网络请求方法
- (void)cancelRequestWithRequestId:(NSNumber *)requestId {
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestId];
    if (requestOperation) {
        [requestOperation cancel];
        [self.dispatchTable removeObjectForKey:requestId];
    }
}

- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList {
    for (NSNumber *requestId in requestIdList) {
        [self cancelRequestWithRequestId:requestId];
    }
}

#pragma mark - Getter
- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        // 全局菊花
//        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

//        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[AFSecurityPolicy certificatesInBundle:bundle]];
//        securityPolicy.allowInvalidCertificates = YES;
//        securityPolicy.validatesDomainName = NO;
//
//        _sessionManager.securityPolicy = securityPolicy;
    }
    return _sessionManager;
}

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                            baseUrl:(NSString *)baseUrl
                               path:(NSString *)path
                             params:(NSDictionary *)params {
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    serializer.timeoutInterval = 30;

    NSError *error = nil;
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, path];
    NSMutableURLRequest *request = [serializer requestWithMethod:method URLString:url parameters:params error:&error];
    request.lm_requestParams = params;
    
    return request;
}

+ (NSURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path params:(NSDictionary *)params {
    return [self requestWithMethod:method baseUrl:BASE_URL path:path params:params];
}

@end

