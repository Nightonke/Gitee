//
//  VHUtils.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils.h"
#import "VHUtils+TransForm.h"
#import <WebKit/WebKit.h>

static NSArray<NSString *> *colorStrings = nil;
static NSArray<NSColor *> *colors = nil;

@implementation VHUtils

#pragma mark - Public Methods

+ (BOOL)isDarkMode
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    return (style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"]);
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}

+ (BOOL)point:(CGPoint)point notOutOfRect:(CGRect)rect
{
    return rect.origin.x <= point.x && point.x <= rect.origin.x + rect.size.width && rect.origin.y <= point.y && point.y <= rect.origin.y + rect.size.height;
}

+ (void)setRandomColor:(ChartDataSet *)chartDataSet withNumber:(NSInteger)count
{
    [chartDataSet setColors:[VHUtils colors]];
}

+ (NSColor *)randomColor
{
    return [[VHUtils colors] objectAtIndex:arc4random() % [VHUtils colors].count];
}

+ (NSColor *)trendColor:(NSColor *)color withCount:(NSUInteger)count withRow:(NSUInteger)row;
{
    if (count == 1)
    {
        return color;
    }
    return [color colorWithAlphaComponent:1 - row * 0.5 / (count - 1)];
}

+ (NSTextField *)labelWithFrame:(NSRect)frame
{
    NSTextField *text = [[NSTextField alloc] initWithFrame:frame];
    [text setBezeled:NO];
    [text setDrawsBackground:NO];
    [text setEditable:NO];
    [text setSelectable:NO];
    return text;
}

+ (void)openUrl:(NSString *)url
{
    if ([url length] == 0)
    {
        return;
    }
    MUST_IN_MAIN_THREAD;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    NOTIFICATION_POST(kNotifyWindowShouldHide);
}

+ (void)resetWKWebView
{
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}

+ (void)scrollViewToTop:(NSScrollView *)scrollView
{
    if ([scrollView hasVerticalScroller]) {
        scrollView.verticalScroller.floatValue = 0;
    }
    [scrollView.documentView scrollPoint:NSMakePoint(0, 0)];
}

#pragma mark - Private methods

+ (NSArray<NSString *> *)colorStrings
{
    if (colorStrings == nil)
    {
        colorStrings = @[@"#F44336",
                         @"#3F51B5",
                         @"#673AB7",
                         @"#E91E63",
                         @"#9C27B0",
                         @"#03A9F4",
                         @"#009688",
                         @"#4CAF50",
                         @"#00BCD4",
                         @"#2196F3",
                         @"#CDDC39",
                         @"#009688",
                         @"#8BC34A",
                         @"#FF9800",
                         @"#FFEB3B",
                         @"#795548",
                         @"#FFC107",
                         @"#9E9E9E",
                         @"#FF5722",
                         @"#607D8B"];
    }
    return colorStrings;
}

+ (NSArray<NSColor *> *)colors
{
    if (colors == nil)
    {
        NSMutableArray<NSColor *> *mColors = [NSMutableArray arrayWithCapacity:[VHUtils colorStrings].count];
        for (NSString *colorString in colorStrings)
        {
            [mColors addObject:[VHUtils colorFromHexColorCodeInString:colorString]];
        }
        colors = [mColors copy];
    }
    return colors;
}

@end
