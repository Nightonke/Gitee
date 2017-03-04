//
//  VHUtils+TransForm.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils.h"
#import "VHNotification.h"

@interface VHUtils (TransForm)

+ (NSImage *)imageFromGithubContentType:(VHGithubContentType)type;

+ (NSColor *)colorFromHexColorCodeInString:(NSString *)string;

+ (NSString *)hexadecimalValueFromColor:(NSColor *)color;

+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

+ (NSDate *)dateFromGithubTimeString:(NSString *)timeString;

+ (VHNotificationReasonType)notificationReasonTypeFromString:(NSString *)string;

+ (NSString *)timeStringToNowFromTime:(NSDate *)time;

+ (VHNotificationType)notificationTypeFromString:(NSString *)string;

+ (NSImage *)imageFromNotificationType:(VHNotificationType)type;

+ (NSString *)githubTimeStringFromDate:(NSDate *)date;

@end
