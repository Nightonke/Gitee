//
//  VHHorizontalLine.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/7.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHHorizontalLine.h"
#import "VHUtils+TransForm.h"

@implementation VHHorizontalLine

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(0, 0)];
    [line lineToPoint:NSMakePoint(NSMaxX([self bounds]), 0)];
    [line setLineWidth:self.lineWidth];
    [[VHUtils colorFromHexColorCodeInString:@"#aaaaaa"] set];
    [line stroke];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay:YES];
}

@end
