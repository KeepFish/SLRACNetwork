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

- (RACSignal *)requestSignal {
    @weakify(self);
    RACSignal *requestSignal = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        RACSignal *finishSignal = [self rac_signalForSelector:@selector(lm_didProcessResult:)];
        [[finishSignal map:^id(RACTuple *tuple) {
            // 这里的tuple是方法的参数数组 只需要第一个就好了
            return tuple.first;
        }] subscribeNext:^(LMRequestResult *result) {
            if (result.error == nil) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:result.error];
            }
        }];
        return nil;
    }] replayLazily] takeUntil:self.rac_willDeallocSignal];
    
    return requestSignal;
}

- (RACCommand *)requestCommand {
    RACCommand *requestCommand = objc_getAssociatedObject(self, @selector(requestCommand));
    if (requestCommand == nil) {
        @weakify(self);
        requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self load];
            return [self.requestSignal takeUntil:self.cancelCommand.executionSignals];
        }];
        objc_setAssociatedObject(self, @selector(requestCommand), requestCommand, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requestCommand;
}

- (RACCommand *)cancelCommand {
    RACCommand *cancelCommand = objc_getAssociatedObject(self, @selector(cancelCommand));
    if (cancelCommand == nil) {
        @weakify(self);
        cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self cancel];
            return [RACSignal empty];
        }];
        objc_setAssociatedObject(self, @selector(cancelCommand), cancelCommand, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cancelCommand;
}

- (RACSignal *)requestErrorSignal {
    return [self.requestCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)executionSignal {
    return [self.requestCommand.executionSignals switchToLatest];
}

- (RACSignal *)requestDoneSignal {
    RACSignal *successSignal = [self.executionSignal mapReplace:@YES];
    RACSignal *errorSignal = [self.requestErrorSignal mapReplace:@NO];
    
    return [RACSignal merge:@[successSignal, errorSignal]];
}

@end


@implementation LMListRequest (RAC)

- (RACCommand *)requestCommand {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@ requestCommand error",[self class]]
                                   reason:@"Don't call this Method. Call  refreshCommand or requestNextPageCommand instead."
                                 userInfo:nil];
}

- (RACCommand *)refreshCommand {
    RACCommand *refreshCommand = objc_getAssociatedObject(self, @selector(refreshCommand));
    if (refreshCommand == nil) {
        @weakify(self);
        refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self reset];
            [self loadNextPage];
            return self.requestSignal;
        }];
        objc_setAssociatedObject(self, @selector(refreshCommand), refreshCommand, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return refreshCommand;
}

- (RACCommand *)requestNextPageCommand {
    RACCommand *requestNextPageCommand = objc_getAssociatedObject(self, @selector(requestNextPageCommand));
    if (requestNextPageCommand == nil) {
        @weakify(self);
        requestNextPageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self loadNextPage];
            return self.requestSignal;
        }];
        objc_setAssociatedObject(self, @selector(requestNextPageCommand), requestNextPageCommand, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requestNextPageCommand;
}

- (RACSignal *)requestErrorSignal {
    return [[RACSignal merge:@[self.refreshCommand.errors, self.requestNextPageCommand.errors]] subscribeOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)executionSignal {
    RACSignal *refreshExecutionSignal = [[self.refreshCommand.executionSignals switchToLatest] mapReplace:@YES];
    RACSignal *requestNextPageExecutionSignal = [[self.requestNextPageCommand.executionSignals switchToLatest] mapReplace:@NO];
    return [RACSignal merge:@[refreshExecutionSignal, requestNextPageExecutionSignal]];
}

@end

