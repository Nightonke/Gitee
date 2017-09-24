//
//  VHGithubNotifierManager+Language.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"

extern NSInteger const AllLanguageID;
extern NSInteger const UnknownLanguageID;

@interface VHGithubNotifierManager (Language)

- (void)innerInitializeLanguages;

- (void)startTimerOfLanguage;

- (void)stopTimerOfLanguage;

- (void)updateLanguages;

- (VHLoadStateType)languagesLoadState;

- (NSInteger)matchLanguageIndexFromSearchString:(NSString *)searchLanguageName;

@end
