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

static const CGFloat CORNER_RADIUS = 5;

@interface VHNotificationGroupHeaderCellView ()

@property (weak) IBOutlet NSButton *titleButton;
@property (weak) IBOutlet NSButton *readButton;

@end

@implementation VHNotificationGroupHeaderCellView

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    self.readButton.image.template = YES;
}

- (void)setRepository:(VHSimpleRepository *)repository
{
    _repository = repository;
    self.titleButton.title = repository.fullName;
    [self.titleButton sizeToFit];
    [self.titleButton setHeight:40];
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

@end
