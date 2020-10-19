//
//  LMRequestProxy.h
//  lmps-driver
//
//  Created on 17/4/8.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMRequestResult.h"

typedef void(^LMNetworkFinishedBlock)(LMRequestResult *result);

@interface LMRequestProxy : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isReachable;

- (NSInteger)loadRequest:(NSURLRequest *)request finished:(LMNetworkFinishedBlock)finished;

- (void)cancelRequestWithRequestId:(NSNumber *)requestId;
- (void)cancelRequestWithRequestIdList:(NSArray *)requestIdList;

@end

@interface LMRequestProxy(LMRequestGenerator)

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                               path:(NSString *)path
                             params:(NSDictionary *)params;

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                            baseUrl:(NSString *)baseUrl
                               path:(NSString *)path
                             params:(NSDictionary *)params;
@end
