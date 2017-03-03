//
//  NSMutableArray+Queue.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/1.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface NSMutableArray<ObjectType> (Queue)

- (ObjectType)front;

- (ObjectType)pop;

- (void)push:(ObjectType)obj;

@end
