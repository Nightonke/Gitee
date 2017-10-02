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
#import "VHLanguagesButton.h"
#import "VHTrendingLanguageCellView.h"
#import "VHTableView.h"

@interface VHTrendingVC ()<NSTableViewDelegate, NSTableViewDataSource, VHStateViewDelegate, VHTrendingRepositoryCellViewDelegate, VHTrendingLanguageCellViewDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet NSView *editingHeadView;
@property (weak) IBOutlet NSTextField *editingTip;
@property (nonatomic, strong) VHCursorButton *editingDoneButton;
@property (nonatomic, strong) VHCursorButton *editingCancelButton;

@property (weak) IBOutlet NSView *headView;
@property (weak) IBOutlet VHCursorButton *languageImageButton;
@property (weak) IBOutlet VHLanguagesButton *languagesButton;
@property (weak) IBOutlet VHCursorButton *timeImageButton;
@property (weak) IBOutlet VHPopUpButton *timePopupButton;

@property (weak) IBOutlet VHHorizontalLine *horizontalLine;

@property (weak) IBOutlet NSScrollView *languagesScrollView;
@property (weak) IBOutlet VHTableView *languagesTableView;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet VHStateView *stateView;
@property (nonatomic, strong) VHScroller *scroller;
@property (nonatomic, strong) VHScroller *languageScroller;

@property (nonatomic, assign) NSUInteger timeSelectedIndex;

@property (nonatomic, assign) BOOL isEditingLanguages;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *backupSelectedLanguageIDs;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectedLanguageIDs;

@end

@implementation VHTrendingVC

#pragma mark - Life

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _selectedLanguageIDs = [NSMutableSet setWithArray:[[VHGithubNotifierManager sharedManager] trendingSelectedLanguageIDs]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.timePopupButton setMenuWindowRelativeFrame:NSMakeRect(60,
                                                                self.timePopupButton.height - 300 + 21,
                                                                200,
                                                                300)];
    self.timeSelectedIndex = [[VHGithubNotifierManager sharedManager] trendingTimeSelectedIndex];
    
    [self addNotifications];
    
    [self createLanguageCancelButton];
    [self createLanguageDoneButton];
    
    [self.editingCancelButton setImage:[NSImage imageNamed:@"icon_cancel.png"]];
    
    self.stateView.delegate = self;
    [self.stateView setLoadingText:@"Loading trending..."];
    [self.stateView setEmptyImage:@"icon_empty_trending"];
    [self.stateView setEmptyText:@"Trending repositories are currently being dissected"];
    [self setUIState];
    
    self.editingTip.delegate = self;
    
    [self.languagesButton setButtonType:NSButtonTypeMomentaryChange];
    self.languagesButton.bezelStyle = NSRoundRectBezelStyle;
    self.languagesButton.bordered = NO;
    [self.languagesButton setSelectedLanguageIDs:self.selectedLanguageIDs];
    
    [self.languagesTableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHTrendingLanguageCellView" bundle:nil] forIdentifier:@"VHTrendingLanguageCellView"];
    self.languagesTableView.delegate = self;
    self.languagesTableView.dataSource = self;
    [self.languagesTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.languagesTableView setIntercellSpacing:NSMakeSize(0, 0)];
    self.languageScroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.view.width - 6, 10, 6, self.scrollView.height - 10)
                                               withImageFrame:NSMakeRect(0, self.scrollView.height - 60, 6, 60)
                                                withImageName:@"image_scroller"
                                         withPressedImageName:@"image_scroller_pressed"
                                               withScrollView:self.languagesScrollView];
    [self.languagesScrollView addSubview:self.languageScroller];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHTrendingRepositoryCellView" bundle:nil] forIdentifier:@"VHTrendingRepositoryCellView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    self.scroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.view.width - 6, 10, 6, self.scrollView.height - 10)
                                       withImageFrame:NSMakeRect(0, self.scrollView.height - 60, 6, 60)
                                        withImageName:@"image_scroller"
                                 withPressedImageName:@"image_scroller_pressed"
                                       withScrollView:self.scrollView];
    [self.scrollView addSubview:self.scroller];

    [self.horizontalLine setLineWidth:0.5];
}

