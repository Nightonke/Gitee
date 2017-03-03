//
//  VHNotificationHeaderCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/3.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationHeaderCellView.h"
#import "VHCursorButton.h"
#import "VHUtils+TransForm.h"
#import "VHGithubNotifierManager+Notification.h"

static const CGFloat CORNER_RADIUS = 5;

@interface VHNotificationHeaderCellView ()

@property (weak) IBOutlet NSTextField *notificationTip;
@property (weak) IBOutlet VHCursorButton *readButton;

@end

@implementation VHNotificationHeaderCellView

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    self.readButton.image.template = YES;
    self.readButton.cursor = [NSCursor pointingHandCursor];
    self.readButton.toolTip = @"Mark all notifications as read";
}

- (void)setNotificationNumber:(NSUInteger)notificationNumber
{
    NSString *notificationTipString = @"One unread notification";
    if (notificationNumber > 1)
    {
        notificationTipString = [NSString stringWithFormat:@"%zd unread notifications", notificationNumber];
    }
    [self.notificationTip setStringValue:notificationTipString];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[VHUtils colorFromHexColorCodeInString:@"#d8d8d8"] set];
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path setLineWidth:2];
    [path moveToPoint:NSMakePoint(10, CORNER_RADIUS)];
    [path lineToPoint:NSMakePoint(10, 36 - CORNER_RADIUS)];
    [path curveToPoint:NSMakePoint(10 + CORNER_RADIUS, 36)
         controlPoint1:NSMakePoint(10, 36)
         controlPoint2:NSMakePoint(10, 36)];
    [path lineToPoint:NSMakePoint(390 - CORNER_RADIUS, 36)];
    [path curveToPoint:NSMakePoint(390, 36 - CORNER_RADIUS)
         controlPoint1:NSMakePoint(390, 36)
         controlPoint2:NSMakePoint(390, 36)];
    [path lineToPoint:NSMakePoint(390, CORNER_RADIUS)];
    [path curveToPoint:NSMakePoint(390 - CORNER_RADIUS, 1)
         controlPoint1:NSMakePoint(390, 1)
         controlPoint2:NSMakePoint(390, 1)];
    [path lineToPoint:NSMakePoint(10 + CORNER_RADIUS, 1)];
    [path curveToPoint:NSMakePoint(10, CORNER_RADIUS)
         controlPoint1:NSMakePoint(10, 1)
         controlPoint2:NSMakePoint(10, 1)];
    [path closePath];
    [path stroke];
    
    [[VHUtils colorFromHexColorCodeInString:@"#f5f5f5"] set];
    [path fill];
}

#pragma mark - Action

- (IBAction)onReadButtonClicked:(id)sender
{
    [[VHGithubNotifierManager sharedManager] markAllNotificationAsRead];
}

@end
