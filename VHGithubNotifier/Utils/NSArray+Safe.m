//
//  NSArray+Safe.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end
