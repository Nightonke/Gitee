//
//  VHWebLoginWC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHWebLoginWC.h"
#import "NSView+Position.h"
#import <WebKit/WebKit.h>
#import "VHUtils.h"
#import "VHGithubNotifierManager+Profile.h"

@interface VHWebLoginWC ()<WKNavigationDelegate>

@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *progressLabel;
@property (nonatomic, strong) WKWebView *webView;
@property (weak) IBOutlet NSVisualEffectView *visualEffectView;

@end

@implementation VHWebLoginWC

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
    
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, self.visualEffectView.width, self.visualEffectView.height - 37) configuration:configuration];
    self.webView.wantsLayer = YES;
    self.webView.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.webView.enclosingScrollView.backgroundColor = [NSColor clearColor];
    self.webView.enclosingScrollView.hasVerticalScroller = NO;
    [self.webView setValue:@(YES) forKey:@"drawsTransparentBackground"];
    self.webView.navigationDelegate = self;
    [self.visualEffectView addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/login"]]];
    
    [self.progress startAnimation:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.progress.hidden = YES;
    self.progressLabel.hidden = YES;
    if ([[VHGithubNotifierManager sharedManager] loginCookieExist:YES])
    {
        [self.window close];
    }
}

#pragma mark - Private Methods

- (void)showWindow:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
    [super showWindow:sender];
}

- (void)windowWillClose
{
    if (self.webLoginDelegate && [self.webLoginDelegate respondsToSelector:@selector(onWebLoginWindowClosed)])
    {
        [self.webLoginDelegate onWebLoginWindowClosed];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
