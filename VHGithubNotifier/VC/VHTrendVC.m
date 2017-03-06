//
//  VHTrendVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/13.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendVC.h"
#import "VHRepository.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Trend.h"
#import "VHGithubNotifier-Bridging-Header.h"
#import "VHDateValueFormatter.h"
#import "VHUtils.h"
#import <WebKit/WebKit.h>
#import "NSView+Position.h"

@interface VHTrendVC()<NSTableViewDelegate, NSTableViewDataSource, WKUIDelegate>

@property (weak) IBOutlet NSPopUpButton *trendPopupButton;
@property (weak) IBOutlet NSButton *anyTimeRadioButton;
@property (weak) IBOutlet NSButton *dayRadioButton;
@property (weak) IBOutlet NSButton *weekRadioButton;
@property (weak) IBOutlet NSButton *monthRadioButton;
@property (weak) IBOutlet NSButton *yearRadioButton;

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation VHTrendVC

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
    
    self.selectedIndex = [[VHGithubNotifierManager sharedManager] trendContentSelectedIndex];
    
    [self setSelectedTimeTypeRadioButton];
    
    [self addNotifications];
    
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(5, -10, self.view.width, self.anyTimeRadioButton.y - 5) configuration:theConfiguration];
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    [self onNotifyRepositoriesLoadedSuccessfully:nil];
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyRepositoriesLoadedSuccessfully:)
                                                 name:kNotifyRepositoriesLoadedSuccessfully
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNotifyRepositoriesLoadedSuccessfully:(NSNotification *)notification
{
    [[VHGithubNotifierManager sharedManager] updateTrendData];
    [self.trendPopupButton.menu removeAllItems];
    [self.trendPopupButton.menu addItemWithTitle:[NSString stringWithFormat:@"Followers of %@", [VHGithubNotifierManager sharedManager].user.name] action:nil keyEquivalent:@""];
    [self.trendPopupButton.menu addItemWithTitle:[NSString stringWithFormat:@"Stars of %@", [VHGithubNotifierManager sharedManager].user.name] action:nil keyEquivalent:@""];
    for (VHRepository *repository in [VHGithubNotifierManager sharedManager].trendDatas)
    {
        [self.trendPopupButton.menu addItemWithTitle:repository.name action:nil keyEquivalent:@""];
    }
    if (self.selectedIndex >= self.trendPopupButton.numberOfItems)
    {
        self.selectedIndex = 0;
    }
    [self.trendPopupButton selectItemAtIndex:self.selectedIndex];
    [self onTrendDataSelected:self.trendPopupButton];
}

#pragma mark - Actions

- (IBAction)onTrendDataSelected:(NSPopUpButton *)sender
{
    self.selectedIndex = self.trendPopupButton.indexOfSelectedItem;
    [[VHGithubNotifierManager sharedManager] setTrendContentSelectedIndex:self.selectedIndex];
    [[VHGithubNotifierManager sharedManager] loadTrendChartInWebView:self.webView
                                               withTrendContentIndex:self.selectedIndex
                                                           withTitle:[self.trendPopupButton.menu itemAtIndex:self.selectedIndex].title];
}

- (IBAction)onTimeTypeChanged:(NSButton *)radioButton
{
    [[VHGithubNotifierManager sharedManager] setTrendTimeType:radioButton.tag];
    [self onTrendDataSelected:nil];
}



#pragma mark - Private Methods

- (void)setSelectedTimeTypeRadioButton
{
    VHGithubTrendTimeType timeType = [[VHGithubNotifierManager sharedManager] trendTimeType];
    NSMutableArray<NSButton *> *radioButtons = [NSMutableArray array];
    [radioButtons addObject:self.anyTimeRadioButton];
    [radioButtons addObject:self.dayRadioButton];
    [radioButtons addObject:self.weekRadioButton];
    [radioButtons addObject:self.monthRadioButton];
    [radioButtons addObject:self.yearRadioButton];
    [radioButtons enumerateObjectsUsingBlock:^(NSButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == timeType)
        {
            obj.state = NSOnState;
            *stop = YES;
        }
    }];
}

@end
