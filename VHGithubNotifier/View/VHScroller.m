//
//  VHScroller.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHScroller.h"
#import "VHScrollerThumb.h"
#import "NSView+Position.h"

@interface VHScroller ()<VHScrollerThumbDelegate>

@property (nonatomic, strong) VHScrollerThumb *thumb;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *pauseStart;
@property (nonatomic, strong) NSDate *previousFireDate;
@property (nonatomic, assign) CGFloat originalX;

@end

@implementation VHScroller

- (instancetype)initWithFrame:(NSRect)frameRect
               withImageFrame:(NSRect)imageFrame
                withImageName:(NSString *)imageName
               withScrollView:(NSScrollView *)scrollView
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _thumb = [[VHScrollerThumb alloc] initWithFrame:imageFrame withImageName:imageName];
        _thumb.delegate = self;
        [self addSubview:_thumb];
        
        _scrollView = scrollView;
        
        [scrollView.contentView setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boundDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:scrollView.contentView];
        
        _originalX = frameRect.origin.x;
        
        [self setX:self.originalX + self.width];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrollView.contentView setPostsBoundsChangedNotifications:NO];
    self.scrollView = nil;
}

- (void)boundDidChange:(NSNotification *)notification
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [context setDuration:0.5];
        NSRect frame = self.frame;
        frame.origin.x = self.originalX;
        [[self animator] setFrame:frame];
    } completionHandler:^{
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(disappear)
                                                    userInfo:nil
                                                     repeats:NO];
    }];
    
    // get the changed content view from the notification
    CGFloat max = self.scrollView.documentView.height - self.scrollView.contentView.height;
    CGFloat now = self.scrollView.contentView.bounds.origin.y;
    CGFloat maxY = self.height - self.thumb.height;
    CGFloat minY = 0;
    
    [self.thumb setY:(1 - now / max) * (maxY - minY)];
}

- (void)disappear
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [context setDuration:0.5];
        NSRect frame = self.frame;
        frame.origin.x = self.originalX + self.width;
        [[self animator] setFrame:frame];
    } completionHandler:nil];
}

- (void)onThumbScrolled:(CGFloat)progress
{
    CGFloat max = self.scrollView.documentView.height - self.scrollView.contentView.height;
    [self.scrollView.documentView scrollPoint:NSMakePoint(0, max * progress)];
}

@end
