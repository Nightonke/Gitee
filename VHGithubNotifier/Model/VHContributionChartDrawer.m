//
//  VHContributionChartDrawer.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHContributionChartDrawer.h"
#import "VHGithubNotifierManager+UserDefault.h"

static const CGFloat alpha = 25;
static const CGFloat beta = 128;
static const CGFloat divideWidth = 1;
static const CGFloat a = 6;
static const CGFloat b = 6;
static const CGFloat leftMostX = 15;
static const CGFloat leftMostY = 230;
static const CGFloat maxContributionHeight = 200;
static const CGFloat minContributionHeight = 3;

@implementation VHContributionChartDrawer

- (void)readyForDrawingFromContributionBlocks:(NSArray<VHContributionBlock *> *)contributionBlocks
{
    // for point move
    // x1 and y1 for point move in the same column(week)
    // x2 and y2 for a point move to next column(week)
    CGPoint leftMostPoint = CGPointMake(leftMostX, leftMostY);
    CGFloat x1 = cos((180 - alpha - beta) / 180.0 * M_PI) * (b + divideWidth);
    CGFloat y1 = sin((180 - alpha - beta) / 180.0 * M_PI) * (b + divideWidth);
    CGFloat x2 = cos(alpha / 180.0 * M_PI) * (a + divideWidth);
    CGFloat y2 = sin(alpha / 180.0 * M_PI) * (a + divideWidth);
    
    // for points in right face of a block
    CGFloat xr = cos((180 - alpha - beta) / 180.0 * M_PI) * b;
    CGFloat yr = sin((180 - alpha - beta) / 180.0 * M_PI) * b;
    
    // for points in left face of a block
    CGFloat xl = cos(alpha / 180.0 * M_PI) * a;
    CGFloat yl = sin(alpha / 180.0 * M_PI) * a;
    
    // for points in top face of a block
    CGFloat xt = cos((180 - alpha - beta) / 180.0 * M_PI) * b;
    CGFloat yt = sin((180 - alpha - beta) / 180.0 * M_PI) * b;
    
    NSUInteger firstDayIndex = [self firstDayIndex:contributionBlocks];
    CGPoint firstPoint = CGPointMake(leftMostPoint.x + x1 * (6 - firstDayIndex),
                                     leftMostPoint.y - y1 * (6 - firstDayIndex));
    NSUInteger nowIndex = firstDayIndex;
    CGPoint nowPoint = CGPointMake(firstPoint.x, firstPoint.y);
    
    NSMutableArray<VHContributionChartFaceDrawer *> *faces = [NSMutableArray arrayWithCapacity:contributionBlocks.count * 3];
    
    CGFloat maxContributionData = CGFLOAT_MIN;
    for (VHContributionBlock *contribution in contributionBlocks)
    {
        maxContributionData = MAX(contribution.contributions, maxContributionData);
    }
    
    for (VHContributionBlock *contribution in contributionBlocks)
    {
        CGFloat h = minContributionHeight;
        if (contribution.contributions != 0)
        {
            h = contribution.contributions / maxContributionData * maxContributionHeight;
        }
        
        // draw the right face
        VHContributionChartFaceDrawer *face = [[VHContributionChartFaceDrawer alloc] init];
        face.p1 = nowPoint;
        face.p2 = CGPointMake(nowPoint.x + xr, nowPoint.y + yr);
        face.p3 = CGPointMake(nowPoint.x + xr, nowPoint.y + yr + h);
        face.p4 = CGPointMake(nowPoint.x, nowPoint.y + h);
        face.color = [contribution rightFaceColor];
        [faces addObject:face];
        
        // draw the left face
        face = [[VHContributionChartFaceDrawer alloc] init];
        face.p1 = nowPoint;
        face.p2 = CGPointMake(nowPoint.x - xl, nowPoint.y + yl);
        face.p3 = CGPointMake(nowPoint.x - xl, nowPoint.y + yl + h);
        face.p4 = CGPointMake(nowPoint.x, nowPoint.y + h);
        face.color = [contribution leftFaceColor];
        [faces addObject:face];
        
        // draw the top
        face = [[VHContributionChartFaceDrawer alloc] init];
        face.p1 = CGPointMake(nowPoint.x, nowPoint.y + h);
        face.p2 = CGPointMake(nowPoint.x - xl, nowPoint.y + yl + h);
        face.p3 = CGPointMake(nowPoint.x - xl + xt, nowPoint.y + yl + yt + h);
        face.p4 = CGPointMake(nowPoint.x + xr, nowPoint.y + yr + h);
        face.color = [contribution topFaceColor];
        [faces addObject:face];

        // move the point
        nowIndex = nowIndex + 1;
        if (nowIndex == 7)
        {
            nowIndex = 0;
            // move to next column(week)
            // first, move to the first point in its week
            nowPoint.x += 6 * x1;
            nowPoint.y += 6 * y1;
            // then, move to the first day in the next week
            nowPoint.x += x2;
            nowPoint.y -= y2;
        }
        else
        {
            // move to next day in the same week
            nowPoint.x -= x1;
            nowPoint.y -= y1;
        }
    }
    
    _faces = [faces copy];
}

- (NSUInteger)firstDayIndex:(NSArray<VHContributionBlock *> *)contributionBlocks
{
    if (contributionBlocks.count == 0)
    {
        return -1;
    }
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:[[contributionBlocks firstObject] date]];
    if ([[VHGithubNotifierManager sharedManager] weekStartFrom] == VHGithubWeekStartFromSunDay)
    {
        
        return [comp weekday] - 1;
    }
    else if ([[VHGithubNotifierManager sharedManager] weekStartFrom] == VHGithubWeekStartFromMonDay)
    {
        return ([comp weekday] + 5) % 7;
    }
    else
    {
        return [comp weekday] - 1;
    }
}

@end
