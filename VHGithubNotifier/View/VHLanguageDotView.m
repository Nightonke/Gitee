//
//  VHLanguageDotView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHLanguageDotView.h"

@implementation VHLanguageDotView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect:self.bounds];
    [self.languageColor setFill];
    [circlePath fill];
}

@end
