//
//  VHSettingsCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSettingsCellView.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Profile.h"
#import "VHGithubNotifierManager+Language.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHGithubNotifierManager+Notification.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHCursorButton.h"
#import "VHUtils.h"

@interface VHSettingsCellView ()

#pragma mark Status Bar

@property (weak) IBOutlet NSButton *totalStargazersNumberButton;
@property (weak) IBOutlet NSButton *followersNumberButton;
@property (weak) IBOutlet NSButton *unreadNotificationsNumberButton;
@property (weak) IBOutlet NSButton *onlyShowsValidContentsInStatusBarButton;

#pragma mark Contents

@property (nonatomic, assign) NSTimeInterval basicInfoUpdateTime;
@property (weak) IBOutlet NSTextField *basicInfoUpdateTimeLabel;
@property (weak) IBOutlet NSSlider *basicInfoUpdateTimeSlider;
@property (nonatomic, assign) NSTimeInterval contributionUpdateTime;
@property (weak) IBOutlet NSTextField *contributionUpdateTimeLabel;
@property (weak) IBOutlet NSSlider *contributionUpdateTimeSlider;
@property (nonatomic, assign) NSTimeInterval languagesUpdateTime;
@property (weak) IBOutlet NSTextField *languagesUpdateTimeLabel;
@property (weak) IBOutlet NSSlider *languagesUpdateTimeSlider;
@property (nonatomic, assign) NSTimeInterval trendingUpdateTime;
@property (weak) IBOutlet NSTextField *trendingUpdateTimeLabel;
@property (weak) IBOutlet NSSlider *trendingUpdateTimeSlider;
@property (nonatomic, assign) NSTimeInterval notificationsUpdateTime;
@property (weak) IBOutlet NSTextField *notificationsUpdateTimeLabel;
@property (weak) IBOutlet NSSlider *notificationsUpdateTimeSlider;

@property (nonatomic, assign) VHGithubWeekStartFrom weekStartsFrom;
@property (weak) IBOutlet NSButton *weekStartsFromSundayButton;
@property (weak) IBOutlet NSButton *weekStartsFromMondayButton;

@property (nonatomic, assign) NSUInteger starLeast;
@property (weak) IBOutlet NSTextField *starLeastLabel;
@property (weak) IBOutlet NSSlider *starLeastSlider;

@property (weak) IBOutlet NSPathControl *realmPathView;
@property (weak) IBOutlet NSButton *viewRealmFileButton;

@end

@implementation VHSettingsCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initSettingsForStatusBar];
    [self initSettingsForContents];
}

- (void)updateSettings
{
    if (self.basicInfoUpdateTime != [[VHGithubNotifierManager sharedManager] basicInfoUpdateTime])
    {
        SettingsLog(@"Basic info update time changed from %f to %f", self.basicInfoUpdateTime, [[VHGithubNotifierManager sharedManager] basicInfoUpdateTime]);
        [[VHGithubNotifierManager sharedManager] updateBasicInfo];
    }
    else if (self.contributionUpdateTime != [[VHGithubNotifierManager sharedManager] profileUpdateTime])
    {
        SettingsLog(@"Contribution update time changed from %f to %f", self.contributionUpdateTime, [[VHGithubNotifierManager sharedManager] profileUpdateTime]);
        [[VHGithubNotifierManager sharedManager] updateProfile];
    }
    else if (self.languagesUpdateTime != [[VHGithubNotifierManager sharedManager] languageUpdateTime])
    {
        SettingsLog(@"Language update time changed from %f to %f", self.languagesUpdateTime, [[VHGithubNotifierManager sharedManager] languageUpdateTime]);
        [[VHGithubNotifierManager sharedManager] updateLanguages];
    }
    else if (self.trendingUpdateTime != [[VHGithubNotifierManager sharedManager] trendingUpdateTime])
    {
        SettingsLog(@"Trending update time changed from %f to %f", self.trendingUpdateTime, [[VHGithubNotifierManager sharedManager] trendingUpdateTime]);
        [[VHGithubNotifierManager sharedManager] updateTrending];
    }
    else if (self.notificationsUpdateTime != [[VHGithubNotifierManager sharedManager] notificationUpdateTime])
    {
        SettingsLog(@"Notification update time changed from %f to %f", self.notificationsUpdateTime, [[VHGithubNotifierManager sharedManager] notificationUpdateTime]);
        [[VHGithubNotifierManager sharedManager] updateNotification];
    }
    
    if (self.weekStartsFrom != [[VHGithubNotifierManager sharedManager] weekStartFrom])
    {
        SettingsLog(@"Week-starts-from changed from %zd to %zd", self.weekStartsFrom, [[VHGithubNotifierManager sharedManager] weekStartFrom]);
        [[VHGithubNotifierManager sharedManager] updateContributionChartLocally];
        NOTIFICATION_POST(kNotifyWeekStartsFromChanged);
    }
    
    if (self.starLeast != [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie])
    {
        SettingsLog(@"Minimum star number in pie changed from %zd to %zd", self.starLeast, [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]);
        NOTIFICATION_POST(kNotifyMinimumStarNumberInPieChanged);
    }
}

