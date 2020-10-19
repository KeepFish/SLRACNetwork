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

@end

@implementation LMListRequest

+ (instancetype)createRequestWithPath:(NSString *)path type:(LMRequestType)type {
    LMListRequest *request = [super requestWithPath:path type:type];
    request.showLoading = NO;
    request.pageSize = LMPageNetworkDefaultPageSize;
    request.currentPage = LMPageNetworkStartPage;
    return request;
}

#pragma mark - 逻辑处理
- (void)reset {
    [self resetToPage:LMPageNetworkStartPage];
}

- (void)resetToPage:(NSInteger)page {
    page = page > self.maxPage ? self.maxPage : page;
    self.currentPage = page;
}

- (NSInteger)loadNextPage {
    if (self.isLoading) {
        return LMListRequestIsLoading;
    }
    return [super load];
}

#pragma mark - 重载方法
- (NSInteger)load {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@ load error",[self class]]
                                   reason:@"You should not call this method directly. Call loadNextPage instead."
                                 userInfo:nil];
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:params];
    finalParams[@"page"] = @(self.currentPage + 1);
    finalParams[@"per_page"] = @(self.pageSize);
    return finalParams;
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

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = MAX(LMPageNetworkStartPage, currentPage);
}

- (BOOL)hasNextPage {
    return self.currentPage < self.maxPage;
}

@end
