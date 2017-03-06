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
#import "NSArray+Safe.h"
#import "VHNotificationGroupHeaderCellView.h"
#import "VHNotificationGroupBodyCellView.h"
#import "VHNotificationHeaderCellView.h"
#import "VHScroller.h"
#import "NSView+Position.h"
#import "VHUtils.h"

@interface VHNotificationVC ()<NSTableViewDelegate, NSTableViewDataSource, VHStateViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet VHStateView *stateView;
@property (nonatomic, strong) VHScroller *scroller;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *isLastBody;

@end

@implementation VHNotificationVC

#pragma mark - Life

- (void)loadView
{
    [super loadView];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNotifications];
    
    self.stateView.delegate = self;
    [self.stateView setLoadingText:@"Loading notifications..."];
    [self.stateView setEmptyText:@"No new notifications"];
    [self.stateView setEmptyImage:@"image_empty_notification"];
    [self setUIState];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHNotificationGroupHeaderCellView" bundle:nil]
                  forIdentifier:@"VHNotificationGroupHeaderCellView"];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHNotificationGroupBodyCellView" bundle:nil]
                  forIdentifier:@"VHNotificationGroupBodyCellView"];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHNotificationHeaderCellView" bundle:nil]
                  forIdentifier:@"VHNotificationHeaderCellView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    self.scrollView.automaticallyAdjustsContentInsets = NO;
    [self.scrollView setContentInsets:NSEdgeInsetsMake(0, 0, 10, 0)];
    
    self.scroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.view.width - 2, 10, 6, self.scrollView.height - 10)
                                       withImageFrame:NSMakeRect(0, self.scrollView.height - 60, 6, 60)
                                        withImageName:@"image_scroller"
                                 withPressedImageName:@"image_scroller_pressed"
                                       withScrollView:self.scrollView];
    self.scroller.wantsLayer = YES;
    self.scroller.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view addSubview:self.scroller];
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
    [self addNotification:kNotifyNotificationsChanged forSelector:@selector(onNotifyNotificationsChanged:)];
}

- (void)onNotifyNotificationsLoadedSuccessfully:(NSNotification *)notification
{
    [self createDataArray];
    if (self.dataArray.count == 0)
    {
        [self.stateView setState:VHStateViewStateTypeEmpty];
        [self.scrollView setHidden:YES];
    }
    else
    {
        [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
        [self.scrollView setHidden:NO];
        [self.tableView reloadData];
        [VHUtils scrollViewToTop:self.scrollView];
    }
}

- (void)onNotifyNotificationsLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Notifications loaded failed!"];
    [self.scrollView setHidden:YES];
}

- (void)onNotifyNotificationsChanged:(NSNotification *)notification
{
    [self createDataArray];
    if (self.dataArray.count == 0)
    {
        [self.stateView setState:VHStateViewStateTypeEmpty];
        [self.scrollView setHidden:YES];
    }
    else
    {
        [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
        [self.scrollView setHidden:NO];
        [self.tableView reloadData];
    }
}

#pragma mark - VHStateViewDelegate

- (void)onRetryButtonClicked
{
    [[VHGithubNotifierManager sharedManager] updateNotification];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.dataArray.count + 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (row == 0)
    {
        return 46;
    }
    VHSimpleRepository *repository = SAFE_CAST([self.dataArray safeObjectAtIndex:row - 1], [VHSimpleRepository class]);
    if (repository)
    {
        return 46;
    }
    else
    {
        return 40;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == 0)
    {
        VHNotificationHeaderCellView *cell = [tableView makeViewWithIdentifier:@"VHNotificationHeaderCellView" owner:self];
        [cell setNotificationNumber:[[VHGithubNotifierManager sharedManager] notificationNumber]];
        return cell;
    }
    VHSimpleRepository *repository = SAFE_CAST([self.dataArray safeObjectAtIndex:row - 1], [VHSimpleRepository class]);
    VHNotification *notification = SAFE_CAST([self.dataArray safeObjectAtIndex:row - 1], [VHNotification class]);
    NSNumber *isLastBody = SAFE_CAST([self.isLastBody safeObjectAtIndex:row - 1], [NSNumber class]);
    if (repository)
    {
        VHNotificationGroupHeaderCellView *cell = [tableView makeViewWithIdentifier:@"VHNotificationGroupHeaderCellView" owner:self];
        [cell setRepository:repository];
        [cell setNotificationNumber:[[VHGithubNotifierManager sharedManager].notificationDic objectForKey:repository].count];
        return cell;
    }
    else if (notification)
    {
        VHNotificationGroupBodyCellView *cell = [tableView makeViewWithIdentifier:@"VHNotificationGroupBodyCellView" owner:self];
        [cell setNotification:notification];
        [cell setIsLastBody:[isLastBody boolValue]];
        return cell;
    }
    return nil;
}

- (void)createDataArray
{
    __block NSMutableArray *mDataArray = [NSMutableArray array];
    [[[VHGithubNotifierManager sharedManager] notificationDic] enumerateKeysAndObjectsUsingBlock:^(VHSimpleRepository * _Nonnull repository, NSArray<VHNotification *> * _Nonnull notifications, BOOL * _Nonnull stop) {
        [mDataArray addObject:repository];
        [mDataArray addObjectsFromArray:notifications];
    }];
    self.dataArray = [mDataArray copy];
    
    mDataArray = [NSMutableArray arrayWithCapacity:self.dataArray.count];
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mDataArray addObject:@(NO)];
    }];
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == self.dataArray.count - 1
            || [[self.dataArray objectAtIndex:idx + 1] isKindOfClass:[VHSimpleRepository class]])
        {
            [mDataArray setObject:@(YES) atIndexedSubscript:idx];
        }
    }];
    self.isLastBody = [mDataArray copy];
}

@end
