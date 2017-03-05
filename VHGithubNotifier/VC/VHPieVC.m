//
//  VHPieVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/19.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHPieVC.h"
#import "AFURLSessionManager.h"
#import "VHGithubNotifier-Bridging-Header.h"
#import "VHGithubNotifierManager+ChartDataProvider.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHUtils.h"
#import "NSView+Position.h"

@interface VHPieVC ()<ChartViewDelegate>

@property (nonatomic, strong) PieChartView *pieChart;
@property (nonatomic, strong) NSDate *lastMouseUpTime;
@property (nonatomic, assign) BOOL isDoubleClick;

@end

@implementation VHPieVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pieChart = [[PieChartView alloc] initWithFrame:self.view.bounds];
    self.pieChart.extraLeftOffset = 30;
    self.pieChart.extraRightOffset = 30;
    self.pieChart.highlightPerTapEnabled = YES;
    self.pieChart.delegate = self;
    
    [self updateCenterText];
    [self.view addSubview:self.pieChart];
    
    [self addNotifications];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [self addNotification:kNotifyRepositoriesLoadedSuccessfully forSelector:@selector(onNotifyRepositoriesLoadedSuccessfully:)];
    [self addNotification:kNotifyWindowWillHide forSelector:@selector(onNotifyWindowWillHide:)];
}

- (void)onNotifyRepositoriesLoadedSuccessfully:(NSNotification *)notification
{
    // update pie
    [self.pieChart clearValues];
    [self.pieChart setData:[[VHGithubNotifierManager sharedManager] userRepositoriesPieDataSet]];
    
    // update total star number
    [self updateCenterText];
    
    // update description text
    [self updateDescriptionText];
}

- (void)onNotifyWindowWillHide:(NSNotification *)notification
{
    [self.pieChart highlightValue:nil callDelegate:NO];
    [self updateDescriptionText];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight
{
    NSString *name = ((PieChartDataEntry *)entry).label;
    if (self.isDoubleClick)
    {
        [VHUtils openUrl:[[VHGithubNotifierManager sharedManager] urlFromRepositoryName:name]];
        [self.pieChart highlightValue:nil callDelegate:NO];
        [self updateDescriptionText];
    }
    else
    {
        self.pieChart.descriptionText = [NSString stringWithFormat:@"Double click to visit %@", name];
    }
    self.isDoubleClick = NO;
}

#pragma mark - Mouse

- (void)mouseUp:(NSEvent *)event
{
    NSDate *mouseUpTime = [NSDate date];
    if (self.lastMouseUpTime && mouseUpTime.timeIntervalSince1970 - self.lastMouseUpTime.timeIntervalSince1970 <= 0.3)
    {
        // double click
        self.isDoubleClick = YES;
    }
    NSPoint locationInPieChart = [self.pieChart convertPoint:[event locationInWindow] fromView:nil];
    ChartHighlight *highlight = [self.pieChart getHighlightByTouchPoint:locationInPieChart];
    if (highlight == nil)
    {
        [self updateDescriptionText];
    }
    [self.pieChart highlightValue:highlight callDelegate:YES];
    self.lastMouseUpTime = [NSDate date];
}

#pragma mark - Private Methods

- (void)updateCenterText
{
    NSString *starString = [NSString stringWithFormat:@"%lu", [[[VHGithubNotifierManager sharedManager] user] starNumber]];
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:starString];
    [centerText addAttribute:NSFontAttributeName
                       value:[NSFont fontWithName:@"Arial Italic" size:30]
                       range:NSMakeRange(0, starString.length)];
    [centerText addAttribute:NSForegroundColorAttributeName
                       value:[VHUtils randomColor]
                       range:NSMakeRange(0, starString.length)];
    [self.pieChart setCenterAttributedText:centerText];
}

- (void)updateDescriptionText
{
    NSUInteger repositoryNumber = [[self.pieChart.data.dataSets firstObject] entryCount];
    if (repositoryNumber == 0)
    {
        self.pieChart.descriptionText = [NSString stringWithFormat:@"There are no repositories whose stargazers number are greater than %zd", [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
    else if (repositoryNumber == 1)
    {
        self.pieChart.descriptionText = [NSString stringWithFormat:@"1 repository whose stargazers number is greater than %zd", [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
    else
    {
        self.pieChart.descriptionText = [NSString stringWithFormat:@"%zd repositories whose stargazers number is greater than %zd", repositoryNumber, [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie]];
    }
}

@end
