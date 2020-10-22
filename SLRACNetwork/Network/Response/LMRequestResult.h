//
//  LMRequestResult.h
//  lmps-driver
//
//  Created on 17/4/9.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LMRequestResponseCode) {
    LMRequestResponseCodeNeedLogin = 401,
    LMRequestResponseJSONSerializeFailed = 777,
};

@interface LMRequestError: NSError

@property (nonatomic, copy, readonly) NSString *message;

+ (LMRequestError *)errorWithMessage:(NSString *)message code:(NSInteger)code;

@end

@interface LMRequestResult: NSObject

@property (nonatomic, strong, readonly) NSNumber *requestId;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) NSDictionary *requestParams;
@property (nonatomic, strong, readonly) NSData *responseData; // 原始数据
@property (nonatomic, strong, readonly) NSDictionary *responseDic; // 转成字典后 json化失败为空
@property (nonatomic, strong, readonly) NSDictionary *headerDic;

@property (nonatomic, strong, readonly) LMRequestError *error;

+ (instancetype)resultWithRequestId:(NSNumber *)requestId
                            request:(NSURLRequest *)request
                               data:(NSData *)data
                                dic:(NSDictionary *)dic
                          headerDic:(NSDictionary *)headerDic
                              error:(LMRequestError *)error;

- (void)updateErrorInfo:(LMRequestError *)error;

@end
