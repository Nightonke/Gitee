//
//  NSColor+Utils.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSColor+Utils.h"

@implementation NSColor (Utils)

- (NSColor *)lighterColor
{
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return [NSColor colorWithHue:h
                      saturation:s
                      brightness:MIN(b * 1.3, 1.0)
                           alpha:a];
    return nil;
}

- (NSColor *)darkerColor
{
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return [NSColor colorWithHue:h
                      saturation:s
                      brightness:b * 0.75
                           alpha:a];
    return nil;
}

@end
