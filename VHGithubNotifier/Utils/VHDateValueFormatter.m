//
//  VHDateValueFormatter.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/16.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHDateValueFormatter.h"

@interface VHDateValueFormatter ()

@property NSDateFormatter *dateFormatter;

@end

@implementation VHDateValueFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd MMM HH:mm";
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
}

@end
