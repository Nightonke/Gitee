//
//  VHUtils.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils.h"

@implementation VHUtils

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

+ (BOOL)CGPoint:(CGPoint)point notOutOfRect:(CGRect)rect
{
    return rect.origin.x <= point.x && point.x <= rect.origin.x + rect.size.width && rect.origin.y <= point.y && point.y <= rect.origin.y + rect.size.height;
}

+ (void)setRandomColor:(ChartDataSet *)chartDataSet withNumber:(NSInteger)count
{
    NSMutableArray<NSColor *> *colors = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
        [colors addObject:[VHUtils randomColor]];
    }
    [chartDataSet setColors:[colors copy]];
}

+ (NSColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
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
    MUST_IN_MAIN_THREAD;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    NOTIFICATION_POST(kNotifyWindowShouldHide);
}

@end
