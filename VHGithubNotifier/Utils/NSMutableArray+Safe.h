//
//  NSMutableArray+Safe.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/29.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

@interface NSMutableArray<ObjectType> (Safe)

- (ObjectType)safeObjectAtIndex:(NSUInteger)index;

@end
