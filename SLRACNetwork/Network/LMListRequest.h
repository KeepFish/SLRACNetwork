//
//  LMListRequest.h
//  lmps-driver
//
//  Created on 17/4/9.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import "LMRequest.h"

static const NSInteger LMListRequestIsLoading = NSIntegerMax;

@interface LMListRequest : LMRequest

@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, assign, readonly) NSInteger maxPage;
@property (nonatomic, assign, readonly) BOOL hasNextPage;

// 是否是刷新
@property (nonatomic, assign, readonly) BOOL isRefresh;

- (NSInteger)refresh;
- (NSInteger)loadNextPage;
- (NSInteger)loadPage:(NSInteger)page;

@end
