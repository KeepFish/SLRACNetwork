//
//  UITableView+Lmps.h
//  lmps-driver
//
//  Created Liu on 2017/2/9.
//  Copyright © 2017年 Come56. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMListRequest;

@interface UITableView (Lmps)

@property (nonatomic, assign, readonly) BOOL isRefreshing;

+ (instancetype)lm_tableViewWithStyle:(UITableViewStyle)style;

- (void)lm_bindRefreshingWithListRequest:(LMListRequest *)request;
// 是否自动改变header footer的刷新状态
- (void)lm_bindRefreshingWithListRequest:(LMListRequest *)request autoChangeStatus:(BOOL)subscribing;

- (void)headerBeginRefreshing;
- (void)footerBeginRefreshing;

@end
