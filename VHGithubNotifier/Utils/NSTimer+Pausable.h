//
//  NSTimer+Pausable.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface NSTimer (Pausable)

- (void)pauseOrResume;

- (void)pause;

- (void)resume;

- (BOOL)isPaused;

@end
