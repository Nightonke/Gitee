//
//  VHContributionBlock.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHContributionBlock.h"
#import "NSDate+Utils.h"
#import "VHUtils+TransForm.h"
#import "NSColor+Utils.h"

@implementation VHContributionBlock

- (instancetype)initWithHppleElement:(TFHppleElement *)element
{
    self = [super init];
    if (self)
    {
        _level = [self levelFromHexColor:[element objectForKey:@"fill"]];
        _contributions = [[element objectForKey:@"data-count"] integerValue];
        _date = [self dateFromString:[element objectForKey:@"data-date"]];
    }
    return self;
}

- (NSColor *)leftFaceColor
{
    switch (self.level)
    {
        case 0: return [VHUtils colorFromHexColorCodeInString:@"#b5b8bc"];
        case 1: return [VHUtils colorFromHexColorCodeInString:@"#8ab045"];
        case 2: return [VHUtils colorFromHexColorCodeInString:@"#42912b"];
        case 3: return [VHUtils colorFromHexColorCodeInString:@"#0f6000"];
        case 4: return [VHUtils colorFromHexColorCodeInString:@"#062b00"];
        default: return [VHUtils colorFromHexColorCodeInString:@"#b5b8bc"];
    }
}

- (NSColor *)rightFaceColor
{
    switch (self.level)
    {
        case 0: return [VHUtils colorFromHexColorCodeInString:@"#cdd0d4"];
        case 1: return [VHUtils colorFromHexColorCodeInString:@"#a0c859"];
        case 2: return [VHUtils colorFromHexColorCodeInString:@"#55a73d"];
        case 3: return [VHUtils colorFromHexColorCodeInString:@"#17750e"];
        case 4: return [VHUtils colorFromHexColorCodeInString:@"#0c3c08"];
        default: return [VHUtils colorFromHexColorCodeInString:@"#cdd0d4"];
    }
}

- (NSColor *)topFaceColor
{
    switch (self.level)
    {
        case 0: return [VHUtils colorFromHexColorCodeInString:@"#ebedf0"];
        case 1: return [VHUtils colorFromHexColorCodeInString:@"#c6e48b"];
        case 2: return [VHUtils colorFromHexColorCodeInString:@"#7bc96f"];
        case 3: return [VHUtils colorFromHexColorCodeInString:@"#239a3b"];
        case 4: return [VHUtils colorFromHexColorCodeInString:@"#196127"];
        default: return [VHUtils colorFromHexColorCodeInString:@"#ebedf0"];
    }
}

#pragma mark - Private Methods

- (Byte)levelFromHexColor:(NSString *)color
{
    if ([color isEqualToString:@"#ebedf0"])
    {
        return 0;
    }
    else if ([color isEqualToString:@"#c6e48b"])
    {
        return 1;
    }
    else if ([color isEqualToString:@"#7bc96f"])
    {
        return 2;
    }
    else if ([color isEqualToString:@"#239a3b"])
    {
        return 3;
    }
    else if ([color isEqualToString:@"#196127"])
    {
        return 4;
    }
    else
    {
        return 0;
    }
}

- (NSDate *)dateFromString:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [[dateFormatter dateFromString:timeString] toLocalTime];
}

@end
