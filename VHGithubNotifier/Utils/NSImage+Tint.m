//
//  NSImage+Tint.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/7.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSImage+Tint.h"

@implementation NSImage (Tint)

- (NSImage *)imageTintedWithColor:(NSColor *)tint
{
    NSImage *image = [self copy];
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    return image;
}

@end
