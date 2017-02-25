//
//  NSDate+Utils.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/16.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSDate *)dateOfDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear |
                                                                             NSCalendarUnitMonth |
                                                                             NSCalendarUnitDay |
                                                                             NSCalendarUnitHour |
                                                                             NSCalendarUnitMinute |
                                                                             NSCalendarUnitSecond)
                                                                   fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (BOOL)isSameDayAsDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

- (BOOL)isSameWeekAsDate:(NSDate *)date byWeekStartFrom:(VHGithubWeekStartFrom)from
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:from];
    
    unsigned unitFlags = NSCalendarUnitYearForWeekOfYear | NSCalendarUnitWeekOfYear;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 yearForWeekOfYear] == [comp2 yearForWeekOfYear] && [comp1 weekOfYear] == [comp2 weekOfYear];
}

- (BOOL)isSameMonthAsDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

- (BOOL)isSameYearAsDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 year]  == [comp2 year];
}

- (NSDate *)toLocalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

- (NSDate *)toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

@end
