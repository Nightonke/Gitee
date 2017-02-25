//
//  NSArray+Safe.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface NSArray<ObjectType> (Safe)

- (ObjectType)safeObjectAtIndex:(NSUInteger)index;

@end
