//
//  ViewModel.h
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/22.
//  Copyright © 2020 sl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "UserRequest.h"

@interface ViewModel : NSObject

@property (nonatomic, strong) UserModel *model;
@property (nonatomic, strong) UserRequest *userInfoRequest;
@property (nonatomic, strong) UserRequest *updateUserInfoRequest;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
