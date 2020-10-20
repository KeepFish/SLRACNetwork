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

@interface LMRequest (RAC)

@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, strong, readonly) RACCommand *cancelCommand;
@property (nonatomic, strong, readonly) RACSignal *requestErrorSignal; //已为主线程
@property (nonatomic, strong, readonly) RACSignal *executionSignal;
@property (nonatomic, strong, readonly) RACSignal *requestDoneSignal;

@end

@interface LMListRequest (RAC)

@property (nonatomic, strong, readonly) RACCommand *refreshCommand;
@property (nonatomic, strong, readonly) RACCommand *requestNextPageCommand;

@end
