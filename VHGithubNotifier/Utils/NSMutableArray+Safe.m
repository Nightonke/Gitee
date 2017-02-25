//
//  NSMutableArray+Safe.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/29.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end
