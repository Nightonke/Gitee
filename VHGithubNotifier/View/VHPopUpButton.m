//
//  VHPopUpButton.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHPopUpButton.h"
#import "NSView+Position.h"

@interface VHPopUpButton ()<NSMenuDelegate>

@end

@implementation VHPopUpButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _menuWindowXOffset = CGFLOAT_MIN;
        _menuWindowYOffset = CGFLOAT_MIN;
        _menuWindowWidth   = CGFLOAT_MIN;
        _menuWindowHeight  = CGFLOAT_MIN;
        _cursor = [NSCursor pointingHandCursor];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _cursor = [NSCursor pointingHandCursor];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
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

#pragma mark - Setters

- (void)setMenuWindowXOffset:(CGFloat)menuWindowXOffset
{
    _menuWindowXOffset = menuWindowXOffset;
    self.menu.delegate = self;
}

- (void)setMenuWindowYOffset:(CGFloat)menuWindowYOffset
{
    _menuWindowYOffset = menuWindowYOffset;
    self.menu.delegate = self;
}

- (void)setMenuWindowWidth:(CGFloat)menuWindowWidth
{
    _menuWindowWidth   = menuWindowWidth;
    self.menu.delegate = self;
}

- (void)setMenuWindowHeight:(CGFloat)menuWindowHeight
{
    _menuWindowHeight  = menuWindowHeight;
    self.menu.delegate = self;
}

- (void)setMenuWindowRelativeFrame:(NSRect)frame
{
    _menuWindowXOffset = frame.origin.x;
    _menuWindowYOffset = frame.origin.y;
    _menuWindowWidth   = frame.size.width;
    _menuWindowHeight  = frame.size.height;
    self.menu.delegate = self;
}

#pragma mark - NSMenuDelegate

- (NSRect)confinementRectForMenu:(NSMenu *)menu onScreen:(nullable NSScreen *)screen
{
    NSRect inScreenFrame = [self frameRelativeToScreen];
    return NSMakeRect(inScreenFrame.origin.x + self.menuWindowXOffset,
                      inScreenFrame.origin.y + self.menuWindowYOffset,
                      self.menuWindowWidth,
                      self.menuWindowHeight);
}

@end
