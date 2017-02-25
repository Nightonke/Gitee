//
//  VHTrendTableCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/18.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendTableCellView.h"
#import "VHHorizontalTrendView.h"
#import "NSView+Position.h"
#import "VHUtils.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+UserDefault.h"

@interface VHTrendTableCellView ()

@property (nonatomic, strong) NSTextField *text;
@property (nonatomic, strong) VHHorizontalTrendView *trend;
@property (nonatomic, strong) NSTextField *number;

@end

@implementation VHTrendTableCellView

#pragma mark - Public Methods

- (void)setRecord:(VHRecord *)record
{
    _record = record;
    [self.text setStringValue:[self dateTextFromRecord:record]];
    [self.text setTextColor:self.trendColor];
    [self.text sizeToFit];
    [self.text setWidth:[self dateTextWidth]];
    [self.trend setFrame:NSMakeRect([self.text getRight], 0, 307 - [self dateTextWidth], 16)
               withValue:record.number
            withMaxValue:self.maxValue
               withColor:self.trendColor];
    [self.number setStringValue:[NSString stringWithFormat:@"%lld", record.number]];
    [self.number setTextColor:self.trendColor];
    [self.number sizeToFit];
    [self.number setWidth:50];
}

#pragma mark - Private Methods

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _text = [VHUtils labelWithFrame:NSMakeRect(0, 0, 0, 20)];
        [_text setAlignment:NSTextAlignmentRight];
        [_text setFont:[NSFont fontWithName:@"Arial" size:13]];
        [self addSubview:_text];
        
        _trend = [[VHHorizontalTrendView alloc] init];
        [self addSubview:_trend];
        
        _number = [VHUtils labelWithFrame:NSMakeRect(307, 0, 50, 20)];
        [_number setFont:[NSFont fontWithName:@"Arial" size:13]];
        [_number setAlignment:NSTextAlignmentRight];
        [self addSubview:_number];
    }
    return self;
}

- (CGFloat)dateTextWidth
{
    switch ([[VHGithubNotifierManager sharedManager] trendTimeType])
    {
        case VHGithubTrendTimeTypeAnytime:
            return 90;
            break;
        case VHGithubTrendTimeTypeDay:
            return 50;
            break;
        case VHGithubTrendTimeTypeWeek:
            return 100;
            break;
        case VHGithubTrendTimeTypeMonth:
            return 30;
            break;
        case VHGithubTrendTimeTypeYear:
            return 40;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)dateTextFromRecord:(VHRecord *)record
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

- (NSString *)dateFormat
{
    switch ([VHGithubNotifierManager sharedManager].trendTimeType)
    {
        case VHGithubTrendTimeTypeAnytime:
            return @"MMM dd HH:mm";
            break;
        case VHGithubTrendTimeTypeDay:
            return @"MMM dd";
            break;
        case VHGithubTrendTimeTypeWeek:
            return @"MMM dd";
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

@end
