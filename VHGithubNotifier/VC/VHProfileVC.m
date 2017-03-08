    //
//  VHProfileVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/29.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHProfileVC.h"
#import "VHSettingsWC.h"
#import "VHCursorButton.h"
#import "VHWebLoginWC.h"
#import "VHGithubNotifierManager+Profile.h"
#import "VHUtils.h"
#import "VHContributionChartView.h"

@interface VHProfileVC ()<VHWebLoginWCDelegate>

@property (weak) IBOutlet NSView *needLoginView;
@property (nonatomic, strong) VHWebLoginWC *webLoginWC;
@property (weak) IBOutlet VHContributionChartView *contributionChart;

@end

@implementation VHProfileVC

#pragma mark - Life

- (void)loadView
{
    [super loadView];

    if ([[VHGithubNotifierManager sharedManager] loginCookieExist:NO])
    {
        self.needLoginView.hidden = YES;
    }
    else
    {
        self.needLoginView.hidden = NO;
    }
    
    [self addNotifications];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyLoginCookieGotSuccessfully forSelector:@selector(onNotifyLoginCookieGotSuccessfully:)];
    [self addNotification:kNotifyLoginCookieGotFailed forSelector:@selector(onNotifyLoginCookieGotFailed:)];
    [self addNotification:kNotifyContributionBlocksLoadedSuccessfully forSelector:@selector(onNotifyContributionBlocksLoadedSuccessfully:)];
}

- (void)onNotifyLoginCookieGotSuccessfully:(NSNotification *)notification
{
    self.needLoginView.hidden = YES;
}

- (void)onNotifyLoginCookieGotFailed:(NSNotification *)notification
{
    self.needLoginView.hidden = NO;
}

- (void)onNotifyContributionBlocksLoadedSuccessfully:(NSNotification *)notification
{
    [self.contributionChart setNeedsDisplay:YES];
}

#pragma mark - Actions

- (IBAction)onLoginButtonClicked:(id)sender
{
    NOTIFICATION_POST(kNotifyWindowShouldHide);
    if (self.webLoginWC == nil)
    {
        self.webLoginWC = [[VHWebLoginWC alloc] initWithWindowNibName:@"VHWebLoginWC"];
    }
    [self.webLoginWC showWindow:self];
}

#pragma mark - VHWebLoginWCDelegate

- (void)onWebLoginWindowClosed
{
    if ([[VHGithubNotifierManager sharedManager] loginCookieExist:NO])
    {
        NetLog(@"Logged in successfully through web view.");
    }
}

@end
