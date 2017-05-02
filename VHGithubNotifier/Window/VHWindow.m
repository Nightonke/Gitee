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
        [self setLevel:NSStatusWindowLevel];
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

- (void)updateArrowWithStatusItem:(NSStatusItem *) statusItem;
{
    NSRect frame = self.frame;
    NSRect statusItemFrame = [[statusItem.view window] convertRectToScreen:statusItem.view.frame];
    CGFloat centerX = statusItemFrame.origin.x + statusItemFrame.size.width / 2;

    frame.origin.x = centerX - frame.size.width / 2;
    frame.origin.y = statusItemFrame.origin.y - frame.size.height - MENU_WINDOW_TOP_MARGIN;
    [self setFrame: frame display:NO];

    const CGFloat OFFSET = [[self screen] frame].origin.x;

    if (frame.origin.x + frame.size.width > OFFSET + [[self screen] frame].size.width)
    {
        frame.origin.x = OFFSET + [[self screen] frame].size.width - frame.size.width - MENU_WINDOW_RIGHT_MARGIN;
    }
    if (frame.origin.x < OFFSET)
    {
        frame.origin.x = OFFSET + MENU_WINDOW_LEFT_MARGIN;
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
