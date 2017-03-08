//
//  VHContributionChartView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHContributionChartView.h"
#import "VHContributionBlock.h"
#import "VHGithubNotifierManager+Profile.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHUtils+TransForm.h"
#import "VHContributionChartDrawer.h"
#import "VHContributionChartFaceDrawer.h"

@implementation VHContributionChartView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    VHContributionChartDrawer *drawer = [[VHGithubNotifierManager sharedManager] contributionChartDrawer];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    path.lineWidth = 0;
    
    for (VHContributionChartFaceDrawer *faceDrawer in drawer.faces)
    {
        [path removeAllPoints];
        [path moveToPoint:faceDrawer.p1];
        [path lineToPoint:faceDrawer.p2];
        [path lineToPoint:faceDrawer.p3];
        [path lineToPoint:faceDrawer.p4];
        [faceDrawer.color set];
        [path closePath];
        [path fill];
    }
}

@end
