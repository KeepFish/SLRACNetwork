//
//  NSURLRequest+LMRequest.m
//  lmps-driver
//
//  Created on 17/4/8.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import "NSURLRequest+LMNetwork.h"
#import <objc/runtime.h>

@implementation NSURLRequest (LMNetwork)

- (void)setLm_requestParams:(NSDictionary *)lm_requestParams {
    objc_setAssociatedObject(self, @selector(lm_requestParams), lm_requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)lm_requestParams {
    return objc_getAssociatedObject(self, @selector(lm_requestParams));
}

@end
