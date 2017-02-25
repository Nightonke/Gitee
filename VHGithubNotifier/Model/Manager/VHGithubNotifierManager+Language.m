//
//  VHGithubNotifierManager+Language.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Language.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHHTTPResponseSerializer.h"
#import "VHLanguage.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHUtils+TransForm.h"
#import "RLMResults+ToArray.h"

static VHLoadStateType languagesLoadState = VHLoadStateTypeDidNotLoad;

@implementation VHGithubNotifierManager (Language)

#pragma mark - Public Methods

- (void)updateLanguages
{
    NSLog(@"[Notifier] Update language");
    languagesLoadState = VHLoadStateTypeLoading;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [VHHTTPResponseSerializer serializer];
    
    NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            NSLog(@"[Notifier] Update language failed with error: %@", error);
            self.languages = (NSArray<VHLanguage *> *)[[VHLanguage allObjects] toArray];
            [self sortLanguages];
            if (self.languages == nil)
            {
                // Some errors happens, so that we cannot get the languages
                languagesLoadState = VHLoadStateTypeLoadFailed;
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedFailed);
            }
            else
            {
                languagesLoadState = VHLoadStateTypeLoadSuccessfully;
                [self updateTrendingContent];
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedSuccessfully);
            }
        }
        else
        {
            NSLog(@"[Notifier] Update language successfully from github");
            self.languages = [VHLanguage languagesFromData:responseObject];
            [self sortLanguages];
            @autoreleasepool
            {
                RLMRealm *realm = [[VHGithubNotifierManager sharedManager] realm];
                [realm beginWriteTransaction];
                [realm addOrUpdateObjectsFromArray:self.languages];
                [realm commitWriteTransaction];
                languagesLoadState = VHLoadStateTypeLoadSuccessfully;
                NOTIFICATION_POST(kNotifyLanguageLoadedSuccessfully);
                [self updateTrendingContent];
            }
        }
    }];
    [dataTask resume];
    
//    self.languages = (NSArray<VHLanguage *> *)[[VHLanguage allObjects] toArray];
//    [self sortLanguages];
//    if (self.languages == nil)
//    {
//        // Some errors happens, so that we cannot get the languages
//        languagesLoadState = VHLoadStateTypeLoadFailed;
//        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedFailed);
//    }
//    else
//    {
//        languagesLoadState = VHLoadStateTypeLoadSuccessfully;
//        [self updateTrendingContent];
//        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedSuccessfully);
//    }
}

- (VHLoadStateType)languagesLoadState
{
    return languagesLoadState;
}

#pragma mark - Private Methods

- (void)sortLanguages
{
    self.languages = [self.languages sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        VHLanguage *l1 = SAFE_CAST(obj1, [VHLanguage class]);
        VHLanguage *l2 = SAFE_CAST(obj2, [VHLanguage class]);
        return [l1.name compare:l2.name];
    }];
}

@end
