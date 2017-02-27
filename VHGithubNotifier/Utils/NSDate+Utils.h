//
//  NSDate+Utils.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/16.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface NSDate (Utils)

- (NSDate *)dateOfDay;

- (BOOL)isSameDayAsDate:(NSDate *)date;

- (BOOL)isSameWeekAsDate:(NSDate *)date byWeekStartFrom:(VHGithubWeekStartFrom)from;

- (BOOL)isSameMonthAsDate:(NSDate *)date;

- (BOOL)isSameYearAsDate:(NSDate *)date;

- (NSDate *)toLocalTime;

- (NSDate *)toGlobalTime;

@end
