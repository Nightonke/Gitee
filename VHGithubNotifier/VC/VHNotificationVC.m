//
//  VHNotificationVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/19.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationVC.h"
#import "VHStateView.h"
#import "VHGithubNotifierManager+Notification.h"

@interface VHNotificationVC ()<NSTableViewDelegate, NSTableViewDataSource, VHStateViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet VHStateView *stateView;

@end

@implementation VHNotificationVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNotifications];
    
    self.stateView.delegate = self;
    [self setUIState];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
}

- (void)setUIState
{
    switch ([[VHGithubNotifierManager sharedManager] notificationLoadState])
    {
        case VHLoadStateTypeLoading:
            [self.scrollView setHidden:YES];
            [self.stateView setState:VHStateViewStateTypeLoading];
            break;
        case VHLoadStateTypeDidNotLoad:
        case VHLoadStateTypeLoadFailed:
            [self onNotifyNotificationsLoadedFailed:nil];
            break;
        case VHLoadStateTypeLoadSuccessfully:
            [self onNotifyNotificationsLoadedSuccessfully:nil];
            break;
    }
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyNotificationsLoadedSuccessfully forSelector:@selector(onNotifyNotificationsLoadedSuccessfully:)];
    [self addNotification:kNotifyNotificationsLoadedFailed forSelector:@selector(onNotifyNotificationsLoadedFailed:)];
}

- (void)onNotifyNotificationsLoadedSuccessfully:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
    [self.scrollView setHidden:NO];
    [self.tableView reloadData];
    [self.scrollView.documentView scrollPoint:NSMakePoint(0, 0)];
}

- (void)onNotifyNotificationsLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Notifications loaded failed!"];
    [self.scrollView setHidden:YES];
}

#pragma mark - VHStateViewDelegate

- (void)onRetryButtonClicked
{
    [[VHGithubNotifierManager sharedManager] updateNotification];
}

@end
