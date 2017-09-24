//
//  VHGithubNotifierManager_Private.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/27.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#ifndef VHGithubNotifierManager_Private_h
#define VHGithubNotifierManager_Private_h

#import "VHUser.h"
#import "VHGithubNotifierManager.h"

@interface VHGithubNotifierManager ()

@property (nonatomic, strong) VHUser *backupUser;
@property (nonatomic, assign) BOOL hasLoadedLanguagesSuccessfully;
@property (nonatomic, assign) BOOL hasLoadedTrendingsSuccessfully;

@end

#endif /* VHGithubNotifierManager_Private_h */
