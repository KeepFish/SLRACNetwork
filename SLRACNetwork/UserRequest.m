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
    UserRequest *request = [self requestWithPath:@""];
    
    return request;
}

+ (instancetype)requestForUpdateUserInfo {
    UserRequest *request = [self requestWithPath:@""];
    request.showLoading = NO;
    
    return request;
}

@end
