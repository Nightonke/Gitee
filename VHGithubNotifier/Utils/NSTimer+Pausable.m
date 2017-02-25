//
//  NSTimer+Pausable.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSTimer+Pausable.h"

@interface NSTimer (CVPausablePrivate)

@property (nonatomic) NSNumber *timeDeltaNumber;

@end

@implementation NSTimer (CVPausablePrivate)

static NSNumber *associationKey;

- (NSNumber *)timeDeltaNumber
{
    return associationKey;
}

- (void)setTimeDeltaNumber:(NSNumber *)timeDeltaNumber
{
    associationKey = timeDeltaNumber;
}

@end

@implementation NSTimer (Pausable)

- (void)pauseOrResume
{
    if ([self isPaused])
    {
        self.fireDate = [[NSDate date] dateByAddingTimeInterval:[self.timeDeltaNumber doubleValue]];
        self.timeDeltaNumber = nil;
    }
    else
    {
        NSTimeInterval interval = [[self fireDate] timeIntervalSinceNow];
        self.timeDeltaNumber = @(interval);
        self.fireDate = [NSDate distantFuture];
    }
}

- (void)pause
{
    if ([self isPaused] == NO)
    {
        NSTimeInterval interval = [[self fireDate] timeIntervalSinceNow];
        self.timeDeltaNumber = @(interval);
        self.fireDate = [NSDate distantFuture];
    }
}

- (void)resume
{
    if ([self isPaused])
    {
        self.fireDate = [[NSDate date] dateByAddingTimeInterval:[self.timeDeltaNumber doubleValue]];
        self.timeDeltaNumber = nil;
    }
}

- (BOOL)isPaused
{
    return (self.timeDeltaNumber != nil);
}

@end
