//
//  VHGithubNotifierManager+ChartDataProvider.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+ChartDataProvider.h"
#import "VHUtils.h"

@implementation VHGithubNotifierManager (ChartDataProvider)

- (PieChartData *)userRepositoriesPieDataSet
{
    __block NSMutableArray<PieChartDataEntry *> *array = [NSMutableArray arrayWithCapacity:self.user.ownerRepositories.count];
    __block PieChartDataEntry *entry;
    for (VHRepository *repository in self.user.ownerRepositories)
    {
        if (repository.starNumber >= self.user.starNumber / 100.0f)
        {
            entry = [[PieChartDataEntry alloc] initWithValue:repository.starNumber label:repository.name];
            [array addObject:entry];
        }
    }
    
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PieChartDataEntry *entry1 = SAFE_CAST(obj1, [PieChartDataEntry class]);
        PieChartDataEntry *entry2 = SAFE_CAST(obj2, [PieChartDataEntry class]);
        if (entry1.value < entry2.value)
        {
            return NSOrderedDescending;
        }
        else if (entry1.value == entry2.value)
        {
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    PieChartDataSet *set = [[PieChartDataSet alloc] initWithValues:array label:@"Repositoies"];
    [VHUtils setRandomColor:set withNumber:[array count]];
    set.valueTextColor = [NSColor whiteColor];
    [set setEntryLabelColor:[NSColor grayColor]];
    set.xValuePosition = PieChartValuePositionOutsideSlice;
    set.valueLineColor = [NSColor grayColor];
    set.valueLinePart1OffsetPercentage = 0.7;
    set.valueLinePart1Length = 0.5;
    set.valueLinePart2Length = 0;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:set];
    return data;
}

@end
