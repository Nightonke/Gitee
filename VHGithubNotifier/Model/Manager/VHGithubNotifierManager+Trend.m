//
//  VHGithubNotifierManager+Trend.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Trend.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHTrendChartParser.h"
#import "VHRepository.h"
#import "VHUtils.h"

static RLMResults *trendDatas;

@implementation VHGithubNotifierManager (Trend)

#pragma mark - Public Methods

- (void)innerInitializePropertiesForTrend
{
    [self copyJsFiles];
}

- (void)updateTrendData
{
    trendDatas = [[VHGithubNotifierManager sharedManager].user.allRepositories sortedResultsUsingKeyPath:@"starNumber" ascending:NO];
}

- (RLMResults *)trendDatas
{
    return trendDatas;
}

- (BOOL)loadTrendChartInWebView:(WKWebView *)webView withTrendContentIndex:(NSUInteger)contentIndex withTitle:(NSString *)title
{
    [VHUtils resetWKWebView];
    [self copyJsFiles];
    [self writeHtmlWithTrendContentIndex:contentIndex withTitle:title];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[self htmlPath]]]];
    return YES;
}

#pragma mark - Private Methods

- (void)copyJsFiles
{
    NSURL *toPath = [self realm].configuration.fileURL;
    toPath = [toPath URLByDeletingLastPathComponent];
    
    [self copyFileFromPath:[[NSBundle mainBundle] pathForResource:@"echarts" ofType:@"js"]
                    toPath:[[toPath URLByAppendingPathComponent:@"echarts.js"] relativePath]];
}

- (void)copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath] == NO)
    {
        NSError *error = nil;
        if ([[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&error])
        {
            TrendLog(@"Copy %@ to %@ successfully", fromPath, toPath);
        }
        else
        {
            TrendLog(@"Copy %@ to %@ failed with error: %@", fromPath, toPath, error);
        }
    }
    else
    {
        TrendingLog(@"%@ existed", toPath);
    }
}

- (void)writeHtmlWithTrendContentIndex:(NSUInteger)contentIndex withTitle:(NSString *)title
{
    NSString *htmlContent = [self htmlContentWithTrendContentIndex:contentIndex withTitle:title];
    NSError *error = nil;
    [htmlContent writeToFile:[self htmlPath]
                  atomically:YES
                    encoding: NSUTF8StringEncoding
                       error:&error];
    if (error)
    {
        TrendLog(@"Write html content failed with error: %@", error);
    }
}

- (NSString *)htmlContentWithTrendContentIndex:(NSUInteger)contentIndex withTitle:(NSString *)title
{
    NSArray<VHRecord *> *records = [NSArray array];
    NSString *yValueName = @"Stargazers";
    if (contentIndex == 0)
    {
        records = [[VHGithubNotifierManager sharedManager].user.followerRecords valueForKey:@"self"];
        yValueName = @"Follwers";
    }
    else if (contentIndex == 1)
    {
        records = [[VHGithubNotifierManager sharedManager].user.starRecords valueForKey:@"self"];
    }
    else
    {
        VHRepository *repository = [trendDatas objectAtIndex:contentIndex - 2];
        records = [repository.starRecords valueForKey:@"self"];
    }
    
    VHGithubTrendTimeType timeType = [[VHGithubNotifierManager sharedManager] trendTimeType];
    switch (timeType)
    {
        case VHGithubTrendTimeTypeAnytime:
            records = [VHRecord anytimeRecordsFromRecords:records];
            break;
        case VHGithubTrendTimeTypeDay:
            records = [VHRecord dayRecordsFromRecords:records];
            break;
        case VHGithubTrendTimeTypeWeek:
            records = [VHRecord weekRecordsFromRecords:records];
            break;
        case VHGithubTrendTimeTypeMonth:
            records = [VHRecord monthRecordsFromRecords:records];
            break;
        case VHGithubTrendTimeTypeYear:
            records = [VHRecord yearRecordsFromRecords:records];
            break;
    }
    
    return [VHTrendChartParser chartHtmlContentWithTitle:title withRecords:records withYValueName:yValueName];
    
//    return @"<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>ECharts</title><script src=\"echarts.js\"></script></head><body><div id=\"main\" style=\"width: 360px;height:470px;\"></div><script type=\"text/javascript\">var myChart = echarts.init(document.getElementById('main'));var option = {title: {text: 'ECharts 入门示例'},tooltip: {},legend: {data:['销量']},xAxis: {data: \"衬衫\",\"羊毛衫\",\"雪纺衫\",\"裤子\",\"高跟鞋\",\"袜子\"]},yAxis: {},series: [{name: '销量',type: 'bar',data: [5, 20, 36, 10, 10, 20]}]};myChart.setOption(option);</script></body></html>";
}

- (NSString *)htmlPath
{
    NSURL *toPath = [self realm].configuration.fileURL;
    toPath = [toPath URLByDeletingLastPathComponent];
    return [[toPath URLByAppendingPathComponent:@"trend.html"] relativePath];
}

@end