- (void)setUIState
{
    [self.timePopupButton.menu removeAllItems];
    [self.timePopupButton.menu addItemWithTitle:@"Today" action:nil keyEquivalent:@""];
    [self.timePopupButton.menu addItemWithTitle:@"This week" action:nil keyEquivalent:@""];
    [self.timePopupButton.menu addItemWithTitle:@"This month" action:nil keyEquivalent:@""];
    [self.timePopupButton selectItem:[self.timePopupButton.menu itemAtIndex:self.timeSelectedIndex]];
    
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
    [self.editingHeadView setHidden:YES];
    [self.headView setHidden:YES];
    [self.horizontalLine setHidden:YES];
    [self.languagesScrollView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.stateView setState:VHStateViewStateTypeLoading];
}

- (void)setLoadingUIStateForTrending
{
    if (self.isEditingLanguages)
    {
        
    }
    else
    {
        [self.editingHeadView setHidden:YES];
        [self.languagesScrollView setHidden:YES];
    }
    [self.scrollView setHidden:YES];
    [self.stateView setState:VHStateViewStateTypeLoading];
    if (self.isEditingLanguages)
    {
        [self.stateView setHidden:YES];
    }
}

- (void)setEditingLanguageState:(BOOL)isEditingLanguage animated:(BOOL)animated
{
    if (self.isAnimating)
    {
        return;
    }
    self.isAnimating = YES;
    self.isEditingLanguages = isEditingLanguage;
    CGFloat languageViewsAlpha = isEditingLanguage ? 1 : 0;
    CGFloat trendingViewsAlpha = isEditingLanguage ? 0 : 1;
    NSTimeInterval duration = animated ? 0.3 : 0;
    self.editingHeadView.hidden = !isEditingLanguage;
    self.editingHeadView.alphaValue = 1 - languageViewsAlpha;
    self.languagesScrollView.hidden = !isEditingLanguage;
    self.languagesScrollView.alphaValue = 1 - languageViewsAlpha;
    self.headView.hidden = isEditingLanguage;
    self.headView.alphaValue = 1 - trendingViewsAlpha;
    self.scrollView.hidden = isEditingLanguage;
    self.scrollView.alphaValue = 1 - trendingViewsAlpha;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = duration;
        self.editingHeadView.animator.alphaValue = languageViewsAlpha;
        self.languagesScrollView.animator.alphaValue = languageViewsAlpha;
        self.headView.animator.alphaValue = trendingViewsAlpha;
        self.scrollView.animator.alphaValue = trendingViewsAlpha;
    } completionHandler:^{
        self.editingHeadView.hidden = !isEditingLanguage;
        self.languagesScrollView.hidden = !isEditingLanguage;
        self.headView.hidden = isEditingLanguage;
        self.scrollView.hidden = isEditingLanguage;
        self.editingHeadView.alphaValue = languageViewsAlpha;
        self.languagesScrollView.alphaValue = languageViewsAlpha;
        self.headView.alphaValue = trendingViewsAlpha;
        self.scrollView.alphaValue = trendingViewsAlpha;
        self.isAnimating = NO;
    }];
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
    if (self.isEditingLanguages)
    {
        // Do nothing
    }
    else
    {
        [self.languagesTableView reloadData];
    }
    
    [self colorLanguageIcon];
}

- (void)onNotifyLanguageLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Languages loaded failed!"];
    [self.editingHeadView setHidden:YES];
    [self.headView setHidden:YES];
    [self.horizontalLine setHidden:YES];
    [self.languagesScrollView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.stateView setState:VHStateViewStateTypeLoading];
}

