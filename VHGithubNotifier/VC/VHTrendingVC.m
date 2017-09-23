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
#import "VHPopUpButton.h"
#import "VHUtils.h"
#import "VHCursorButton.h"
#import "NSImage+Tint.h"
#import "VHUtils+TransForm.h"
#import "VHHorizontalLine.h"

@interface VHTrendingVC ()<NSTableViewDelegate, NSTableViewDataSource, VHStateViewDelegate, VHTrendingRepositoryCellViewDelegate>

@property (weak) IBOutlet VHCursorButton *languageImageButton;
@property (weak) IBOutlet VHPopUpButton *languagePopupButton;
@property (weak) IBOutlet VHCursorButton *timeImageButton;
@property (weak) IBOutlet VHPopUpButton *timePopupButton;
@property (weak) IBOutlet VHHorizontalLine *horizontalLine;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet VHStateView *stateView;
@property (nonatomic, strong) VHScroller *scroller;

@end

@implementation VHTrendingVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.languagePopupButton setMenuWindowRelativeFrame:NSMakeRect(-220,
                                                                    self.languagePopupButton.height - 300,
                                                                    200,
                                                                    300)];
    [self.timePopupButton setMenuWindowRelativeFrame:NSMakeRect(60,
                                                                self.timePopupButton.height - 300 + 21,
                                                                200,
                                                                300)];

    [self addNotifications];
    
    self.stateView.delegate = self;
    [self.stateView setLoadingText:@"Loading trending..."];
    [self.stateView setEmptyImage:@"icon_empty_trending"];
    [self.stateView setEmptyText:@"Trending repositories are currently being dissected"];
    [self setUIState];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHTrendingRepositoryCellView" bundle:nil]
                  forIdentifier:@"VHTrendingRepositoryCellView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [NSColor clearColor];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    
    self.scrollView.drawsBackground = NO;
    
    self.scroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.view.width - 6, 10, 6, self.scrollView.height - 10)
                                       withImageFrame:NSMakeRect(0, self.scrollView.height - 60, 6, 60)
                                        withImageName:@"image_scroller"
                                 withPressedImageName:@"image_scroller_pressed"
                                       withScrollView:self.scrollView];
    [self.view addSubview:self.scroller];
    
    [self.horizontalLine setLineWidth:0.5];
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
            [self colorLanguageIcon];
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
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:language.name action:nil keyEquivalent:@""];
        [item setImage:[[NSImage imageNamed:@"icon_language_dot"] imageTintedWithColor:language.color]];
        item.image.size = NSMakeSize(8, 8);
        [self.languagePopupButton.menu addItem:item];
    }];

    NSUInteger languageSelectedIndex = [[VHGithubNotifierManager sharedManager] trendingContentSelectedIndex];
    if (languageSelectedIndex >= self.languagePopupButton.numberOfItems)
    {
        languageSelectedIndex = 0;
        [[VHGithubNotifierManager sharedManager] setTrendingContentSelectedIndex:0];
    }
    [self.languagePopupButton selectItemAtIndex:languageSelectedIndex];

    NSUInteger timeSelectedIndex = [[VHGithubNotifierManager sharedManager] trendingTimeSelectedIndex];
    if (timeSelectedIndex >= self.timePopupButton.numberOfItems)
    {
        timeSelectedIndex = 0;
        [[VHGithubNotifierManager sharedManager] setTrendingTimeSelectedIndex:0];
    }
    [self.timePopupButton selectItemAtIndex:timeSelectedIndex];
    
    [self colorLanguageIcon];
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
    if ([VHGithubNotifierManager sharedManager].trendingRepositories.count == 0)
    {
        [self.stateView setState:VHStateViewStateTypeEmpty];
        [self.scrollView setHidden:YES];
    }
    else
    {
        [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
        [self.languagePopupButton setHidden:NO];
        [self.timePopupButton setHidden:NO];
        [self.scrollView setHidden:NO];
        [self.tableView reloadData];
        [VHUtils scrollViewToTop:self.scrollView];
    }
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
        [[VHGithubNotifierManager sharedManager] updateTrending];
        [self setUIStateForTrendingContent];
    }
}

#pragma mark - Actions

- (IBAction)onTrendingContentSelected:(NSPopUpButton *)sender
{
    [[VHGithubNotifierManager sharedManager] setTrendingContentSelectedIndex:sender.indexOfSelectedItem];
    [[VHGithubNotifierManager sharedManager] updateTrending];
    [self setLoadingUIStateForTrending];
    [self colorLanguageIcon];
}

- (IBAction)onTrendingTimeSelected:(NSPopUpButton *)sender
{
    [[VHGithubNotifierManager sharedManager] setTrendingTimeSelectedIndex:sender.indexOfSelectedItem];
    [[VHGithubNotifierManager sharedManager] updateTrending];
    [self setLoadingUIStateForTrending];
}

- (IBAction)onLanguageImageButtonClicked:(id)sender
{
    [self.languagePopupButton performClick:nil];
}

- (IBAction)onTimeImageButtonClicked:(id)sender
{
    [self.timePopupButton performClick:nil];
}

#pragma mark - VHTrendingRepositoryCellViewDelegate

- (void)onTrendingClicked:(VHTrendingRepository *)repository
{
    [VHUtils openUrl:repository.url];
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

#pragma mark - Private Methods

- (void)colorLanguageIcon
{
    NSUInteger index = [[VHGithubNotifierManager sharedManager] trendingContentSelectedIndex];
    if (index < 2)
    {
        self.languageImageButton.image = [[NSImage imageNamed:@"icon_language"] imageTintedWithColor:[VHUtils colorFromHexColorCodeInString:@"#03A9F4"]];
    }
    else
    {
        VHLanguage *language = [[VHGithubNotifierManager sharedManager].languages safeObjectAtIndex:index - 2];
        self.languageImageButton.image = [[NSImage imageNamed:@"icon_language"] imageTintedWithColor:language.color];
    }
}

@end
