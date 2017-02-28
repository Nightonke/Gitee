//
//  VHNotificationVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/19.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotificationVC.h"
#import "VHStateView.h"

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
    // Do view setup here.
}

@end
