//
//  VHHorizontalTrendView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHHorizontalTrendView.h"
#import "NSView+Position.h"

@interface VHHorizontalTrendView ()

@property (nonatomic, assign) CGFloat drawLength;

@end

@implementation VHHorizontalTrendView

#pragma mark - Public Methods

- (void)setFrame:(CGRect)frame withValue:(CGFloat)value withMaxValue:(CGFloat)maxValue withColor:(NSColor *)color
{
    self.frame = frame;
    self.value = value;
    self.maxValue = maxValue;
    self.color = color;
    if (self.maxValue == 0)
    {
        self.drawLength = frame.size.height / 2;
    }
    else
    {
        self.drawLength = (frame.size.width - frame.size.height / 2) * value / maxValue + frame.size.height / 2;
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self.color set];
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:NSMakePoint(0, self.height / 2)];
    [path lineToPoint:NSMakePoint(self.height / 2, self.height)];
    [path lineToPoint:NSMakePoint(self.drawLength, self.height)];
    [path lineToPoint:NSMakePoint(self.drawLength, 0)];
    [path lineToPoint:NSMakePoint(self.height / 2, 0)];
    [path closePath];
    [path fill];
}

@end
