//
//  VHPieVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/19.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHPieVC.h"
#import "AFURLSessionManager.h"
#import "VHGithubNotifier-Swift.h"
#import "VHGithubNotifierManager+ChartDataProvider.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHUtils.h"
#import "NSView+Position.h"
#import "VHCursorButton.h"

@interface VHPieVC ()<ChartViewDelegate>

@property (nonatomic, strong) VHPieChartView *pieChart;
@property (weak) IBOutlet VHCursorButton *openUrlButton;
@property (nonatomic, strong) NSString *highlightedRepositoryName;

@end

@implementation VHPieVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pieChart = [[VHPieChartView alloc] initWithFrame:self.view.bounds];
    self.pieChart.extraLeftOffset = 30;
    self.pieChart.extraRightOffset = 30;
    self.pieChart.highlightPerTapEnabled = YES;
    self.pieChart.delegate = self;
    self.pieChart.holeColor = nil;
    self.pieChart.noDataText = @"Didn't get any data yet!";
    self.pieChart.noDataFont = [NSFont systemFontOfSize:12 weight:NSFontWeightLight];
    self.pieChart.descriptionFont = [NSFont systemFontOfSize:12 weight:NSFontWeightLight];
    self.pieChart.entryLabelFont = [NSFont systemFontOfSize:12 weight:NSFontWeightLight];
    [self.pieChart setData:[[VHGithubNotifierManager sharedManager] userRepositoriesPieData]];
    
    [self updateCenterText];
    [self.view addSubview:self.pieChart];
    
    [self.openUrlButton removeFromSuperview];
    [self.view addSubview:self.openUrlButton];
    self.openUrlButton.hidden = YES;
    
    [self addNotifications];
    
    if ([[VHGithubNotifierManager sharedManager] repositoriesLoadState] == VHLoadStateTypeLoadSuccessfully)
    {
        [self onNotifyRepositoriesLoadedSuccessfully:nil];
    }
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyRepositoriesLoadedSuccessfully forSelector:@selector(onNotifyRepositoriesLoadedSuccessfully:)];
    [self addNotification:kNotifyWindowWillShow forSelector:@selector(onNotifyWindowWillShow:)];
    [self addNotification:kNotifyWindowWillHide forSelector:@selector(onNotifyWindowWillHide:)];
    [self addNotification:kNotifyTabInTabViewControllerChanged forSelector:@selector(onNotifyTabInTabViewControllerChanged:)];
    [self addNotification:kNotifyMinimumStarNumberInPieChanged forSelector:@selector(onNotifyMinimumStarNumberInPieChanged:)];
}

- (void)onNotifyRepositoriesLoadedSuccessfully:(NSNotification *)notification
{
    // update pie
    [self.pieChart notifyDataSetChanged];
    [self.pieChart highlightValue:nil];
    self.openUrlButton.hidden = YES;

    // update total star number
    [self updateCenterText];

    // update description text
    [self updateDescriptionText];
    
    [self.pieChart animateWithXAxisDuration:1];
}

- (void)onNotifyWindowWillHide:(NSNotification *)notification
{
    [self.pieChart stopSpinAnimation];
    [self.pieChart stopDeceleration];
}

- (void)onNotifyWindowWillShow:(NSNotification *)notification
{
    [self.pieChart highlightValue:nil callDelegate:NO];
    [self.pieChart animateWithXAxisDuration:1];
    [self updateDescriptionText];
}

- (void)onNotifyTabInTabViewControllerChanged:(NSNotification *)notification
{
    if ([notification.object integerValue] == VHGithubContentTypeRepositoryPie)
    {
        [self.pieChart animateWithXAxisDuration:1];
    }
}

- (void)onNotifyMinimumStarNumberInPieChanged:(NSNotification *)notification
{
    [[VHGithubNotifierManager sharedManager] updateUserRepositoriesPieData];
    [self onNotifyRepositoriesLoadedSuccessfully:nil];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight
{
    NSString *name = ((PieChartDataEntry *)entry).label;
    self.highlightedRepositoryName = name;
    self.pieChart.descriptionTextAlign = NSTextAlignmentRight;
    self.pieChart.chartDescription.text = [NSString stringWithFormat:@"Visit %@           ", name];
    self.openUrlButton.hidden = NO;
}

- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView
{
    self.openUrlButton.hidden = YES;
    [self updateDescriptionText];
}

#pragma mark - Mouse

- (void)mouseUp:(NSEvent *)event
{
    NSPoint locationInPieChart = [self.pieChart convertPoint:[event locationInWindow] fromView:nil];
    ChartHighlight *highlight = [self.pieChart getHighlightByTouchPoint:locationInPieChart];
    [self.pieChart highlightValue:highlight callDelegate:YES];
}

#pragma mark - Actions

- (IBAction)onOpenUrlButtonClicked:(id)sender
{
    [VHUtils openUrl:[[VHGithubNotifierManager sharedManager] urlFromRepositoryName:self.highlightedRepositoryName]];
    [self.pieChart highlightValue:nil callDelegate:NO];
    [self updateDescriptionText];
}

#pragma mark - Private Methods

- (void)updateCenterText
{
    NSString *starString = [NSString stringWithFormat:@"%zd", [[VHGithubNotifierManager sharedManager] repositoriesPieTotalStarNumber]];
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:starString];
    NSFont *font = [NSFont systemFontOfSize:30 weight:NSFontWeightThin];
    [centerText addAttribute:NSFontAttributeName
                       value:font
                       range:NSMakeRange(0, starString.length)];
    [centerText addAttribute:NSForegroundColorAttributeName
                       value:[NSColor grayColor]
                       range:NSMakeRange(0, starString.length)];
    [self.pieChart setCenterAttributedText:centerText];
}

- (void)updateDescriptionText
{
    [self.openUrlButton setTop:self.pieChart.legend.neededHeight + 20];
    self.pieChart.descriptionTextAlign = NSTextAlignmentCenter;
    NSUInteger repositoryNumber = [[self.pieChart.data.dataSets firstObject] entryCount];
    if (repositoryNumber == 0)
    {
        self.pieChart.chartDescription.text = [NSString stringWithFormat:@"There are no repositories whose stargazers number are not less than %zd", [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
    else if (repositoryNumber == 1)
    {
        self.pieChart.chartDescription.text = [NSString stringWithFormat:@"1 repository whose stargazers number is not less than %zd", [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
    else
    {
        self.pieChart.chartDescription.text = [NSString stringWithFormat:@"%zd repositories whose stargazers number is not less than %zd", repositoryNumber, [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
}

@end
