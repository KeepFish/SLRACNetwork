//
//  LMRequest.h
//  lmps-driver
//
//  Created on 17/4/5.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMRequestResult.h"

@class LMRequest;

typedef NS_ENUM (NSUInteger, LMRequestType) {
    LMRequestTypeGet = 1,
    LMRequestTypePost,
    LMRequestTypeDelete,
    LMRequestTypePatch,
    LMRequestTypePut
};

// 接口请求参数协议
@protocol LMRequestDataSource <NSObject>

@required

- (NSDictionary *)lm_paramsForRequest:(LMRequest *)request;

@end

// 底层网络请求状态返回代理
@protocol LMRequestDelegate <NSObject>

@required

- (void)lm_request:(LMRequest *)request didFinished:(LMRequestResult *)result;

@end

// 请求拦截 - 外部
@protocol LMRequestInterceptor <NSObject>

@optional

// load之前 返回false请求不会执行
- (BOOL)lm_request:(LMRequest *)request willLoadWithParams:(NSDictionary *)params;

// 将要处理result
- (void)lm_request:(LMRequest *)request willProcessResult:(LMRequestResult *)result;

@end

// 基类定义
@interface LMRequest : NSObject

@property (nonatomic, weak) id<LMRequestDataSource> dataSource;
@property (nonatomic, weak) id<LMRequestDelegate> delegate;
@property (nonatomic, weak) id<LMRequestInterceptor> interceptor;

@property (nonatomic, assign, readonly) NSInteger requestID;

@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, assign, readonly) BOOL isReachable;

@property (nonatomic, assign) BOOL isResponseJsonable;      // default YES
@property (nonatomic, assign, getter=isShowErrorMessage) BOOL showErrorMessage; // default YES
@property (nonatomic, assign, getter=isShowLoading) BOOL showLoading;       // default YES
@property (nonatomic, assign) LMRequestType requestType;    // default LMRequestTypePost

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *baseUrl; // 地址库和图片服务器接口地址不同 需要单独设置

+ (instancetype)requestWithPath:(NSString *)path;
+ (instancetype)requestWithPath:(NSString *)path type:(LMRequestType)type;

- (NSInteger)load;

- (id)fetchData;

- (void)cancel;

#pragma mark - 拦截器

// 这里对result添加error有效
- (void)lm_willProcessResult:(LMRequestResult *)result;

- (void)lm_didProcessResult:(LMRequestResult *)result;

// 返回NO就不会发请求
- (BOOL)lm_willLoadWithParams:(NSDictionary *)params;

@end
