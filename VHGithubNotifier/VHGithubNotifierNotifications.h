//
//  VHGithubNotifierNotifications.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#ifndef VHGithubNotifierNotifications_h
#define VHGithubNotifierNotifications_h

// When  : When the profile of user is loaded.
// Who   : VHGithubNotifierManager
// To    : VHGithubNotifierManager
// Params:
static NSString * const kNotifyProfileLoadedSuccessfully = @"kNotifyProfileLoadedSuccessfully";

// When  : When the repositories of user is loaded.
// Who   : VHGithubNotifierManager
// To    : AppDelegate
// Params:
static NSString * const kNotifyRepositoriesLoadedSuccessfully = @"kNotifyRepositoriesLoadedSuccessfully";

// When  : When the github-content-types are changed.
// Who   : VHGithubNotifierManager/Settings
// To    : VCs
// Params:
static NSString * const kNotifyGithubContentsChanged = @"kNotifyGithubContentsChanged";

// When  : When the window is going to show.
// Who   : AppDelegate
// To    : VCs
// Params:
static NSString * const kNotifyWindowWillAppear = @"kNotifyWindowWillAppear";

#endif /* VHGithubNotifierNotifications_h */

// When  : When the languages are loaded successfully from github.
// Who   : VHGithubNotifierManager
// To    : VCs
// Params:
static NSString * const kNotifyLanguageLoadedSuccessfully = @"kNotifyLanguageLoadedSuccessfully";

// When  : When the languages are loaded failed from github.
// Who   : VHGithubNotifierManager
// To    : VCs
// Params:
static NSString * const kNotifyLanguageLoadedFailed = @"kNotifyLanguageLoadedFailed";

// When  : When the one trending content is loaded successfully from github.
// Who   : VHGithubNotifierManager
// To    : VCs
// Params:
static NSString * const kNotifyTrendingLoadedSuccessfully = @"kNotifyTrendingLoadedSuccessfully";

// When  : When the one trending content is loaded failed from github.
// Who   : VHGithubNotifierManager
// To    : VCs
// Params:
static NSString * const kNotifyTrendingLoadedFailed = @"kNotifyTrendingLoadedFailed";

// When  : When the window should be hide.
// Who   :
// To    : AppDelegate
// Params:
static NSString * const kNotifyWindowShouldHide = @"kNotifyWindowShouldHide";

// When  : In the process of user account confirming, successfully
// Who   : Manager
// To    : AccountWC
// Params:
static NSString * const kNotifyUserAccountConfirmSuccessfully = @"kNotifyUserAccountConfirmSuccessfully";

// When  : In the process of user account confirming, internet failed
// Who   : Manager
// To    : AccountWC
// Params:
static NSString * const kNotifyUserAccountConfirmInternetFailed = @"kNotifyUserAccountConfirmInternetFailed";

// When  : In the process of user account confirming, incorrect username or password
// Who   : Manager
// To    : AccountWC
// Params:
static NSString * const kNotifyUserAccountConfirmIncorrectUsernameOrPassword = @"kNotifyUserAccountConfirmIncorrectUsernameOrPassword";

// When  : When notifications are updated successfully from github.
// Who   : Manager
// To    :
// Params:
static NSString * const kNotifyNotificationsLoadedSuccessfully = @"kNotifyNotificationsLoadedSuccessfully";

// When  : When notifications are updated failed from github.
// Who   : Manager
// To    :
// Params:
static NSString * const kNotifyNotificationsLoadedFailed = @"kNotifyNotificationsLoadedFailed";
