//
//  VHGithubNotifierManager+Trend.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import <WebKit/WebKit.h>

@interface VHGithubNotifierManager (Trend)

- (void)innerInitializePropertiesForTrend;

- (void)updateTrendData;

- (RLMResults *)trendDatas;

- (BOOL)loadTrendChartInWebView:(WKWebView *)webView withTrendContentIndex:(NSUInteger)contentIndex withTitle:(NSString *)title;

@end
