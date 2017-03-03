//
//  VHNotificationGroupHeaderCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationGroupHeaderCellView.h"
#import "NSView+Position.h"
#import "VHUtils+TransForm.h"
#import "VHCursorButton.h"
#import "VHGithubNotifierManager+Notification.h"

static const CGFloat CORNER_RADIUS = 5;

@interface VHNotificationGroupHeaderCellView ()

@property (weak) IBOutlet VHCursorButton *title;
@property (weak) IBOutlet NSTextField *notificationNumberLabel;
@property (weak) IBOutlet VHCursorButton *readButton;

@end

@implementation VHNotificationGroupHeaderCellView

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    self.title.cursor = [NSCursor pointingHandCursor];
    self.readButton.image.template = YES;
    self.readButton.cursor = [NSCursor pointingHandCursor];
}

- (void)setRepository:(VHSimpleRepository *)repository
{
    _repository = repository;
    self.title.title = _repository.fullName;
    if ([VHUtils widthOfString:_repository.fullName withFont:self.title.font] > self.title.width)
    {
        
    }
    else
    {
        CGFloat height = self.title.height;
        [self.title sizeToFit];
        [self.title setHeight:height];
    }
    
    self.title.toolTip = BROWSE_STRING(self.repository.fullName);
    self.readButton.toolTip = [NSString stringWithFormat:@"Mark all %@ notifications as read", self.repository.fullName];
}

- (void)setNotificationNumber:(NSUInteger)notificationNumber
{
    if (notificationNumber <= 0)
    {
        self.notificationNumberLabel.hidden = YES;
    }
    else
    {
        self.notificationNumberLabel.hidden = NO;
        self.notificationNumberLabel.stringValue = [NSString stringWithFormat:@"%zd", notificationNumber];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[VHUtils colorFromHexColorCodeInString:@"#d8d8d8"] set];
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path setLineWidth:2];
    [path moveToPoint:NSMakePoint(10, 1)];
    [path lineToPoint:NSMakePoint(10, 36 - CORNER_RADIUS)];
    [path curveToPoint:NSMakePoint(10 + CORNER_RADIUS, 36)
         controlPoint1:NSMakePoint(10, 36)
         controlPoint2:NSMakePoint(10, 36)];
    [path lineToPoint:NSMakePoint(390 - CORNER_RADIUS, 36)];
    [path curveToPoint:NSMakePoint(390, 36 - CORNER_RADIUS)
         controlPoint1:NSMakePoint(390, 36)
         controlPoint2:NSMakePoint(390, 36)];
    [path lineToPoint:NSMakePoint(390, 1)];
    [path lineToPoint:NSMakePoint(10, 1)];
    [path closePath];
    [path stroke];
    
    [[VHUtils colorFromHexColorCodeInString:@"#f5f5f5"] set];
    [path fill];
}

- (IBAction)onTitleClicked:(id)sender
{
    [VHUtils openUrl:self.repository.htmlUrl];
}

- (IBAction)onReadButtonClicked:(id)sender
{
    [[VHGithubNotifierManager sharedManager] markNotificationAsReadInRepository:self.repository];
}

@end
