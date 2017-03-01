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
#import "VHUtils.h"
#import "NSView+Position.h"

@interface VHPieVC ()<ChartViewDelegate>

@property (nonatomic, strong) PieChartView *pieChart;

@end

@implementation VHPieVC

#pragma mark - Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pieChart = [[PieChartView alloc] initWithFrame:self.view.bounds];
    self.pieChart.extraLeftOffset = 30;
    self.pieChart.extraRightOffset = 30;
    self.pieChart.descriptionText = @"Repositories";
    self.pieChart.highlightPerTapEnabled = YES;
    self.pieChart.delegate = self;
    
    [self updateCenterText];
    [self.view addSubview:self.pieChart];
    
    [self addNotifications];
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyWindowWillAppear:)
                                                 name:kNotifyWindowWillAppear
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNotifyWindowWillAppear:(NSNotification *)notification
{
    [self.pieChart clearValues];
    [self updateCenterText];
    [self.pieChart setData:[[VHGithubNotifierManager sharedManager] userRepositoriesPieDataSet]];
    [self.pieChart animateWithXAxisDuration:0 yAxisDuration:1];
    [self.pieChart.data setHighlightEnabled:YES];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight
{
    
}

#pragma mark - Mouse

- (void)mouseUp:(NSEvent *)event
{
    NSPoint locationInPieChart = [self.pieChart convertPoint:[event locationInWindow] fromView:nil];
    [self.pieChart highlightValue:[self.pieChart getHighlightByTouchPoint:locationInPieChart] callDelegate:YES];
}

#pragma mark - Private Methods

- (void)updateCenterText
{
    NSString *starString = [NSString stringWithFormat:@"%lu", [[[VHGithubNotifierManager sharedManager] user] starNumber]];
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:starString];
    [centerText addAttribute:NSFontAttributeName
                       value:[NSFont fontWithName:@"Arial Italic" size:40]
                       range:NSMakeRange(0, starString.length)];
    [centerText addAttribute:NSForegroundColorAttributeName
                       value:[VHUtils randomColor]
                       range:NSMakeRange(0, starString.length)];
    [self.pieChart setCenterAttributedText:centerText];
}

@end
