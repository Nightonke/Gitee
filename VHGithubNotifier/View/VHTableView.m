//
//  VHTableView.m
//  VHGithubNotifier
//
//  Created by Nightonke on 2017/9/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTableView.h"

@implementation VHTableView

- (void)scrollRowToVisible:(NSInteger)rowIndex animate:(BOOL)animate
{
    if(animate)
    {
        NSRect rowRect = [self rectOfRow:rowIndex];
        NSPoint scrollOrigin = rowRect.origin;
        NSClipView *clipView = (NSClipView *)[self superview];
        scrollOrigin.y += MAX(0, round((NSHeight(rowRect) - NSHeight(clipView.frame)) * 0.5f));
        NSScrollView *scrollView = (NSScrollView *)[clipView superview];
        if ([scrollView respondsToSelector:@selector(flashScrollers)])
        {
            [scrollView flashScrollers];
        }
        [[clipView animator] setBoundsOrigin:scrollOrigin];
    }
    else
    {
        NSRect rowRect = [self rectOfRow:rowIndex];
        NSPoint scrollOrigin = rowRect.origin;
        NSClipView *clipView = (NSClipView *)[self superview];
        scrollOrigin.y += MAX(0, round((NSHeight(rowRect) - NSHeight(clipView.frame)) * 0.5f));
        [clipView setBoundsOrigin:scrollOrigin];
    }
}

@end
