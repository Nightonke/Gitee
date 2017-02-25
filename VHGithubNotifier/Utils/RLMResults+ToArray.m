//
//  RLMResults+ToArray.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "RLMResults+ToArray.h"

@implementation RLMResults (ToArray)

- (NSArray<RLMObject *> *)toArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (RLMObject *object in self)
    {
        [array addObject:object];
    }
    return array;
}

@end
