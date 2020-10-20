//
//  NSURLRequest+LMRequest.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import "NSURLRequest+LMRequest.h"
#import <objc/runtime.h>

@implementation NSURLRequest (LMRequest)

- (void)setLm_requestParams:(NSDictionary *)lm_requestParams {
    objc_setAssociatedObject(self, @selector(lm_requestParams), lm_requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)lm_requestParams {
    return objc_getAssociatedObject(self, @selector(lm_requestParams));
}

@end
