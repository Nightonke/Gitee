//
//  CNUserNotificationBannerButton.m
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

#import "CNUserNotificationBannerButton.h"
#import "CNUserNotificationBannerButtonCell.h"


static NSDictionary *buttonTextAttributes;
typedef void (^CNUserNotificationBannerButtonActionHandler)(void);

@interface CNUserNotificationBannerButton () {}
@property (strong) CNUserNotificationBannerButtonActionHandler actionHandler;
@end

@implementation CNUserNotificationBannerButton

+ (void)initialize {
	NSMutableParagraphStyle *buttonStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
	buttonStyle.alignment = NSCenterTextAlignment;
	buttonTextAttributes = @{
        NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.238 alpha:1.000],
        NSParagraphStyleAttributeName:  buttonStyle,
        NSFontAttributeName:            [NSFont fontWithName:@"LucidaGrande" size:12],
        NSBaselineOffsetAttributeName:  [NSNumber numberWithInt:-2]
    };
}

+ (Class)cellClass {
	return [CNUserNotificationBannerButtonCell class];
}

- (instancetype)initWithTitle:(NSString *)theTitle actionHandler:(void (^)(void))actionHandler {
	self = [self init];
	if (self) {
		[self setTitle:theTitle];
		[self setActionHandler:actionHandler];
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		[self setButtonType:NSMomentaryPushInButton];
		[self setBezelStyle:NSRoundedBezelStyle];
	}
	return self;
}

- (void)setTitle:(NSString *)aString {
	[super setTitle:aString];
	[self setAttributedTitle:[[NSAttributedString alloc] initWithString:aString
	                                                         attributes:buttonTextAttributes]];
}

@end
