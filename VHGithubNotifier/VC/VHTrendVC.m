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
#import "VHGithubNotifier-Bridging-Header.h"
#import "VHDateValueFormatter.h"
#import "VHTrendTableCellView.h"
#import "VHUtils.h"

@interface VHTrendVC()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSPopUpButton *trendPopupButton;
@property (weak) IBOutlet NSButton *anyTimeRadioButton;
@property (weak) IBOutlet NSButton *dayRadioButton;
@property (weak) IBOutlet NSButton *weekRadioButton;
@property (weak) IBOutlet NSButton *monthRadioButton;
@property (weak) IBOutlet NSButton *yearRadioButton;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) RLMResults *trendDatas;
@property (nonatomic, strong) NSColor *trendColor;
@property (nonatomic, strong) NSArray<VHRecord *> *records;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation VHTrendVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedIndex = [[VHGithubNotifierManager sharedManager] trendContentSelectedIndex];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:20];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    [self setSelectedTimeTypeRadioButton];
    
    [self addNotifications];
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
    [self.trendPopupButton.menu removeAllItems];
    
    [self.trendPopupButton.menu addItemWithTitle:[NSString stringWithFormat:@"Followers of %@", [VHGithubNotifierManager sharedManager].user.name] action:nil keyEquivalent:@""];
    [self.trendPopupButton.menu addItemWithTitle:[NSString stringWithFormat:@"Stars of %@", [VHGithubNotifierManager sharedManager].user.name] action:nil keyEquivalent:@""];
    self.trendDatas = [[VHGithubNotifierManager sharedManager].user.allRepositories sortedResultsUsingProperty:@"starNumber" ascending:NO];
    for (VHRepository *repository in self.trendDatas)
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
    
    if (self.selectedIndex == 0)
    {
        self.records = [[VHGithubNotifierManager sharedManager].user.followerRecords valueForKey:@"self"];
    }
    else if (self.selectedIndex == 1)
    {
        self.records = [[VHGithubNotifierManager sharedManager].user.starRecords valueForKey:@"self"];
    }
    else
    {
        VHRepository *repository = [self.trendDatas objectAtIndex:self.selectedIndex - 2];
        self.records = [repository.starRecords valueForKey:@"self"];
    }
    
    VHGithubTrendTimeType timeType = [[VHGithubNotifierManager sharedManager] trendTimeType];
    switch (timeType)
    {
        case VHGithubTrendTimeTypeAnytime:
            self.records = [VHRecord anytimeRecordsFromRecords:self.records];
            break;
        case VHGithubTrendTimeTypeDay:
            self.records = [VHRecord dayRecordsFromRecords:self.records];
            break;
        case VHGithubTrendTimeTypeWeek:
            self.records = [VHRecord weekRecordsFromRecords:self.records];
            break;
        case VHGithubTrendTimeTypeMonth:
            self.records = [VHRecord monthRecordsFromRecords:self.records];
            break;
        case VHGithubTrendTimeTypeYear:
            self.records = [VHRecord yearRecordsFromRecords:self.records];
            break;
    }
    
    self.trendColor = [VHUtils randomColor];
    [self.tableView reloadData];
}

- (IBAction)onTimeTypeChanged:(NSButton *)radioButton
{
    [[VHGithubNotifierManager sharedManager] setTrendTimeType:radioButton.tag];
    [self onTrendDataSelected:nil];
}

#pragma mark - NSTableViewDelegate NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.records count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    VHTrendTableCellView *cell = [tableView makeViewWithIdentifier:NSStringFromClass([VHTrendTableCellView class]) owner:self];
    if (cell == nil)
    {
        cell = [[VHTrendTableCellView alloc] init];
    }
    [cell setTrendColor:[VHUtils trendColor:self.trendColor withCount:self.records.count withRow:row]];
    [cell setMaxValue:[self.records lastObject].number];
    [cell setRecord:[self.records objectAtIndex:self.records.count - row - 1]];
    return cell;
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
