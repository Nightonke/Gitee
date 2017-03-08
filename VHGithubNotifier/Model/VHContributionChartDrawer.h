//
//  VHContributionChartDrawer.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHContributionChartFaceDrawer.h"
#import "VHContributionBlock.h"

@interface VHContributionChartDrawer : NSObject

@property (nonatomic, strong, readonly) NSArray<VHContributionChartFaceDrawer *> *faces;

- (void)readyForDrawingFromContributionBlocks:(NSArray<VHContributionBlock *> *)contributionBlocks;

@end
