//
//  VHTrendingVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/19.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingVC.h"
#import "VHStateView.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+Language.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHTrendingRepositoryCellView.h"
#import "NSArray+Safe.h"
#import "NSView+Position.h"
#import "VHScroller.h"

@interface VHTrendingVC ()<NSTableViewDelegate, NSTableViewDataSource, VHStateViewDelegate, VHTrendingRepositoryCellViewDelegate>

@property (weak) IBOutlet NSPopUpButton *languagePopupButton;
@property (weak) IBOutlet NSPopUpButton *timePopupButton;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet VHStateView *stateView;
@property (nonatomic, strong) VHScroller *scroller;

@property (nonatomic, assign) NSUInteger languageSelectedIndex;
@property (nonatomic, assign) NSUInteger timeSelectedIndex;

@end

@implementation VHTrendingVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.languageSelectedIndex = [[VHGithubNotifierManager sharedManager] trendingContentSelectedIndex];
    self.timeSelectedIndex = [[VHGithubNotifierManager sharedManager] trendingTimeSelectedIndex];
    
    [self addNotifications];
    
    self.stateView.delegate = self;
    [self setUIState];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHTrendingRepositoryCellView" bundle:nil]
                  forIdentifier:@"VHTrendingRepositoryCellView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    
    self.scroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.view.width - 44, 0, 48, self.scrollView.height)
                                       withImageFrame:NSMakeRect(0, self.scrollView.height - 48, 48, 48)
                                        withImageName:@"icon_scroller"
                                       withScrollView:self.scrollView];
    [self.view addSubview:self.scroller];
}

- (void)setUIState
{
    [self.timePopupButton.menu removeAllItems];
    [self.timePopupButton.menu addItemWithTitle:@"Today" action:nil keyEquivalent:@""];
    [self.timePopupButton.menu addItemWithTitle:@"This week" action:nil keyEquivalent:@""];
    [self.timePopupButton.menu addItemWithTitle:@"This month" action:nil keyEquivalent:@""];
    
    switch ([[VHGithubNotifierManager sharedManager] languagesLoadState])
    {
        case VHLoadStateTypeLoading:
            [self setLoadingUIStateForLanguage];
            break;
        case VHLoadStateTypeDidNotLoad:
        case VHLoadStateTypeLoadFailed:
            [self onNotifyLanguageLoadedFailed:nil];
            break;
        case VHLoadStateTypeLoadSuccessfully:
            [self onNotifyLanguageLoadedSuccessfully:nil];
            [self setUIStateForTrendingContent];
            break;
    }
}

- (void)setUIStateForTrendingContent
{
    switch ([[VHGithubNotifierManager sharedManager] trendingContentLoadState])
    {
        case VHLoadStateTypeLoading:
            [self setLoadingUIStateForTrending];
            break;
        case VHLoadStateTypeDidNotLoad:
        case VHLoadStateTypeLoadFailed:
            [self onNotifyTrendingLoadedFailed:nil];
            break;
        case VHLoadStateTypeLoadSuccessfully:
            [self onNotifyTrendingLoadedSuccessfully:nil];
            break;
    }
}

- (void)setLoadingUIStateForLanguage
{
    [self.languagePopupButton setHidden:YES];
    [self.timePopupButton setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.stateView setState:VHStateViewStateTypeLoading];
}

- (void)setLoadingUIStateForTrending
{
    [self.scrollView setHidden:YES];
    [self.stateView setState:VHStateViewStateTypeLoading];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyLanguageLoadedSuccessfully forSelector:@selector(onNotifyLanguageLoadedSuccessfully:)];
    [self addNotification:kNotifyLanguageLoadedFailed forSelector:@selector(onNotifyLanguageLoadedFailed:)];
    [self addNotification:kNotifyTrendingLoadedSuccessfully forSelector:@selector(onNotifyTrendingLoadedSuccessfully:)];
    [self addNotification:kNotifyTrendingLoadedFailed forSelector:@selector(onNotifyTrendingLoadedFailed:)];
}

