//
//  VHTabVCBackgroundView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/26.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHTabVCBackgroundView.h"
#import "VHUtils+TransForm.h"

static const CGFloat TAB_VC_MARGIN_TOP = 15;

@interface VHTabVCBackgroundView ()

@property (nonatomic, assign) CGFloat statusItemCenterX;

@end

@implementation VHTabVCBackgroundView

#pragma mark - Public Methods

- (void)updateArrowWithStatusItemCenterX:(CGFloat)centerX
{
    self.statusItemCenterX = centerX;
    [self setNeedsDisplay:YES];
}

- (NSRect)tabViewFrame
{
    return NSMakeRect(0,
                      self.bounds.size.height - self.arrowHeight,
                      self.bounds.size.width,
                      TAB_VC_TITLE_HEIGHT);
}

- (NSRect)contentViewFrame
{
    return NSMakeRect(0,
                      0,
                      self.bounds.size.width,
                      self.bounds.size.height - self.arrowHeight - TAB_VC_TITLE_HEIGHT);
}

#pragma mark - Private Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _statusItemCenterX = 0;
        _arrowWidth = TAB_VC_ARROW_WIDTH;
        _arrowHeight = TAB_VC_ARROW_HEIGHT;
        _titleHeight = TAB_VC_TITLE_HEIGHT;
        _cornerRadius = TAB_VC_CORNER_RADIUS;
        self.layer = _layer;
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = _cornerRadius / 2;
    }
    return self;
}

- (BOOL)opaque
{
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw the title
    NSRect frameOnScreen = [[self window] convertRectToScreen:self.frame];
    CGFloat arrowTopX = self.statusItemCenterX - frameOnScreen.origin.x;
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    
    [path moveToPoint:NSMakePoint(0, self.bounds.size.height - TAB_VC_MARGIN_TOP - self.cornerRadius)];
    [path curveToPoint:NSMakePoint(self.cornerRadius, self.bounds.size.height - TAB_VC_MARGIN_TOP)
         controlPoint1:NSMakePoint(0, self.bounds.size.height - TAB_VC_MARGIN_TOP)
         controlPoint2:NSMakePoint(0, self.bounds.size.height - TAB_VC_MARGIN_TOP)];
    [path lineToPoint:NSMakePoint(arrowTopX - self.arrowWidth / 2, self.bounds.size.height - TAB_VC_MARGIN_TOP)];
    [path lineToPoint:NSMakePoint(arrowTopX, self.bounds.size.height - TAB_VC_MARGIN_TOP + self.arrowHeight)];
    [path lineToPoint:NSMakePoint(arrowTopX + self.arrowWidth / 2, self.bounds.size.height - TAB_VC_MARGIN_TOP)];
    [path lineToPoint:NSMakePoint(self.bounds.size.width - self.cornerRadius, self.bounds.size.height - TAB_VC_MARGIN_TOP)];
    [path curveToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height - TAB_VC_MARGIN_TOP - self.cornerRadius)
         controlPoint1:NSMakePoint(self.bounds.size.width, self.bounds.size.height - TAB_VC_MARGIN_TOP)
         controlPoint2:NSMakePoint(self.bounds.size.width, self.bounds.size.height - TAB_VC_MARGIN_TOP)];
    [path lineToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height - self.titleHeight - TAB_VC_MARGIN_TOP)];
    [path lineToPoint:NSMakePoint(0, self.bounds.size.height - self.titleHeight - TAB_VC_MARGIN_TOP)];
//    [path closePath];
    
    [[VHUtils colorFromHexColorCodeInString:@"#03A9F4"] set];
    [path fill];
//    [NSGraphicsContext saveGraphicsState];
    
    // Shadow
//    [[NSColor colorWithCalibratedWhite:1 alpha:0.1] set];
//    path = [[NSBezierPath alloc] init];
//    [path setLineWidth:0];
//    [path moveToPoint:NSMakePoint(0, self.bounds.size.height - self.titleHeight - self.arrowHeight)];
//    [path curveToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height - self.titleHeight - self.arrowHeight)
//         controlPoint1:NSMakePoint(self.bounds.size.width / 8, self.bounds.size.height - self.titleHeight - self.arrowHeight - 5)
//         controlPoint2:NSMakePoint(7 * self.bounds.size.width / 8, self.bounds.size.height - self.titleHeight - self.arrowHeight - 5)];
//    [path closePath];
//    NSShadow *shadow = [[NSShadow alloc] init];
//    [shadow setShadowColor:[NSColor blackColor]];
//    [shadow setShadowBlurRadius:10.0];
//    [shadow set];
//    [path fill];
//    
////     Restore the graphics state
//    [NSGraphicsContext restoreGraphicsState];
}

@end
