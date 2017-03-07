//
//  VHTrendChartParser.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendChartParser.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+UserDefault.h"

static const NSUInteger chartWidth = 390;
static const NSUInteger chartHeight = 460;
static const NSUInteger marginTop = 130;
static const NSUInteger titleFontSize = 14;
static const NSUInteger barNumberAtFirst = 20;
static NSUInteger colorIndex = 0;
static NSArray<NSString *> *colors = nil;

@implementation VHTrendChartParser

+ (NSString *)chartHtmlContentWithTitle:(NSString *)title withRecords:(NSArray<VHRecord *> *)records withYValueName:(NSString *)yValueName
{
    NSUInteger startValue = MAX(records.count - barNumberAtFirst, 0);
    NSUInteger endValue = records.count;
    NSUInteger minValue = INT_MAX;
    for (VHRecord *record in records)
    {
        minValue = MIN(minValue, record.number);
    }
    minValue = MAX(0, [records firstObject].number / 10 * 10 - 10);
    
    NSMutableString *htmlContent = [NSMutableString stringWithString:@"<!DOCTYPE html><html><head><meta charset=\"utf-8\"><script src=\"echarts.js\"></script></head><body><div id=\"main\" style=\"width: "];
    
    [htmlContent appendString:[NSString stringWithFormat:@"%zdpx;height:%zdpx;", chartWidth, chartHeight]];
    [htmlContent appendString:[NSString stringWithFormat:@"margin-top:%zdpx;\"></div><script type=\"text/javascript\">var myChart=echarts.init(document.getElementById(\'main\'));option=null;option={title:{text:\"", marginTop]];
    
    [htmlContent appendString:[NSString stringWithFormat:@"%@\",textStyle:{fontWeight:\'lighter\',fontFamily:\'sans-serif\',fontSize:", title]];
    
    [htmlContent appendString:[NSString stringWithFormat:@"%zd,},subtextStyle:{fontSize:0,},itemGap:0,},tooltip : {textStyle:{fontWeight:\'lighter\'},trigger: \'item\'},toolbox:{show:true,feature:{magicType:{show:true,type:[\'line\', \'bar\'],title:[\'\', \'\'],iconStyle:{normal:{color:\'#03A9F4\',borderColor:\'#03A9F4\'},emphasis:{color:\'#03A9F4\',borderColor:\'#03A9F4\'}}},},right: 20},calculable : true,legend: {show: false,},grid: {top: \'8%%\',left: \'1%%\',right: \'10%%\',containLabel: true},yAxis: [{axisLabel:{textStyle:{fontWeight:'lighter'}},type : \'value\',min : %zd,max : \'dataMax\'}],dataZoom: [{type: \'inside\',startValue: ", titleFontSize, minValue]];
    
    [htmlContent appendString:[NSString stringWithFormat:@"%zd,endValue:", startValue]];
    [htmlContent appendString:[NSString stringWithFormat:@"%zd,},{type: \'slider\',show: true,startValue: ", endValue - 1]];
    [htmlContent appendString:[NSString stringWithFormat:@"%zd,endValue:", startValue]];
    [htmlContent appendString:[NSString stringWithFormat:@"%zd,filterMode: \'filter\',borderColor:\'rgba(0,0,0,0)\',fillerColor:\'rgba(3,169,244,0.2)\',dataBackground:{lineStyle: {color:\'#03A9F4\'},areaStyle:{color:\'#03A9F4\'}},handleStyle:{color:\'rgba(3,169,244,1)\'},textStyle:{fontWeight: \'lighter\'},left:'25'}],xAxis: [{axisLabel:{textStyle:{fontWeight:\'lighter\'}},axisTick: {alignWithLabel: true},type : \'category\',boundaryGap: true,data : [", endValue]];
    
    for (VHRecord *record in records)
    {
        [htmlContent appendString:[NSString stringWithFormat:@"\"%@\",", [VHTrendChartParser dateTextFromRecord:record]]];
    }
    
    [htmlContent appendString:[NSString stringWithFormat:@"]}],series : [{color: [\'%@", [self chartBarColor]]];
    [htmlContent appendString:[NSString stringWithFormat:@"\'],name: \'%@\',type: \'bar\',data: [", yValueName]];
    
    for (VHRecord *record in records)
    {
        [htmlContent appendString:[NSString stringWithFormat:@"\"%lld\",", record.number]];
    }
    
    [htmlContent appendString:@"]}]};myChart.setOption(option);</script></body></html>"];

    return [htmlContent copy];
}

+ (NSString *)dateTextFromRecord:(VHRecord *)record
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:[self dateFormat]];
    
    switch ([VHGithubNotifierManager sharedManager].trendTimeType)
    {
        case VHGithubTrendTimeTypeAnytime:
            return [dateFormatter stringFromDate:record.date];
            break;
        case VHGithubTrendTimeTypeDay:
            return [dateFormatter stringFromDate:record.date];
            break;
        case VHGithubTrendTimeTypeWeek:
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setFirstWeekday:[VHGithubNotifierManager sharedManager].weekStartFrom];
            NSDate *startOfTheWeek;
            NSDate *endOfWeek;
            NSTimeInterval interval;
            [calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                        startDate:&startOfTheWeek
                         interval:&interval
                          forDate:record.date];
            endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval - 1];
            return [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:startOfTheWeek], [dateFormatter stringFromDate:endOfWeek]];
        }
            break;
        case VHGithubTrendTimeTypeMonth:
            return [dateFormatter stringFromDate:record.date];
            break;
        case VHGithubTrendTimeTypeYear:
            return [dateFormatter stringFromDate:record.date];
            break;
        default:
            NSAssert(NO, @"Unknown record!");
            break;
    }
    return nil;
}

+ (NSString *)dateFormat
{
    switch ([VHGithubNotifierManager sharedManager].trendTimeType)
    {
        case VHGithubTrendTimeTypeAnytime:
            return @"MMM d HH:mm";
            break;
        case VHGithubTrendTimeTypeDay:
            return @"MMM d";
            break;
        case VHGithubTrendTimeTypeWeek:
            return @"MMM d";
            break;
        case VHGithubTrendTimeTypeMonth:
            return @"MMM";
            break;
        case VHGithubTrendTimeTypeYear:
            return @"yyyy";
            break;
        default:
            break;
    }
    return nil;
}

+ (NSString *)chartBarColor
{
    colorIndex = (colorIndex + 1) % [VHTrendChartParser colors].count;
    return [[VHTrendChartParser colors] objectAtIndex:colorIndex];
}

+ (NSArray<NSString *> *)colors
{
    if (colors == nil)
    {
//        colors = @[@"#F44336",
//                   @"#3F51B5",
//                   @"#673AB7",
//                   @"#E91E63",
//                   @"#9C27B0",
//                   @"#03A9F4",
//                   @"#009688",
//                   @"#4CAF50",
//                   @"#00BCD4",
//                   @"#2196F3",
//                   @"#CDDC39",
//                   @"#009688",
//                   @"#8BC34A",
//                   @"#FF9800",
//                   @"#FFEB3B",
//                   @"#795548",
//                   @"#FFC107",
//                   @"#9E9E9E",
//                   @"#FF5722",
//                   @"#607D8B"];
        colors = @[@"#03A9F4"];
    }
    return colors;
}

@end
