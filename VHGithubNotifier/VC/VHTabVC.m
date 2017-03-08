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
#import "VHCursorButton.h"
#import "VHSettingsWC.h"
#import "NSView+Position.h"
#import "NSImage+Tint.h"
#import "VHGithubNotifier-Swift.h"

@interface VHTabVC ()<VHTabViewDelegate, VHSettingsWCDelegate>

@property (nonatomic, assign) CGFloat statusItemCenterX;
@property (nonatomic, strong) VHTabVCBackgroundView *backgroundView;
@property (weak) IBOutlet NSTabView *tab;
@property (weak) IBOutlet VHTabView *vhTabView;
@property (weak) IBOutlet VHVisualEffectView *visualEffectView;

@property (nonatomic, strong) VHProfileVC *profileVC;
@property (nonatomic, strong) VHPieVC *pieVC;
@property (nonatomic, strong) VHTrendVC *trendVC;
@property (nonatomic, strong) VHTrendingVC *trendingVC;
@property (nonatomic, strong) VHNotificationVC *notificationVC;

@property (nonatomic, strong) VHCursorButton *settingsButton;
@property (nonatomic, strong) VHCursorButton *exitButton;

@property (nonatomic, strong) VHSettingsWC *settingsWC;

@end

@implementation VHTabVC

- (void)loadView
{
    [super loadView];
    
    [self addIcons];
    
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
    
    self.vhTabView.delegate = self;
}

- (void)addIcons
{
    CGFloat iconWidth = 30;
    self.settingsButton = [self iconWithImage:[NSImage imageNamed:@"icon_settings"] withTag:0];
    self.settingsButton.toolTip = @"Settings";
    self.exitButton = [self iconWithImage:[NSImage imageNamed:@"icon_exit"] withTag:0];
    self.exitButton.toolTip = @"Quit Gitee";
    self.exitButton.frame = NSMakeRect(self.vhTabView.getRight - iconWidth - 5, self.vhTabView.getTop, iconWidth, self.vhTabView.height);
    [self.view addSubview:self.exitButton];
    self.settingsButton.frame = NSMakeRect(self.exitButton.getLeft - iconWidth, self.exitButton.getTop, iconWidth, self.exitButton.height);
    [self.view addSubview:self.settingsButton];
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

#pragma mark - VHSettingsWCDelegate

- (void)onSettingsWindowClosed
{
    self.settingsWC = nil;
}

#pragma mark - Actions

- (void)onSettingsButtonClicked:(id)sender
{
    NOTIFICATION_POST(kNotifyWindowShouldHide);
    if (self.settingsWC == nil)
    {
        self.settingsWC = [[VHSettingsWC alloc] initWithWindowNibName:@"VHSettingsWC"];
        self.settingsWC.settingsWCDelegate = self;
    }
    [self.settingsWC showWindow:self];
}

- (void)onExitButtonClicked:(id)sender
{
    SystemLog(@"Terminate in profile vc");
    [NSApp terminate:nil];
}

- (void)onIconClicked:(VHCursorButton *)button
{
    if (button == self.settingsButton)
    {
        [self onSettingsButtonClicked:button];
    }
    else if (button == self.exitButton)
    {
        [self onExitButtonClicked:button];
    }
}

#pragma mark - Private Methods

- (VHCursorButton *)iconWithImage:(NSImage *)image withTag:(NSInteger)tag
{
    image = [image imageTintedWithColor:[NSColor whiteColor]];
    image.template = NO;
    image.size = NSMakeSize(20, 20);
    VHCursorButton *button = [[VHCursorButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [button setButtonType:NSButtonTypeMomentaryChange];
    button.bezelStyle = NSRoundRectBezelStyle;
    button.image = image;
    button.target = self;
    button.action = @selector(onIconClicked:);
    button.tag = tag;
    button.bordered = NO;
    return button;
}

@end
