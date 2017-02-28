//
//  VHNotificationGroupBodyCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationGroupBodyCellView.h"
#import "NSView+Position.h"
#import "VHUtils+TransForm.h"

static const CGFloat CORNER_RADIUS = 5;

@interface VHNotificationGroupBodyCellView ()

@property (weak) IBOutlet NSImageView *image;
@property (weak) IBOutlet NSTextFieldCell *title;
@property (weak) IBOutlet NSButton *subscribeButton;
@property (weak) IBOutlet NSButton *readButton;

@end

@implementation VHNotificationGroupBodyCellView

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    self.subscribeButton.image.template = YES;
    self.readButton.image.template = YES;
}

- (void)setNotification:(VHNotification *)notification
{
    _notification = notification;
    self.title.title = notification.title;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[VHUtils colorFromHexColorCodeInString:@"#d8d8d8"] set];
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path setLineWidth:2];
    
    if (self.isLastBody)
    {
        [path moveToPoint:NSMakePoint(10, 40)];
        [path lineToPoint:NSMakePoint(10, CORNER_RADIUS)];
        [path curveToPoint:NSMakePoint(10 + CORNER_RADIUS, 2)
             controlPoint1:NSMakePoint(10, 2)
             controlPoint2:NSMakePoint(10, 2)];
        [path lineToPoint:NSMakePoint(390 - CORNER_RADIUS, 2)];
        [path curveToPoint:NSMakePoint(390, CORNER_RADIUS)
             controlPoint1:NSMakePoint(390, 2)
             controlPoint2:NSMakePoint(390, 2)];
        [path lineToPoint:NSMakePoint(390, 40)];
    }
    else
    {
        [path moveToPoint:NSMakePoint(10, 40)];
        [path lineToPoint:NSMakePoint(10, 0.5)];
        [path lineToPoint:NSMakePoint(390, 0.5)];
        [path lineToPoint:NSMakePoint(390, 40)];
    }
    [path stroke];
    
    [[VHUtils colorFromHexColorCodeInString:@"#ffffff"] set];
    [path fill];
}

@end
