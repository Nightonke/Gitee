//
//  CNUserNotificationBannerButtonCell.m
//
//  Created by Frank Gregor on 20.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2013 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CNUserNotificationBannerButtonCell.h"


static NSColor *gradientTopColor, *gradientBottomColor;
static NSGradient *backgroundGradient;
static NSColor *strokeColor;
static CGFloat borderRadius;


@implementation CNUserNotificationBannerButtonCell

+ (void)initialize {
	gradientTopColor = [NSColor colorWithCalibratedWhite:0.980 alpha:0.950];
	gradientBottomColor = [NSColor colorWithCalibratedWhite:0.802 alpha:0.950];
	backgroundGradient = [[NSGradient alloc] initWithStartingColor:gradientTopColor endingColor:gradientBottomColor];
	strokeColor = [NSColor colorWithCalibratedWhite:0.369 alpha:1.000];
	borderRadius = 5.0;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
	NSRect borderRect = NSInsetRect(frame, 5, 5);
	NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:4 yRadius:4];
	[strokeColor setFill];
	[borderPath fill];

	if (self.isHighlighted) {
		NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(borderRect, 0.5, 0.5) xRadius:4 yRadius:4];
		[backgroundGradient drawInBezierPath:buttonPath angle:-90];
	}
	else {
		NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(borderRect, 0.5, 0.5) xRadius:4 yRadius:4];
		[backgroundGradient drawInBezierPath:buttonPath angle:90];
	}
}

@end
