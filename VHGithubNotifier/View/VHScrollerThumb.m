//
//  VHScrollerThumb.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHScrollerThumb.h"
#import "NSView+Position.h"

@interface VHScrollerThumb ()

@property (nonatomic, assign) NSPoint lastDragLocation;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *pressedImageName;

@property (nonatomic, assign) BOOL mouseDown;

@end

@implementation VHScrollerThumb

- (instancetype)initWithFrame:(NSRect)frameRect
                withImageName:(NSString *)imageName
         withPressedImageName:(NSString *)pressedImageName
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _dragDirection = VHDragDirectionTypeVertical;
        _imageName = imageName;
        _pressedImageName = pressedImageName;
        [self setImage:[NSImage imageNamed:_imageName]];
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
    self.lastDragLocation = [[self window] convertRectToScreen:CGRectMake(event.locationInWindow.x, event.locationInWindow.y, 0, 0)].origin;
    self.maxX = [self superview].bounds.size.width - self.frame.size.width;
    self.maxY = [self superview].bounds.size.height - self.frame.size.height;
    [self setImage:[NSImage imageNamed:self.pressedImageName]];
    self.mouseDown = YES;
    
    while (1)
    {
        event = [[self window] nextEventMatchingMask: (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        
        NSPoint newDragLocation = [[self window] convertRectToScreen:CGRectMake(event.locationInWindow.x, event.locationInWindow.y, 0, 0)].origin;

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
        
        if ([event type] == NSLeftMouseUp)
        {
            [self setImage:[NSImage imageNamed:self.imageName]];
            self.mouseDown = NO;
            break;
        }
    }
}

- (void)setY:(CGFloat)y
{
    if (self.mouseDown == NO)
    {
        [super setY:y];
    }
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
