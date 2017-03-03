//
//  VHNotificationGroupBodyCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationGroupBodyCellView.h"
#import "NSView+Position.h"
#import "VHUtils.h"
#import "VHUtils+TransForm.h"
#import "VHCursorButton.h"
#import "VHGithubNotifierManager+Notification.h"

static const CGFloat CORNER_RADIUS = 5;

@interface VHNotificationGroupBodyCellView ()

@property (weak) IBOutlet NSImageView *image;
@property (weak) IBOutlet VHCursorButton *title;
@property (weak) IBOutlet VHCursorButton *subscribeButton;
@property (weak) IBOutlet VHCursorButton *readButton;

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation VHNotificationGroupBodyCellView

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    self.title.cursor = [NSCursor pointingHandCursor];
    self.subscribeButton.image.template = YES;
    self.subscribeButton.cursor = [NSCursor pointingHandCursor];
    self.readButton.image.template = YES;
    self.readButton.cursor = [NSCursor pointingHandCursor];
    self.backgroundColor = [VHUtils colorFromHexColorCodeInString:@"#ffffff"];
}

- (void)setNotification:(VHNotification *)notification
{
    _notification = notification;
    self.title.title = _notification.title;
    if ([VHUtils widthOfString:_notification.title withFont:self.title.font] > self.title.width)
    {
        self.title.toolTip = [NSString stringWithFormat:@"%@  %@", _notification.title, [VHUtils timeStringToNowFromTime:self.notification.updateDate]];
    }
    else
    {
        CGFloat height = self.title.height;
        [self.title sizeToFit];
        [self.title setHeight:height];
        self.title.toolTip = [NSString stringWithFormat:@"%@", [VHUtils timeStringToNowFromTime:self.notification.updateDate]];
    }
    
    self.subscribeButton.toolTip = @"Unsubscribe from this thread";
    self.readButton.toolTip = @"Mark as read";
}

- (IBAction)onTitleClicked:(id)sender
{
    [VHUtils openUrl:self.notification.htmlUrl];
}

- (IBAction)onSubscribeButtonClicked:(id)sender
{
    [[VHGithubNotifierManager sharedManager] unsubscribeThread:self.notification];
}

- (IBAction)onReadButtonClicked:(id)sender
{
    [[VHGithubNotifierManager sharedManager] markNotificationAsRead:self.notification];
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
    
    [self.backgroundColor set];
    [path fill];
}

- (void)mouseEntered:(NSEvent *)event
{
    [super mouseEntered:event];
    self.backgroundColor = [VHUtils colorFromHexColorCodeInString:@"#f5f9fc"];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    [super mouseExited:event];
    self.backgroundColor = [VHUtils colorFromHexColorCodeInString:@"#ffffff"];
    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)event
{
    [super scrollWheel:event];
    self.backgroundColor = [VHUtils colorFromHexColorCodeInString:@"#ffffff"];
    [self setNeedsDisplay:YES];
}

- (void)updateTrackingAreas
{
    if(self.trackingArea != nil)
    {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