#pragma mark - Actions - Status Bar

- (void)initSettingsForStatusBar
{
    NSUInteger contents = [[VHGithubNotifierManager sharedManager] statusBarButtonContents];
    self.totalStargazersNumberButton.state = contents & VHStatusBarButtonContentTypeStargazers;
    self.followersNumberButton.state = contents & VHStatusBarButtonContentTypeFollowers;
    self.unreadNotificationsNumberButton.state = contents & VHStatusBarButtonContentTypeNotifications;
    
    self.onlyShowsValidContentsInStatusBarButton.state = [[VHGithubNotifierManager sharedManager] onlyShowsValidContentsInStatusBar];
}

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

#pragma mark - Actions - Contents

- (void)initSettingsForContents
{
    NSTimeInterval updateTime;
    
    updateTime = [[VHGithubNotifierManager sharedManager] basicInfoUpdateTime];
    [self.basicInfoUpdateTimeSlider setDoubleValue:updateTime / 60 / 5];
    [self.basicInfoUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    self.basicInfoUpdateTime = updateTime;
    
    updateTime = [[VHGithubNotifierManager sharedManager] profileUpdateTime];
    [self.contributionUpdateTimeSlider setDoubleValue:updateTime / 60 / 5];
    [self.contributionUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    self.contributionUpdateTime = updateTime;
    
    updateTime = [[VHGithubNotifierManager sharedManager] languageUpdateTime];
    [self.languagesUpdateTimeSlider setDoubleValue:updateTime / 60 / 60];
    [self.languagesUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    self.languagesUpdateTime = updateTime;
    
    updateTime = [[VHGithubNotifierManager sharedManager] trendingUpdateTime];
    [self.trendingUpdateTimeSlider setDoubleValue:updateTime / 60 / 5];
    [self.trendingUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    self.trendingUpdateTime = updateTime;
    
    updateTime = [[VHGithubNotifierManager sharedManager] notificationUpdateTime];
    [self.notificationsUpdateTimeSlider setDoubleValue:updateTime / 60 / 5];
    [self.notificationsUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    self.notificationsUpdateTime = updateTime;
    
    self.weekStartsFrom = [[VHGithubNotifierManager sharedManager] weekStartFrom];
    if (self.weekStartsFrom == VHGithubWeekStartFromSunDay)
    {
        self.weekStartsFromSundayButton.state = NSOnState;
    }
    else if (self.weekStartsFrom == VHGithubWeekStartFromMonDay)
    {
        self.weekStartsFromMondayButton.state = NSOnState;
    }
    
    NSUInteger starLeast = [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie];
    [self.starLeastSlider setDoubleValue:starLeast / 10];
    [self.starLeastLabel setStringValue:[self stringFromStarNumber:starLeast]];
    self.starLeast = starLeast;
    
    [self.realmPathView setURL:[[VHGithubNotifierManager sharedManager] realmDirectory]];
}

- (IBAction)onContentsSliderValueChanged:(NSSlider *)sender
{
    sender.doubleValue = round(sender.doubleValue);
    NSTimeInterval updateTime = sender.doubleValue * 5 * 60;
    
    if (sender == self.basicInfoUpdateTimeSlider)
    {
        [[VHGithubNotifierManager sharedManager] setBasicInfoUpdateTime:updateTime];
        [self.basicInfoUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    }
    else if (sender == self.contributionUpdateTimeSlider)
    {
        [[VHGithubNotifierManager sharedManager] setProfileUpdateTime:updateTime];
        [self.contributionUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    }
    else if (sender == self.languagesUpdateTimeSlider)
    {
        updateTime = sender.doubleValue * 60 * 60;
        [[VHGithubNotifierManager sharedManager] setLanguageUpdateTime:updateTime];
        [self.languagesUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    }
    else if (sender == self.trendingUpdateTimeSlider)
    {
        [[VHGithubNotifierManager sharedManager] setTrendingUpdateTime:updateTime];
        [self.trendingUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    }
    else if (sender == self.notificationsUpdateTimeSlider)
    {
        [[VHGithubNotifierManager sharedManager] setNotificationUpdateTime:updateTime];
        [self.notificationsUpdateTimeLabel setStringValue:[self stringFromTimeInterval:updateTime]];
    }
}

- (IBAction)onContentWeekStartsFromChanged:(NSButton *)sender
{
    if (self.weekStartsFromSundayButton.state == NSOnState)
    {
        [[VHGithubNotifierManager sharedManager] setWeekStartFrom:VHGithubWeekStartFromSunDay];
    }
    else if (self.weekStartsFromMondayButton.state == NSOnState)
    {
        [[VHGithubNotifierManager sharedManager] setWeekStartFrom:VHGithubWeekStartFromMonDay];
    }
}

- (IBAction)onContentStarLeastChanged:(id)sender
{
    self.starLeastSlider.doubleValue = round(self.starLeastSlider.doubleValue);
    NSUInteger starLeast = [self.starLeastSlider doubleValue] * 10;
    [[VHGithubNotifierManager sharedManager] setMinimumStarNumberInPie:starLeast];
    [self.starLeastLabel setStringValue:[self stringFromStarNumber:starLeast]];
}

- (IBAction)onViewRealmFileButtonClicked:(id)sender
{
    [VHUtils openURL:[[VHGithubNotifierManager sharedManager] realmDirectory]];
}

#pragma mark - Actions - Libraries

- (IBAction)onAFNetworkingClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/AFNetworking/AFNetworking"];
}

- (IBAction)onRealmClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/realm/realm-cocoa"];
}

- (IBAction)onUAGithubEngineeClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/owainhunt/UAGithubEngine"];
}

- (IBAction)onHppleClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/topfunky/hpple"];
}

- (IBAction)onCNUserNotificationClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/phranck/CNUserNotification"];
}

- (IBAction)onYAMLFrameworkClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/mirek/YAML.framework"];
}

- (IBAction)onSYFlatButtonClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/Sunnyyoung/SYFlatButton"];
}

- (IBAction)onChartsClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/danielgindi/Charts"];
}

- (IBAction)onEChartsClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/ecomfe/echarts"];
}

