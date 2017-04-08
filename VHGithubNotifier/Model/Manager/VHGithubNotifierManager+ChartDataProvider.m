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
static PieChartData *userRepositoriesPieData;
static PieChartDataSet *userRepositoriesPieDataSet;

@implementation VHGithubNotifierManager (ChartDataProvider)

- (PieChartData *)userRepositoriesPieData
{
    if (userRepositoriesPieData == nil)
    {
        userRepositoriesPieData = [[PieChartData alloc] initWithDataSet:userRepositoriesPieDataSet];
    }
    return userRepositoriesPieData;
}

- (void)updateUserRepositoriesPieData
{
    if ([[[self userRepositoriesPieData] dataSets] count] == 0)
    {
        userRepositoriesPieDataSet = [[PieChartDataSet alloc] initWithValues:[self pieChartDataEntries] label:@""];
        [VHUtils setRandomColor:userRepositoriesPieDataSet withNumber:userRepositoriesPieData.entryCount];
        userRepositoriesPieDataSet.valueTextColor = [NSColor whiteColor];
        userRepositoriesPieDataSet.valueFont = [NSFont systemFontOfSize:12 weight:NSFontWeightLight];
        [userRepositoriesPieDataSet setEntryLabelColor:[NSColor grayColor]];
        [userRepositoriesPieDataSet setEntryLabelFont:[NSFont systemFontOfSize:12 weight:NSFontWeightLight]];
        userRepositoriesPieDataSet.xValuePosition = PieChartValuePositionOutsideSlice;
        userRepositoriesPieDataSet.valueLineColor = [NSColor grayColor];
        userRepositoriesPieDataSet.valueLineWidth = 0.5;
        userRepositoriesPieDataSet.valueLinePart1OffsetPercentage = 0.9;
        userRepositoriesPieDataSet.valueLinePart1Length = 0.6;
        userRepositoriesPieDataSet.valueLinePart2Length = 0;
        
        [[self userRepositoriesPieData] setDataSets:@[userRepositoriesPieDataSet]];
    }
    else
    {
        userRepositoriesPieDataSet.values = [self pieChartDataEntries];
        [VHUtils setRandomColor:userRepositoriesPieDataSet withNumber:userRepositoriesPieData.entryCount];
    }
}

- (NSMutableArray<PieChartDataEntry *> *)pieChartDataEntries
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
    
    return array;
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
