//
//  UserRequest.h
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import "LMRequest+RAC.h"

@interface UserRequest : LMRequest

+ (instancetype)requestForGetUserInfo;

+ (instancetype)requestForUpdateUserInfo;


@end
