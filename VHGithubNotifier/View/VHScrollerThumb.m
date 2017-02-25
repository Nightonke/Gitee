//
//  VHScrollerThumb.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHScrollerThumb.h"

@interface VHScrollerThumb ()

@property (nonatomic, assign) NSPoint lastDragLocation;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;

@end

@implementation VHScrollerThumb

- (instancetype)initWithFrame:(NSRect)frameRect withImageName:(NSString *)imageName
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self setImage:[NSImage imageNamed:imageName]];
        _dragDirection = VHDragDirectionTypeVertical;
    }
    return self;
}

#pragma mark - Touch Action

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    // Convert to superview's coordinate space
    self.lastDragLocation = [[self superview] convertPoint:[event locationInWindow] fromView:nil];
    self.maxX = [self superview].bounds.size.width - self.frame.size.width;
    self.maxY = [self superview].bounds.size.height - self.frame.size.height;
}

- (void)mouseDragged:(NSEvent *)event
{
    // We're working only in the superview's coordinate space, so we always convert.
    NSPoint newDragLocation = [[self superview] convertPoint:[event locationInWindow] fromView:nil];
    NSPoint thisOrigin = [self frame].origin;
    
    switch (self.dragDirection)
    {
        case VHDragDirectionTypeNeither:
            break;
        case VHDragDirectionTypeHorizontal:
            thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
            break;
        case VHDragDirectionTypeVertical:
            thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
            break;
        case VHDragDirectionTypeBoth:
            thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
            thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
            break;
    }
    
    thisOrigin.x = MIN(self.maxX, thisOrigin.x);
    thisOrigin.x = MAX(0, thisOrigin.x);
    thisOrigin.y = MIN(self.maxY, thisOrigin.y);
    thisOrigin.y = MAX(0, thisOrigin.y);
    [self setFrameOrigin:thisOrigin];
    self.lastDragLocation = newDragLocation;
    
    [self updateProgress];
}

- (void)updateProgress
{
    CGFloat progress = 1 - self.frame.origin.y / self.maxY;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onThumbScrolled:)])
    {
        [self.delegate onThumbScrolled:progress];
    }
}

@end