- (void)onNotifyTrendingLoadedSuccessfully:(NSNotification *)notification
{
    if ([[VHGithubNotifierManager sharedManager] hasValidTrendingData])
    {
        if (self.isEditingLanguages)
        {
            // Do nothing but update the trending data
        }
        else
        {
            [self.editingHeadView setHidden:YES];
            [self.languagesScrollView setHidden:YES];
            [self.horizontalLine setHidden:NO];
            [self.headView setHidden:NO];
            [self.scrollView setHidden:NO];
        }
        [self.stateView setState:VHStateViewStateTypeLoadSuccessfully];
        [self.tableView reloadData];
        [VHUtils scrollViewToTop:self.scrollView];
    }
    else
    {
        [self.stateView setState:VHStateViewStateTypeEmpty];
        [self.tableView reloadData];
    }
}

- (void)onNotifyTrendingLoadedFailed:(NSNotification *)notification
{
    [self.stateView setState:VHStateViewStateTypeLoadFailed];
    [self.stateView setRetryText:@"Trendings loaded failed!"];
    [self.editingHeadView setHidden:NO];
    [self.horizontalLine setHidden:NO];
    [self.languagesScrollView setHidden:NO];
    [self.headView setHidden:NO];
    [self.scrollView setHidden:NO];
    [self.tableView reloadData];
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

- (void)onEditingLanguagesDoneButtonClicked:(VHCursorButton *)sender
{
    if (self.selectedLanguageIDs.count == 0)
    {
        self.selectedLanguageIDs = [self.backupSelectedLanguageIDs mutableCopy];
        return;
    }
    if (![self.backupSelectedLanguageIDs isEqualToSet:self.selectedLanguageIDs])
    {
        NSMutableArray *selectedLanguageIDs = [NSMutableArray arrayWithCapacity:self.selectedLanguageIDs.count];
        [self.selectedLanguageIDs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            [selectedLanguageIDs addObject:obj];
        }];
        [[VHGithubNotifierManager sharedManager] setTrendingSelectedLanguageIDs:[selectedLanguageIDs copy]];
        [[VHGithubNotifierManager sharedManager] updateTrending];
        [self setLoadingUIStateForTrending];
        [self colorLanguageIcon];
    }
    [self.languagesButton setSelectedLanguageIDs:self.selectedLanguageIDs];
    [self setEditingLanguageState:NO animated:YES];
}

- (void)onEditingLanguagesCancelButtonClicked:(VHCursorButton *)sender
{
    [self setEditingLanguageState:NO animated:YES];
    self.selectedLanguageIDs = [self.backupSelectedLanguageIDs mutableCopy];
}

- (IBAction)onTrendingTimeSelected:(NSPopUpButton *)sender
{
    [[VHGithubNotifierManager sharedManager] setTrendingTimeSelectedIndex:sender.indexOfSelectedItem];
    [[VHGithubNotifierManager sharedManager] updateTrending];
    [self setLoadingUIStateForTrending];
}

- (IBAction)onLanguageImageButtonClicked:(id)sender
{
    [self onLanguageButtonClicked:self.languagesButton];
}

