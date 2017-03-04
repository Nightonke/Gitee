//
//  VHUtils+TransForm.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils+TransForm.h"
#import "NSDate+Utils.h"

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

+ (NSString *)hexadecimalValueFromColor:(NSColor *)color
{
    
    double redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    NSColor *convertedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if(convertedColor) {
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
        
        redIntValue = redFloatValue*255.99999f;
        greenIntValue = greenFloatValue*255.99999f;
        blueIntValue = blueFloatValue*255.99999f;
        
        redHexValue = [NSString stringWithFormat:@"%02x", redIntValue];
        greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue = [NSString stringWithFormat:@"%02x", blueIntValue];
        
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    
    return nil;
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)input
{
    return [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSDate *)dateFromGithubTimeString:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'Z'"];
    return [[dateFormatter dateFromString:timeString] toLocalTime];
}

+ (VHNotificationReasonType)notificationReasonTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"assign"])
    {
        return VHNotificationReasonTypeAssign;
    }
    else if ([string isEqualToString:@"author"])
    {
        return VHNotificationReasonTypeAuthor;
    }
    else if ([string isEqualToString:@"comment"])
    {
        return VHNotificationReasonTypeComment;
    }
    else if ([string isEqualToString:@"invitation"])
    {
        return VHNotificationReasonTypeInvitation;
    }
    else if ([string isEqualToString:@"manual"])
    {
        return VHNotificationReasonTypeManual;
    }
    else if ([string isEqualToString:@"mention"])
    {
        return VHNotificationReasonTypeMention;
    }
    else if ([string isEqualToString:@"state_change"])
    {
        return VHNotificationReasonTypeStateChange;
    }
    else if ([string isEqualToString:@"subscribed"])
    {
        return VHNotificationReasonTypeSubscribed;
    }
    else if ([string isEqualToString:@"team_mention"])
    {
        return VHNotificationReasonTypeTeamMention;
    }
    else
    {
        return VHNotificationReasonTypeUnknown;
    }
}

+ (NSString *)timeStringToNowFromTime:(NSDate *)time
{
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:time];
    if (secondsBetween <= 0)
    {
        return @"Now";
    }
    else if (secondsBetween <= 1)
    {
        return @"a second ago";
    }
    else if (secondsBetween < 60)
    {
        return [NSString stringWithFormat:@"%.0lf seconds ago", secondsBetween];
    }
    else if (secondsBetween < 60 * 2)
    {
        return @"a minute ago";
    }
    else if (secondsBetween < 60 * 60)
    {
        return [NSString stringWithFormat:@"%.0lf minutes ago", secondsBetween / 60];
    }
    else if (secondsBetween < 60 * 60 * 2)
    {
        return @"an hour ago";
    }
    else if (secondsBetween < 60 * 60 * 23)
    {
        return [NSString stringWithFormat:@"%.0lf hours ago", secondsBetween / (60 * 60)];
    }
    else if (secondsBetween < 60 * 60 * 24 * 2)
    {
        return @"a day ago";
    }
    else if (secondsBetween < 60 * 60 * 24 * 30)
    {
        return [NSString stringWithFormat:@"%.0lf days ago", secondsBetween / (60 * 60 * 24)];
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"'on' dd MMM yyyy"];
        return [dateFormatter stringFromDate:time];
    }
}

+ (VHNotificationType)notificationTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"Issue"])
    {
        return VHNotificationTypeIssue;
    }
    else if ([string isEqualToString:@"PullRequest"])
    {
        return VHNotificationTypePullRequest;
    }
    else
    {
        return VHNotificationTypeUnknown;
    }
}

+ (NSImage *)imageFromNotificationType:(VHNotificationType)type
{
    switch (type)
    {
        case VHNotificationTypeIssue:
            return [NSImage imageNamed:@"image_issue"];
        case VHNotificationTypePullRequest:
            return [NSImage imageNamed:@"image_pull_request"];
        default:
            return [NSImage imageNamed:@"image_notification"];
    }
}

+ (NSString *)githubTimeStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return [dateFormatter stringFromDate:date];
}

@end
