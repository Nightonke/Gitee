//
//  VHWindow.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/27.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHWindow.h"
#import "NSView+Position.h"
#import "VHTabVC.h"

const static CGFloat MENU_WINDOW_TOP_MARGIN = 5;
const static CGFloat MENU_WINDOW_RIGHT_MARGIN = 20;
const static CGFloat MENU_WINDOW_LEFT_MARGIN = 20;

@interface VHWindow ()

@property (nonatomic, strong) id mouseEventMonitor;

@end

@implementation VHWindow

#pragma mark - Public Methods

- (instancetype)initWithStatusItem:(NSStatusItem *)statusBarButton withDelegate:(id<VHWindowProtocol>)delegate
{
    ViewLog(@"Init");
    NSRect frame = NSMakeRect(0, 0, 400, 600);
    
    self = [super initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:NO];
    if (self)
    {
        VHTabVC *vc = [[VHTabVC alloc] initWithNibName:@"VHTabVC" bundle:[NSBundle mainBundle]];
        [self setContentViewController:vc];
        
        _windowDelegate = delegate;
        [self setHasShadow:YES];
        [self setLevel:NSPopUpMenuWindowLevel];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setCollectionBehavior:NSWindowCollectionBehaviorStationary];
        
        WEAK_SELF(self);
        _mouseEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown | NSEventMaskOtherMouseDown)
                                                                    handler:^(NSEvent *event) {
                                                                        STRONG_SELF(self);
                                                                        if (self.windowDelegate != nil && [self.windowDelegate respondsToSelector:@selector(onMouseClickedOutside)])
                                                                        {
                                                                            [self.windowDelegate onMouseClickedOutside];
                                                                        }
                                                                    }];
    }
    return self;
}

- (void)updateArrowWithStatusItemCenterX:(CGFloat)centerX withStatusItemFrame:(CGRect)statusItemFrame;
{
    NSRect frame = self.frame;
    frame.origin.x = centerX - self.frame.size.width / 2;
    frame.origin.y = statusItemFrame.origin.y - [self frame].size.height - MENU_WINDOW_TOP_MARGIN;
    
    if (frame.origin.x + frame.size.width > [[self screen] frame].size.width)
    {
        frame.origin.x = [[self screen] frame].size.width - frame.size.width - MENU_WINDOW_RIGHT_MARGIN;
    }
    if (frame.origin.x < 0)
    {
        frame.origin.x = MENU_WINDOW_LEFT_MARGIN;
    }
    
    [self setFrame:frame display:NO];
    VHTabVC *tabVC = (VHTabVC *)SAFE_CAST(self.contentViewController, [VHTabVC class]);
    if (tabVC)
    {
        [tabVC updateArrowWithStatusItemCenterX:centerX];
    }
}

#pragma mark - Private Methods

- (void)dealloc
{
    ViewLog(@"Dealloc");
    [NSEvent removeMonitor:self.mouseEventMonitor];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

@end
