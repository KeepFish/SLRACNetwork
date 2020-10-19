//
//  LMRequestResult.m
//  lmps-driver
//
//  Created on 17/4/9.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import "LMRequestResult.h"
#import "NSURLRequest+LMNetwork.h"

NSString * const LMNetworkResponseErrorKey = @"com.sl.error.response";

@interface LMRequestError ()

@property (nonatomic, copy) NSString *message;

@end

@implementation LMRequestError

- (instancetype)initWithMessage:(NSString *)message code:(NSInteger)code {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    self = [super initWithDomain:LMNetworkResponseErrorKey code:code userInfo:userInfo];
    if (self) {
        _message = message;
    }
    return self;
}

+ (LMRequestError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    return [[self alloc] initWithMessage:message code:code];
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"code:%zd, message:%@", self.code, self.message];
}

@end


@interface LMRequestResult ()

@property (nonatomic, strong) NSNumber *requestId;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSDictionary *requestParams;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSDictionary *responseDic;
@property (nonatomic, strong) NSDictionary *headerDic;

@property (nonatomic, strong) LMRequestError *error;

@end

@implementation LMRequestResult

+ (instancetype)resultWithRequestId:(NSNumber *)requestId request:(NSURLRequest *)request data:(NSData *)data dic:(NSDictionary *)dic headerDic:(NSDictionary *)headerDic error:(LMRequestError *)error {
    LMRequestResult *result = [LMRequestResult new];
    result.error = error;
    result.request = request;
    result.requestParams = request.lm_requestParams;
    result.requestId = requestId;
    result.responseData = data;
    result.responseDic = dic;
    result.headerDic = headerDic;
    
    return result;
}

- (void)updateErrorInfo:(LMRequestError *)error {
    _error = error;
}

@end
