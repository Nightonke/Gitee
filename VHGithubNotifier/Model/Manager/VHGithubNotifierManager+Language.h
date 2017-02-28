//
//  VHGithubNotifierManager+Language.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"

@interface VHGithubNotifierManager (Language)

- (void)startTimerOfLanguage;

- (void)stopTimerOfLanguage;

- (void)updateLanguages;

- (VHLoadStateType)languagesLoadState;

@end
