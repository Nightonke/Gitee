//
//  VHGithubNotifierManager.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUser.h"
#import "VHLanguage.h"
#import "VHTrendingRepository.h"
#import "UAGithubEngine.h"

@interface VHGithubNotifierManager : NSObject

@property (nonatomic, strong) VHUser *user;
@property (nonatomic, strong) NSArray<VHLanguage *> *languages;
@property (nonatomic, strong) NSArray<VHTrendingRepository *> *trendingRepositories;

+ (instancetype)sharedManager;

- (UAGithubEngine *)engine;

- (void)startTimerOfBasicInfo;

- (void)stopTimerOfBasicInfo;

- (void)updateBasicInfo;

- (void)redirectLogToDocuments;

- (void)confirmUserAccount:(NSString *)username withPassword:(NSString *)password;

- (VHLoadStateType)repositoriesLoadState;

- (BOOL)userAccountInfoExist;

@end
