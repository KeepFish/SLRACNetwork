//
//  ListViewModel.h
//  SLRACNetwork
//
//  Created by 孙立 on 2020/10/20.
//  Copyright © 2020 sl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMRequest+RAC.h"

@interface ListViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) LMListRequest *listRequest;

@end
