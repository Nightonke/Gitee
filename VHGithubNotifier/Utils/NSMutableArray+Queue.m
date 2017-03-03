//
//  NSMutableArray+Queue.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (id)front
{
    return [self firstObject];
}

- (id)pop
{
    id headObject = [self firstObject];
    if (headObject)
    {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

- (void)push:(id)obj
{
    [self addObject:obj];
}

@end