#pragma mark - Actions Developer

- (IBAction)onNightonkeClicked:(id)sender
{
    [VHUtils openUrl:@"http://huangweiping.me/"];
}

#pragma mark - Actions Gitee

- (IBAction)onGiteeClicked:(id)sender
{
    [VHUtils openUrl:@"https://github.com/Nightonke/Gitee"];
}

#pragma mark - Private Methods

- (NSString *)stringFromTimeInterval:(NSTimeInterval)time
{
    int hour = ((int)time) / 3600;
    int minute = (((int)time) / 60) % 60;
    NSString *hourString = @"";
    NSString *minuteString = @"";
    
    if (hour == 1)
    {
        hourString = [NSString stringWithFormat:@"an hour"];
    }
    else if (hour > 1)
    {
        hourString = [NSString stringWithFormat:@"%d hours", hour];
    }
    
    if (minute == 1)
    {
        minuteString = [NSString stringWithFormat:@"a minute"];
    }
    else if (minute > 1)
    {
        minuteString = [NSString stringWithFormat:@"%d minutes", minute];
    }
    
    return [NSString stringWithFormat:@"%@ %@", hourString, minuteString];
}

- (NSString *)stringFromStarNumber:(double)starNumber
{
    if (starNumber == 1)
    {
        return @"1 star";
    }
    else
    {
        return [NSString stringWithFormat:@"%.0lf stars", starNumber];
    }
}

@end
