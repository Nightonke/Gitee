//
//  VHUtils+TransForm.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils+TransForm.h"

@implementation VHUtils (TransForm)

+ (NSImage *)imageFromGithubContentType:(VHGithubContentType)type
{
    switch (type)
    {
        case VHGithubContentTypeProfile: return [NSImage imageNamed:@"icon_profile"];
        case VHGithubContentTypeRepositoryPie: return [NSImage imageNamed:@"icon_repository_pie"];
        case VHGithubContentTypeTrend: return [NSImage imageNamed:@"icon_trend"];
        case VHGithubContentTypeTrending: return [NSImage imageNamed:@"icon_trending"];
        case VHGithubContentTypeNotifications: return [NSImage imageNamed:@"icon_notification"];
        case VHGithubContentTypeSettings: return [NSImage imageNamed:@"icon_settings"];
        default:
            NSAssert(NO, @"Unknown VHGithubContentType");
            break;
    }
    return [NSImage imageNamed:@"icon_github"];
}

+ (NSColor *)colorFromHexColorCodeInString:(NSString *)string
{
    NSString *colorString = [string copy];
    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != string)
    {
        NSScanner* scanner = [NSScanner scannerWithString:colorString];
        [scanner scanHexInt:&colorCode];
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode);
    
    result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff
                                       green:(CGFloat)greenByte / 0xff
                                        blue:(CGFloat)blueByte / 0xff
                                       alpha:1.0];
    return result;
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)input
{
    return [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
