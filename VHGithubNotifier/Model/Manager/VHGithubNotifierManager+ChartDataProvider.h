//
//  VHGithubNotifierManager+ChartDataProvider.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import "VHGithubNotifier-Bridging-Header.h"

@interface VHGithubNotifierManager (ChartDataProvider)

- (PieChartData *)userRepositoriesPieData;

- (void)updateUserRepositoriesPieData;

- (NSString *)urlFromRepositoryName:(NSString *)name;

- (NSUInteger)repositoriesPieTotalStarNumber;

@end
