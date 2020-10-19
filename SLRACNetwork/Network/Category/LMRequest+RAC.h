//
//  LMRequest+RAC.h
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/19.
//  Copyright © 2020 sl. All rights reserved.
//

#import "LMRequest.h"
#import "LMListRequest.h"
#import <ReactiveObjC.h>

@protocol LMRequestRacOperationProtocal <NSObject>

- (RACCommand *)requestCommand;
- (RACCommand *)cancelCommand;
- (RACSignal *)requestErrorSignal;
- (RACSignal *)executionSignal;

@end


@protocol LMListRequestRacOperationProtocal <NSObject>

- (RACCommand *)refreshCommand;
- (RACCommand *)requestNextPageCommand;

@end


@interface LMRequest (RAC) <LMRequestRacOperationProtocal>

@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, strong, readonly) RACCommand *cancelCommand;
@property (nonatomic, strong, readonly) RACSignal *requestErrorSignal; //已为主线程
@property (nonatomic, strong, readonly) RACSignal *executionSignal;
@property (nonatomic, strong, readonly) RACSignal *requestDoneSignal;

@end

@interface LMListRequest (RAC) <LMListRequestRacOperationProtocal>

@property (nonatomic, strong, readonly) RACCommand *refreshCommand;
@property (nonatomic, strong, readonly) RACCommand *requestNextPageCommand;

@end
