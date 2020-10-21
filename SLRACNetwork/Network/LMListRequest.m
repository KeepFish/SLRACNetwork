//
//  LMListRequest.m
//  lmps-driver
//
//  Created on 17/4/9.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import "LMListRequest.h"

static const NSInteger LMPageNetworkStartPage = 0;
static const NSInteger LMPageNetworkDefaultPageSize = 15;

@interface LMListRequest()

@property (nonatomic, assign, readwrite) NSInteger currentPage;
@property (nonatomic, assign, readwrite) NSInteger maxPage;

@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation LMListRequest

+ (instancetype)requestWithPath:(NSString *)path {
    return [self requestWithPath:path type:LMRequestTypeGet];
}

+ (instancetype)requestWithPath:(NSString *)path type:(LMRequestType)type {
    LMListRequest *request = [super requestWithPath:path type:type];
    request.showLoading = NO;
    request.pageSize = LMPageNetworkDefaultPageSize;
    request.currentPage = LMPageNetworkStartPage;
    return request;
}

- (NSInteger)refresh {
    return [self loadPage:LMPageNetworkStartPage];
}

- (NSInteger)loadPage:(NSInteger)page {
    self.currentPage = page;
    return [self _load];
}

- (NSInteger)loadNextPage {
    return [self _load];
}

- (NSInteger)_load {
    if (self.isLoading) {
        return LMListRequestIsLoading;
    }
    self.isRefresh = self.currentPage == LMPageNetworkStartPage;
    return [super load];
}

#pragma mark - 重载方法
- (NSInteger)load {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@ load error",[self class]]
                                   reason:@"You should not call this method directly. Call loadNextPage instead."
                                 userInfo:nil];
}

- (BOOL)lm_willLoadWithParams:(NSDictionary *__autoreleasing *)params {
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:*params];
    finalParams[@"page"] = @(self.currentPage + 1);
    finalParams[@"pageSize"] = @(self.pageSize);
    *params = finalParams;
    return [super lm_willLoadWithParams:params];
}

- (void)lm_didProcessResult:(LMRequestResult *)result {
    [self updatePageInfo:result];
    [super lm_didProcessResult:result];
}

- (void)updatePageInfo:(LMRequestResult *)result {
    if (result.error) {
        self.currentPage--;
    } else {
        NSDictionary *headerDic = result.headerDic;
        self.currentPage = [headerDic[@"X-Page-CurrentPage"] intValue];
        self.pageSize = [headerDic[@"X-Page-PerPage"] intValue];
        self.maxPage = (NSInteger)ceil([headerDic[@"X-Page-TotalCount"] doubleValue] / self.pageSize);
    }
}

#pragma mark - Getter & Setter
- (void)setPageSize:(NSInteger)pageSize {
    _pageSize = (pageSize <= 0 ? LMPageNetworkDefaultPageSize : pageSize);
}

- (BOOL)hasNextPage {
    return self.currentPage < self.maxPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    NSInteger page = currentPage;
    if (page < 0) {
        page = 0;
    } else {
        page = page > self.maxPage ? self.maxPage : page;
    }
    _currentPage = page;
}

@end
