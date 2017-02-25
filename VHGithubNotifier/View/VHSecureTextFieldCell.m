//
//  VHSecureTextFieldCell.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSecureTextFieldCell.h"

@implementation VHSecureTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath *betterBounds = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:5 yRadius:5];
    [betterBounds addClip];
    [super drawWithFrame:cellFrame inView:controlView];
    if (self.isBezeled) {
        [betterBounds setLineWidth:2];
        [[NSColor colorWithCalibratedRed:0.510 green:0.643 blue:0.804 alpha:1] setStroke];
        [betterBounds stroke];
    }
}

- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    // super would normally draw text at the top of the cell
    NSInteger offset = floor((NSHeight(frame) -
                              ([[self font] ascender] - [[self font] descender])) / 2);
    return NSInsetRect(frame, 5, offset - 3);
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView
               editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event {
    [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                  inView:controlView editor:editor delegate:delegate event:event];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView
                 editor:(NSText *)editor delegate:(id)delegate
                  start:(NSInteger)start length:(NSInteger)length {
    
    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                    inView:controlView editor:editor delegate:delegate
                     start:start length:length];
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view {
    [super drawInteriorWithFrame:
     [self adjustedFrameToVerticallyCenterText:frame] inView:view];
}

@end
