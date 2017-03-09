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
#import "VHStateView.h"
#import "NSView+Position.h"
#import "VHCursorButton+AFNetworking.h"

@interface VHProfileVC ()<VHWebLoginWCDelegate, VHStateViewDelegate>

@property (weak) IBOutlet NSView *needLoginView;
@property (nonatomic, strong) VHWebLoginWC *webLoginWC;
@property (weak) IBOutlet VHContributionChartView *contributionChart;
@property (weak) IBOutlet NSTextField *yearContributionsLabel;
@property (weak) IBOutlet NSTextField *yearContributionsTimeLabel;
@property (weak) IBOutlet NSTextField *todayContributionsLabel;
@property (weak) IBOutlet NSTextField *todayContributionsTimeLabel;
@property (weak) IBOutlet VHStateView *stateView;
@property (weak) IBOutlet VHCursorButton *avatarButton;
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *accountLabel;

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
    [self setUI];
}

- (void)setUI
{
    [self.stateView setRetryText:@"Contributions loaded failed!"];
    [self.stateView setLoadingText:@"Loading contributions..."];
    
    switch ([[VHGithubNotifierManager sharedManager] contributionLoadState])
    {
        case VHLoadStateTypeLoading:
            self.stateView.state = VHStateViewStateTypeLoading;
            self.contributionChart.hidden = YES;
            break;
        case VHLoadStateTypeDidNotLoad:
        case VHLoadStateTypeLoadFailed:
            self.stateView.state = VHStateViewStateTypeLoadFailed;
            self.contributionChart.hidden = YES;
            break;
        case VHLoadStateTypeLoadSuccessfully:
            self.stateView.state = VHStateViewStateTypeLoadSuccessfully;
            [self updateContributionLabels];
            self.contributionChart.hidden = NO;
            break;
    }
    
    self.avatarButton.wantsLayer = YES;
    self.avatarButton.layer.cornerRadius = self.avatarButton.width / 2;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.toolTip = @"Click to visit profile in browser";
    
    [self setProfileUI];
}

- (void)setProfileUI
{
    [[[VHCursorButton sharedImageDownloader] imageCache] removeAllImages];
    [self.avatarButton setImageWithURL:[NSURL URLWithString:[VHGithubNotifierManager sharedManager].user.avatar]
                      placeholderImage:[NSImage imageNamed:@"icon_user_placeholder"]];
    [self.nameLabel setStringValue:AVOID_NIL_STRING([VHGithubNotifierManager sharedManager].user.name)];
    [self.accountLabel setStringValue:AVOID_NIL_STRING([VHGithubNotifierManager sharedManager].user.account)];
}

- (void)updateContributionLabels
{
    self.yearContributionsLabel.stringValue = [NSString stringWithFormat:@"%zd", [[VHGithubNotifierManager sharedManager] yearContributions]];
    [self.yearContributionsLabel sizeToFit];
    self.yearContributionsTimeLabel.stringValue = [[VHGithubNotifierManager sharedManager] yearContributionsTimeString];
    [self.yearContributionsTimeLabel sizeToFit];
    
    self.todayContributionsLabel.stringValue = [NSString stringWithFormat:@"%zd", [[VHGithubNotifierManager sharedManager] todayContributions]];
    [self.todayContributionsLabel sizeToFit];
    self.todayContributionsTimeLabel.stringValue = [[VHGithubNotifierManager sharedManager] todayContributionsTimeString];
    [self.todayContributionsTimeLabel sizeToFit];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyLoginCookieGotSuccessfully forSelector:@selector(onNotifyLoginCookieGotSuccessfully:)];
    [self addNotification:kNotifyLoginCookieGotFailed forSelector:@selector(onNotifyLoginCookieGotFailed:)];
    [self addNotification:kNotifyContributionBlocksLoadedSuccessfully forSelector:@selector(onNotifyContributionBlocksLoadedSuccessfully:)];
    [self addNotification:kNotifyContributionBlocksLoadedFailed forSelector:@selector(onNotifyContributionBlocksLoadedFailed:)];
    [self addNotification:kNotifyProfileLoadedSuccessfully forSelector:@selector(onNotifyProfileLoadedSuccessfully:)];
    [self addNotification:kNotifyContributionChartChanged forSelector:@selector(onNotifyContributionChartChanged:)];
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
    self.stateView.state = VHStateViewStateTypeLoadSuccessfully;
    self.contributionChart.hidden = NO;
    [self.contributionChart setNeedsDisplay:YES];
    [self updateContributionLabels];
}

- (void)onNotifyContributionBlocksLoadedFailed:(NSNotification *)notification
{
    self.stateView.state = VHStateViewStateTypeLoadFailed;
    self.contributionChart.hidden = YES;
}

- (void)onNotifyProfileLoadedSuccessfully:(NSNotification *)notificatio
{
    [self setProfileUI];
}

- (void)onNotifyContributionChartChanged:(NSNotification *)notification
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

- (IBAction)onAvatarClicked:(id)sender
{
    [VHUtils openUrl:[VHGithubNotifierManager sharedManager].user.htmlUrl];
}

#pragma mark - VHWebLoginWCDelegate

- (void)onWebLoginWindowClosed
{
    if ([[VHGithubNotifierManager sharedManager] loginCookieExist:NO])
    {
        NetLog(@"Logged in successfully through web view.");
    }
}

#pragma mark - VHStateViewDelegate

- (void)onRetryButtonClicked
{
    [[VHGithubNotifierManager sharedManager] updateProfile];
}

@end
