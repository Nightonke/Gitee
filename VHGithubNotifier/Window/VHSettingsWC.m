//
//  VHSettingsWC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/6.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSettingsWC.h"
#import "VHUtils.h"
#import "VHGithubNotifierManager+UserDefault.h"

@interface VHSettingsWC ()

@property (weak) IBOutlet NSScrollView *scrollView;

#pragma mark Status Bar
@property (weak) IBOutlet NSButton *totalStargazersNumberButton;
@property (weak) IBOutlet NSButton *followersNumberButton;
@property (weak) IBOutlet NSButton *unreadNotificationsNumberButton;
@property (weak) IBOutlet NSButton *onlyShowsValidContentsInStatusBarButton;

@end

@implementation VHSettingsWC

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window.contentView setWantsLayer:YES];
    self.window.contentView.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.window.contentView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    self.window.toolbar.showsBaselineSeparator = NO;
    [self.window setMovableByWindowBackground:YES];
    
    self.scrollView.contentView.bounds = CGRectMake(0, 0, self.scrollView.contentView.bounds.size.width, self.scrollView.contentView.bounds.size.height);
    [VHUtils scrollViewToTop:self.scrollView];
    
    [self initSettingsForStatusBar];
}

- (void)initSettingsForStatusBar
{
    NSUInteger contents = [[VHGithubNotifierManager sharedManager] statusBarButtonContents];
    self.totalStargazersNumberButton.state = contents & VHStatusBarButtonContentTypeStargazers;
    self.followersNumberButton.state = contents & VHStatusBarButtonContentTypeFollowers;
    self.unreadNotificationsNumberButton.state = contents & VHStatusBarButtonContentTypeNotifications;
    
    self.onlyShowsValidContentsInStatusBarButton.state = [[VHGithubNotifierManager sharedManager] onlyShowsValidContentsInStatusBar];
}

#pragma mark - Actions - Status Bar

- (IBAction)onStatusBarContentChanged:(NSButton *)sender
{
    NSUInteger contents = 0;
    if (self.totalStargazersNumberButton.state)
    {
        contents |= VHStatusBarButtonContentTypeStargazers;
    }
    if (self.followersNumberButton.state)
    {
        contents |= VHStatusBarButtonContentTypeFollowers;
    }
    if (self.unreadNotificationsNumberButton.state)
    {
        contents |= VHStatusBarButtonContentTypeNotifications;
    }
    [[VHGithubNotifierManager sharedManager] setStatusBarButtonContents:contents];
    
    [[VHGithubNotifierManager sharedManager] setOnlyShowsValidContentsInStatusBar:self.onlyShowsValidContentsInStatusBarButton.state];
    
    NOTIFICATION_POST(kNotifyStatusBarButtonContentChanged);
}



@end
