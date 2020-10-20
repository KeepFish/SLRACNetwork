//
//  UserRequest.m
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import "UserRequest.h"

@implementation UserRequest

+ (instancetype)requestForGetUserInfo {
    UserRequest *request = [self requestWithPath:@"Driver/Driver/getinfo"];
    request.showLoading = NO;
    request.showErrorMessage = NO;
    
    return request;
}

+ (instancetype)requestForUpdateUserInfo {
    UserRequest *request = [self requestWithPath:@"Driver/Driver/updateavatar"];
    request.showLoading = NO;
    
    return request;
}

@end
