//
//  VHCursorButton.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHCursorButton.h"

@implementation VHCursorButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _cursor = [NSCursor pointingHandCursor];
    }
    return self;
}

- (void)resetCursorRects
{
    if (self.cursor)
    {
        [self addCursorRect:[self bounds] cursor: self.cursor];
    }
    else
    {
        [super resetCursorRects];
    }
}

@end
