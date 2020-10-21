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

// 订阅返回LMError
@property (nonatomic, strong, readonly) RACSignal *errorSignal;
// 订阅返回LMResult
@property (nonatomic, strong, readonly) RACSignal *successSignal;
// 请求成功YES 失败NO
@property (nonatomic, strong, readonly) RACSignal *requestFinishSignal;

@end
