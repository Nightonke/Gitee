//
//  VHGithubNotifierManager+ChartDataProvider.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+ChartDataProvider.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHUtils.h"

static NSUInteger repositoriesPieTotalStarNumber = 0;

@implementation VHGithubNotifierManager (ChartDataProvider)

- (PieChartData *)userRepositoriesPieDataSet
{
    __block NSMutableArray<PieChartDataEntry *> *array = [NSMutableArray arrayWithCapacity:self.user.ownerRepositories.count];
    __block PieChartDataEntry *entry;
    repositoriesPieTotalStarNumber = 0;
    for (VHRepository *repository in self.user.ownerRepositories)
    {
        if (repository.starNumber >= [[VHGithubNotifierManager sharedManager] minimumStarNumberInPie])
        {
            repositoriesPieTotalStarNumber += repository.starNumber;
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
    PieChartDataSet *set = [[PieChartDataSet alloc] initWithValues:array label:@""];
    [VHUtils setRandomColor:set withNumber:[array count]];
    set.valueTextColor = [NSColor whiteColor];
    set.valueFont = [NSFont systemFontOfSize:12 weight:NSFontWeightLight];
    [set setEntryLabelColor:[NSColor grayColor]];
    [set setEntryLabelFont:[NSFont systemFontOfSize:12 weight:NSFontWeightLight]];
    set.xValuePosition = PieChartValuePositionOutsideSlice;
    set.valueLineColor = [NSColor grayColor];
    set.valueLineWidth = 0.5;
    set.valueLinePart1OffsetPercentage = 0.9;
    set.valueLinePart1Length = 0.6;
    set.valueLinePart2Length = 0;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:set];
    return data;
}

- (NSString *)urlFromRepositoryName:(NSString *)name
{
    for (VHRepository *repository in self.user.allRepositories)
    {
        if ([repository.name isEqualToString:name])
        {
            return repository.url;
        }
    }
    return nil;
}

- (NSUInteger)repositoriesPieTotalStarNumber
{
    return repositoriesPieTotalStarNumber;
}

@end
