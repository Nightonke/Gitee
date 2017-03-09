//
//  VHUtils.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifier-Bridging-Header.h"

@interface VHUtils : NSObject

+ (BOOL)isDarkMode;

+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;

+ (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font;

+ (BOOL)point:(CGPoint)point notOutOfRect:(CGRect)rect;

+ (void)setRandomColor:(ChartDataSet *)chartDataSet withNumber:(NSInteger)count;

+ (NSColor *)randomColor;

+ (NSColor *)trendColor:(NSColor *)color withCount:(NSUInteger)count withRow:(NSUInteger)row;

+ (NSTextField *)labelWithFrame:(NSRect)frame;

+ (void)openUrl:(NSString *)url;

+ (void)openURL:(NSURL *)url;

+ (void)resetWKWebViewExceptCookie;

+ (void)resetWKWebView;

+ (void)scrollViewToTop:(NSScrollView *)scrollView;

+ (NSArray<NSColor *> *)randomColors;

@end
