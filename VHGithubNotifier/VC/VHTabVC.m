//
//  VHTabVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHTabVC.h"
#import "VHTabVCBackgroundView.h"
#import "VHTabView.h"
#import "VHProfileVC.h"
#import "VHPieVC.h"
#import "VHTrendVC.h"
#import "VHTrendingVC.h"
#import "VHNotificationVC.h"
#import "VHSettingsVC.h"

@interface VHTabVC ()<VHTabViewDelegate>

@property (nonatomic, assign) CGFloat statusItemCenterX;
@property (nonatomic, strong) VHTabVCBackgroundView *backgroundView;
@property (weak) IBOutlet NSTabView *tab;
@property (weak) IBOutlet VHTabView *vhTabView;

@property (nonatomic, strong) VHProfileVC *profileVC;
@property (nonatomic, strong) VHPieVC *pieVC;
@property (nonatomic, strong) VHTrendVC *trendVC;
@property (nonatomic, strong) VHTrendingVC *trendingVC;
@property (nonatomic, strong) VHNotificationVC *notificationVC;
@property (nonatomic, strong) VHSettingsVC *settingsVC;

@end

@implementation VHTabVC

- (void)loadView
{
    [super loadView];
    
    NSTabViewItem *profileItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeProfile]];
    self.profileVC = [[VHProfileVC alloc] initWithNibName:@"VHProfileVC" bundle:nil];
    profileItem.view = self.profileVC.view;
    [self.tab addTabViewItem:profileItem];
    
    NSTabViewItem *pieItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeRepositoryPie]];
    self.pieVC = [[VHPieVC alloc] initWithNibName:@"VHPieVC" bundle:nil];
    pieItem.view = self.pieVC.view;
    [self.tab addTabViewItem:pieItem];
    
    NSTabViewItem *trendItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeTrend]];
    self.trendVC = [[VHTrendVC alloc] initWithNibName:@"VHTrendVC" bundle:nil];
    trendItem.view = self.trendVC.view;
    [self.tab addTabViewItem:trendItem];
    
    NSTabViewItem *trendingItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeTrending]];
    self.trendingVC = [[VHTrendingVC alloc] initWithNibName:@"VHTrendingVC" bundle:nil];
    trendingItem.view = self.trendingVC.view;
    [self.tab addTabViewItem:trendingItem];
    
    NSTabViewItem *notificationItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeNotifications]];
    self.notificationVC = [[VHNotificationVC alloc] initWithNibName:@"VHNotificationVC" bundle:nil];
    notificationItem.view = self.notificationVC.view;
    [self.tab addTabViewItem:notificationItem];
    
    NSTabViewItem *settingsItem = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", VHGithubContentTypeSettings]];
    self.settingsVC = [[VHSettingsVC alloc] initWithNibName:@"VHSettingsVC" bundle:nil];
    settingsItem.view = self.settingsVC.view;
    [self.tab addTabViewItem:settingsItem];
    
    self.vhTabView.delegate = self;
}

- (void)updateArrowWithStatusItemCenterX:(CGFloat)centerX
{
    self.statusItemCenterX = centerX;
    VHTabVCBackgroundView *backgroundView = (VHTabVCBackgroundView *)SAFE_CAST(self.view, [VHTabVCBackgroundView class]);
    if (backgroundView != nil)
    {
        [backgroundView updateArrowWithStatusItemCenterX:centerX];
        [backgroundView setNeedsDisplay:YES];
    }
}

#pragma mark - VHTabViewDelegate

- (void)didSelectGithubContentType:(VHGithubContentType)type
{
    [self.tab selectTabViewItemAtIndex:log(type) / log(2)];
}

@end