- (void)onNotifyLanguageLoadedSuccessfully:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
    [self.languagePopupButton setHidden:NO];
    [self.timePopupButton setHidden:NO];
    [self.scrollView setHidden:YES];
    
    [self.languagePopupButton.menu removeAllItems];
    
    [self.languagePopupButton.menu addItemWithTitle:@"All languages" action:nil keyEquivalent:@""];
    [self.languagePopupButton.menu addItemWithTitle:@"Unknown languages" action:nil keyEquivalent:@""];
    [[VHGithubNotifierManager sharedManager].languages enumerateObjectsUsingBlock:^(VHLanguage * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.languagePopupButton.menu addItemWithTitle:language.name action:nil keyEquivalent:@""];
    }];
    
    if (self.languageSelectedIndex >= self.languagePopupButton.numberOfItems)
    {
        self.languageSelectedIndex = 0;
    }
    [self.languagePopupButton selectItemAtIndex:self.languageSelectedIndex];
    
    if (self.timeSelectedIndex >= self.timePopupButton.numberOfItems)
    {
        self.timeSelectedIndex = 0;
    }
    [self.timePopupButton selectItemAtIndex:self.timeSelectedIndex];
}

- (void)onNotifyLanguageLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Languages loaded failed!"];
    [self.languagePopupButton setHidden:YES];
    [self.timePopupButton setHidden:YES];
    [self.scrollView setHidden:YES];
}

- (void)onNotifyTrendingLoadedSuccessfully:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
    [self.languagePopupButton setHidden:NO];
    [self.timePopupButton setHidden:NO];
    [self.scrollView setHidden:NO];
    
    [self.tableView reloadData];
    [self.scrollView.documentView scrollPoint:NSMakePoint(0, 0)];
}

- (void)onNotifyTrendingLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Trendings loaded failed!"];
    [self.languagePopupButton setHidden:NO];
    [self.timePopupButton setHidden:NO];
    [self.scrollView setHidden:YES];
}

#pragma mark - VHStateViewDelegate

- (void)onRetryButtonClicked
{
    if ([[VHGithubNotifierManager sharedManager] languagesLoadState] == VHLoadStateTypeLoadFailed)
    {
        [[VHGithubNotifierManager sharedManager] updateLanguages];
        [self setUIState];
    }
    else
    {
        [[VHGithubNotifierManager sharedManager] updateTrendingContent];
        [self setUIStateForTrendingContent];
    }
}

#pragma mark - Actions

- (IBAction)onTrendingContentSelected:(NSPopUpButton *)sender
{
    [[VHGithubNotifierManager sharedManager] setTrendingContentSelectedIndex:sender.indexOfSelectedItem];
    [[VHGithubNotifierManager sharedManager] updateTrendingContent];
    [self setLoadingUIStateForTrending];
}

- (IBAction)onTrendingTimeSelected:(NSPopUpButton *)sender
{
    [[VHGithubNotifierManager sharedManager] setTrendingTimeSelectedIndex:sender.indexOfSelectedItem];
    [[VHGithubNotifierManager sharedManager] updateTrendingContent];
    [self setLoadingUIStateForTrending];
}

#pragma mark - VHTrendingRepositoryCellViewDelegate

- (void)onTrendingClicked:(VHTrendingRepository *)repository
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:repository.url]];
    NOTIFICATION_POST(kNotifyWindowShouldHide);
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [VHGithubNotifierManager sharedManager].trendingRepositories.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    VHTrendingRepositoryCellView *cell = [tableView makeViewWithIdentifier:@"VHTrendingRepositoryCellView" owner:self];
    [cell setTrendingRepository:[[VHGithubNotifierManager sharedManager].trendingRepositories safeObjectAtIndex:row]];
    [cell setIsLastRow:row == [self numberOfRowsInTableView:tableView] - 1];
    [cell setDelegate:self];
    return cell;
}

@end
