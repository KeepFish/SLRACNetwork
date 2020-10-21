//
//  UITableView+Lmps.m
//  lmps-driver
//
//  Created on 2017/5/9.
//  Copyright © 2017年 Come56. All rights reserved.
//


#import "UITableView+Lmps.h"
#import <objc/runtime.h>
#import "LMRequest+RAC.h"
#import <MJRefresh.h>

#pragma mark - Private Method
@interface UITableView (LmpsPrivate)

@property (nonatomic, assign) BOOL isRequestDone;
@property (nonatomic, strong, readonly) NSMutableArray<RACDisposable *> *requestDisposables;

@end

@implementation UITableView (LmpsPrivate)

- (NSMutableArray<RACDisposable *> *)requestDisposables {
    NSMutableArray *requestDisposables = objc_getAssociatedObject(self, @selector(requestDisposables));
    if (requestDisposables == nil) {
        requestDisposables = [NSMutableArray arrayWithCapacity:2];
        objc_setAssociatedObject(self, @selector(requestDisposables), requestDisposables, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requestDisposables;
}

- (BOOL)isRequestDone {
    return [objc_getAssociatedObject(self, @selector(isRequestDone)) boolValue];
}

- (void)setIsRequestDone:(BOOL)isRequestDone {
    objc_setAssociatedObject(self, @selector(isRequestDone), @(isRequestDone), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - Public Method
@implementation UITableView (Lmps)

+ (instancetype)lm_tableViewWithStyle:(UITableViewStyle)style {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    tableView.estimatedRowHeight = 44.f;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, 1.f)];
    
    return tableView;
}

#pragma mark - MJRefresh binding
- (void)lm_bindRefreshingWithPageRequest:(LMListRequest *)request {
    [self lm_bindRefreshingWithPageRequest:request autoChangeStatus:YES];
}

- (void)lm_bindRefreshingWithPageRequest:(LMListRequest *)request autoChangeStatus:(BOOL)autoChange {
    @weakify(self, request);
    // refresh header
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self, request);
        self.isRequestDone = NO;
        [request refresh];
        
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header = header;
    
    // refresh footer
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self, request);
        self.isRequestDone = NO;
        [request loadNextPage];
    }];
    self.mj_footer = footer;
    
    if (autoChange) {
        NSMutableArray *disposables = self.requestDisposables;
        // 移除先前订阅的信号
        [disposables enumerateObjectsUsingBlock:^(RACDisposable *disposable, NSUInteger idx, BOOL * _Nonnull stop) {
            [disposable dispose];
        }];
        [disposables removeAllObjects];
        
        // 请求成功后，设置refresh控件的状态以及reloadData
        [disposables addObject:[request.successSignal subscribeNext:^(NSNumber *isRefresh) {
            @strongify(self, request);
            if (self) {
                self.isRequestDone = YES;
                
                if ([isRefresh boolValue]) {
                    [self.mj_header endRefreshing];
                }
                request.hasNextPage ? [self.mj_footer endRefreshing] : [self.mj_footer endRefreshingWithNoMoreData];
            }
        }]];
        
        // 请求失败时，重置refresh控件的状态
        [disposables addObject:[request.errorSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (self) {
                self.isRequestDone = YES;
                [self.mj_header endRefreshing];
                [self.mj_footer endRefreshing];
            }
        }]];
    }
}

- (BOOL)isRefreshing {
    return !self.isRequestDone;
}

- (void)headerBeginRefreshing {
    [self.mj_header beginRefreshing];
}

- (void)footerBeginRefreshing {
    [self.mj_footer beginRefreshing];
}

@end
