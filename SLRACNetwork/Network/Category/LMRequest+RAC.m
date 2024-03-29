//
//  LMRequest+RAC.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/19.
//  Copyright © 2020 sl. All rights reserved.
//

#import "LMRequest+RAC.h"
#import <objc/runtime.h>

@implementation LMRequest (RAC)

- (RACSubject *)successSubject {
    RACSubject *successSubject = objc_getAssociatedObject(self, @selector(successSubject));
    if (successSubject == nil) {
        successSubject = [RACSubject subject];
        @weakify(self);
        [[[[self rac_signalForSelector:@selector(lm_didProcessResult:)] map:^id(RACTuple *tuple) {
            // 这里的tuple是方法的参数数组 只需要第一个就好了
            return tuple.first;
        }] deliverOnMainThread] subscribeNext:^(LMRequestResult *result) {
            @strongify(self);
            if (result.error == nil) {
                [self.successSubject sendNext:result];
            }
        }];
        objc_setAssociatedObject(self, @selector(successSubject), successSubject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return successSubject;
}

- (RACSubject *)errorSubject {
    RACSubject *errorSubject = objc_getAssociatedObject(self, @selector(errorSubject));
    if (errorSubject == nil) {
        errorSubject = [RACSubject subject];
        @weakify(self);
        [[[[self rac_signalForSelector:@selector(lm_didProcessResult:)] map:^id(RACTuple *tuple) {
            return tuple.first;
        }] deliverOnMainThread] subscribeNext:^(LMRequestResult *result) {
            @strongify(self);
            if (result.error != nil) {
                [self.errorSubject sendNext:result.error];
            }
        }];
        objc_setAssociatedObject(self, @selector(errorSubject), errorSubject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return errorSubject;
}

- (RACSignal *)errorSignal {
    return self.errorSubject;
}

- (RACSignal *)successSignal {
    return self.successSubject;
}

- (RACSignal *)requestFinishSignal {
    RACSignal *requestFinishSignal = objc_getAssociatedObject(self, @selector(requestFinishSignal));
    if (requestFinishSignal == nil) {
        RACSignal *successSignal = [self.successSignal mapReplace:@YES];
        RACSignal *errorSignal = [self.errorSignal mapReplace:@NO];
        requestFinishSignal = [RACSignal merge:@[successSignal, errorSignal]];
        objc_setAssociatedObject(self, @selector(requestFinishSignal), requestFinishSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requestFinishSignal;
}

@end

@implementation LMListRequest (RAC)

- (RACSignal *)mapSuccessSignal {
    RACSignal *mapSuccessSignal = objc_getAssociatedObject(self, @selector(mapSuccessSignal));
    if (mapSuccessSignal == nil) {
        @weakify(self);
        mapSuccessSignal = [self.successSubject map:^id _Nullable(id  _Nullable value) {
            @strongify(self);
            return @(self.isRefresh);
        }];
        objc_setAssociatedObject(self, @selector(mapSuccessSignal), mapSuccessSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mapSuccessSignal;
}

- (RACSignal *)successSignal {
    return self.mapSuccessSignal;
}

@end