- (IBAction)onLanguageButtonClicked:(VHLanguagesButton *)sender
{
    self.backupSelectedLanguageIDs = [self.selectedLanguageIDs mutableCopy];
    [self setEditingLanguageState:YES animated:YES];
    self.editingTip.stringValue = @"";
    [self.languagesTableView scrollRowToVisible:0];
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

#pragma mark - VHTrendingLanguageCellViewDelegate

- (void)onLanguage:(VHLanguage *)language selected:(BOOL)selected
{
    if (selected)
    {
        [self.selectedLanguageIDs addObject:@(language.languageId)];
    }
    else
    {
        [self.selectedLanguageIDs removeObject:@(language.languageId)];
    }
    if (self.selectedLanguageIDs.count == 0)
    {
        [self.editingDoneButton setEnabled:NO];
    }
    else
    {
        [self.editingDoneButton setEnabled:YES];
    }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];
    if (textField == self.editingTip)
    {
        NSString *languageName = self.editingTip.stringValue;
        NSInteger index = [[VHGithubNotifierManager sharedManager] matchLanguageIndexFromSearchString:languageName];
        [self.languagesTableView scrollRowToVisible:index animate:NO];
    }
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.tableView)
    {
        return [VHGithubNotifierManager sharedManager].trendingRepositories.count;
    }
    else if (tableView == self.languagesTableView)
    {
        return [[[VHGithubNotifierManager sharedManager] languages] count];
    }
    else
    {
        return 0;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.tableView)
    {
        VHTrendingRepositoryCellView *cell = [tableView makeViewWithIdentifier:@"VHTrendingRepositoryCellView" owner:self];
        [cell setTrendingRepository:[[VHGithubNotifierManager sharedManager].trendingRepositories safeObjectAtIndex:row]];
        [cell setIsLastRow:row == [self numberOfRowsInTableView:tableView] - 1];
        [cell setDelegate:self];
        return cell;
    }
    else if (tableView == self.languagesTableView)
    {
        VHTrendingLanguageCellView *cell = [tableView makeViewWithIdentifier:@"VHTrendingLanguageCellView" owner:self];
        VHLanguage *language = [[[VHGithubNotifierManager sharedManager] languages] objectAtIndex:row];
        [cell setLanguage:language];
        [cell setDelegate:self];
        [cell setSelected:[self.selectedLanguageIDs containsObject:@(language.languageId)]];
        return cell;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Private Methods

- (void)colorLanguageIcon
{
    // Don't change the color of the icon, it's ugly
    self.languageImageButton.image = [[NSImage imageNamed:@"icon_language"] imageTintedWithColor:[VHUtils colorFromHexColorCodeInString:THEME_COLOR_STRING]];
//    NSInteger ID = [[[[VHGithubNotifierManager sharedManager] trendingSelectedLanguageIDs] firstObject] integerValue];
//    RLMResults<VHLanguage *> *languages = [VHLanguage objectsWhere:@"languageId = %d", ID];
//    VHLanguage *language = [languages firstObject];
//    if (language)
//    {
//        self.languageImageButton.image = [[NSImage imageNamed:@"icon_language"] imageTintedWithColor:language.color];
//    }
//    else
//    {
//        self.languageImageButton.image = [[NSImage imageNamed:@"icon_language"] imageTintedWithColor:[VHUtils colorFromHexColorCodeInString:THEME_COLOR_STRING]];
//    }
}

- (void)createLanguageCancelButton
{
    NSImage *cancelImage = [NSImage imageNamed:@"icon_cancel"];
    cancelImage.size = NSMakeSize(20, 20);
    cancelImage.template = NO;
    self.editingCancelButton = [[VHCursorButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.editingCancelButton setButtonType:NSButtonTypeMomentaryChange];
    self.editingCancelButton.bezelStyle = NSRoundRectBezelStyle;
    self.editingCancelButton.bordered = NO;
    self.editingCancelButton.image = cancelImage;
    [self.editingHeadView addSubview:self.editingCancelButton];
    [self.editingCancelButton setLeft:self.editingHeadView.width - 9 - 30];
    [self.editingCancelButton setVCenter:self.editingHeadView.height / 2];
    [self.editingCancelButton setTarget:self];
    [self.editingCancelButton setAction:@selector(onEditingLanguagesCancelButtonClicked:)];
    [self.editingCancelButton setToolTip:@"Cancel"];
}

- (void)createLanguageDoneButton
{
    NSImage *doneImage = [NSImage imageNamed:@"icon_done"];
    doneImage.size = NSMakeSize(20, 20);
    doneImage.template = NO;
    self.editingDoneButton = [[VHCursorButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.editingDoneButton setButtonType:NSButtonTypeMomentaryChange];
    self.editingDoneButton.bezelStyle = NSRoundRectBezelStyle;
    self.editingDoneButton.bordered = NO;
    self.editingDoneButton.image = doneImage;
    [self.editingHeadView addSubview:self.editingDoneButton];
    [self.editingDoneButton setLeft:self.editingCancelButton.getLeft - 4 - 30];
    [self.editingDoneButton setVCenter:self.editingHeadView.height / 2];
    [self.editingDoneButton setTarget:self];
    [self.editingDoneButton setAction:@selector(onEditingLanguagesDoneButtonClicked:)];
    [self.editingDoneButton setToolTip:@"Done"];
}

@end
