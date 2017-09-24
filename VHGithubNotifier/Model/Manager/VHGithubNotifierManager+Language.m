//
//  VHGithubNotifierManager+Language.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Language.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHHTTPResponseSerializer.h"
#import "VHLanguage.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHUtils+TransForm.h"
#import "RLMResults+ToArray.h"
#import "VHGithubNotifierManager_Private.h"

NSInteger const AllLanguageID = -20001;
NSInteger const UnknownLanguageID = -20002;

static NSTimer *languageTimer;
static VHLoadStateType languagesLoadState = VHLoadStateTypeDidNotLoad;
static NSString *languageUrl = @"https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml";

@implementation VHGithubNotifierManager (Language)

#pragma mark - Public Methods

- (void)innerInitializeLanguages
{
    VHLanguage *allLanguage = [[VHLanguage alloc] init];
    allLanguage.languageId = AllLanguageID;
    allLanguage.name = @"All Languages";
    allLanguage.requestName = @"";
    allLanguage.colorValue = THEME_COLOR_STRING;
    
    VHLanguage *unknownLanguage = [[VHLanguage alloc] init];
    unknownLanguage.languageId = UnknownLanguageID;
    unknownLanguage.name = @"Unknown Languages";
    unknownLanguage.requestName = @"unknown";
    unknownLanguage.colorValue = THEME_COLOR_STRING;
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:allLanguage];
    [realm addOrUpdateObject:unknownLanguage];
    [realm commitWriteTransaction];
}

- (void)startTimerOfLanguage
{
    MUST_IN_MAIN_THREAD;
    LanguageLog(@"Start Timer");
    languageTimer = [NSTimer scheduledTimerWithTimeInterval:[self languageUpdateTime]
                                                     target:self
                                                   selector:@selector(innerUpdateLanguage)
                                                   userInfo:nil
                                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:languageTimer forMode:NSDefaultRunLoopMode];
    [languageTimer fire];
}

- (void)stopTimerOfLanguage
{
    MUST_IN_MAIN_THREAD;
    LanguageLog(@"Stop Timer");
    [languageTimer invalidate];
    languageTimer = nil;
}

- (void)updateLanguages
{
    IN_MAIN_THREAD({
        LanguageLog(@"Update language");
        [self stopTimerOfLanguage];
        [self startTimerOfLanguage];
    });
}

- (VHLoadStateType)languagesLoadState
{
    return languagesLoadState;
}

- (NSInteger)matchLanguageIndexFromSearchString:(NSString *)searchLanguageName
{
    __block NSInteger index = 0;
    [self.languages enumerateObjectsUsingBlock:^(VHLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *lowercaseSearchLanguageName = [searchLanguageName lowercaseString];
        NSString *lowercaseLanguageName = [obj.name lowercaseString];
        if ([lowercaseLanguageName hasPrefix:lowercaseSearchLanguageName])
        {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

#pragma mark - Private Methods

- (void)innerUpdateLanguage
{
    LanguageLog(@"Update language");
    languagesLoadState = VHLoadStateTypeLoading;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [VHHTTPResponseSerializer serializer];
    
    NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    WEAK_SELF(self);
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        STRONG_SELF(self);
        [manager invalidateSessionCancelingTasks:YES];
        NSMutableArray<VHLanguage *> *languages;
        if (error)
        {
            LanguageLog(@"Update language failed with error: %@", error);
            languages = [NSMutableArray arrayWithArray:(NSArray<VHLanguage *> *)[[VHLanguage allObjects] toArray]];
            [self sortLanguages:languages];
            [self addSpecialLanguages:languages];
            self.languages = [languages mutableCopy];
            if (self.languages.count == 0)
            {
                // Some errors happens, so that we cannot get the languages
                languagesLoadState = VHLoadStateTypeLoadFailed;
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedFailed);
            }
            else
            {
                self.hasLoadedLanguagesSuccessfully = YES;
                languagesLoadState = VHLoadStateTypeLoadSuccessfully;
                [self updateTrending];
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLanguageLoadedSuccessfully);
            }
        }
        else
        {
            LanguageLog(@"Update language successfully");
            languages = [NSMutableArray arrayWithArray:[VHLanguage languagesFromData:responseObject]];
            [self sortLanguages:languages];
            [self addSpecialLanguages:languages];
            self.languages = [languages mutableCopy];
            self.hasLoadedLanguagesSuccessfully = YES;
            @autoreleasepool
            {
                RLMRealm *realm = [[VHGithubNotifierManager sharedManager] realm];
                [realm beginWriteTransaction];
                [realm addOrUpdateObjectsFromArray:self.languages];
                [realm commitWriteTransaction];
            }
            languagesLoadState = VHLoadStateTypeLoadSuccessfully;
            NOTIFICATION_POST(kNotifyLanguageLoadedSuccessfully);
            [self updateTrending];
        }
    }];
    [dataTask resume];
}

- (void)sortLanguages:(NSMutableArray<VHLanguage *> *)languages
{
    [languages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        VHLanguage *l1 = SAFE_CAST(obj1, [VHLanguage class]);
        VHLanguage *l2 = SAFE_CAST(obj2, [VHLanguage class]);
        return [l1.name compare:l2.name];
    }];
}

- (void)addSpecialLanguages:(NSMutableArray<VHLanguage *> *)languages
{
    __block BOOL existAllLanguage = NO;
    __block BOOL existUnknownLanguage = NO;
    [languages enumerateObjectsUsingBlock:^(VHLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.languageId == AllLanguageID)
        {
            existAllLanguage = YES;
        }
        if (obj.languageId == UnknownLanguageID)
        {
            existUnknownLanguage = YES;
        }
    }];
    if (!existUnknownLanguage)
    {
        VHLanguage *unknownLanguage = [[VHLanguage alloc] init];
        unknownLanguage.languageId = UnknownLanguageID;
        unknownLanguage.name = @"Unknown Languages";
        unknownLanguage.requestName = @"unknown";
        unknownLanguage.colorValue = THEME_COLOR_STRING;
        [languages insertObject:unknownLanguage atIndex:0];
    }
    if (!existAllLanguage)
    {
        VHLanguage *allLanguage = [[VHLanguage alloc] init];
        allLanguage.languageId = AllLanguageID;
        allLanguage.name = @"All Languages";
        allLanguage.requestName = @"";
        allLanguage.colorValue = THEME_COLOR_STRING;
        [languages insertObject:allLanguage atIndex:0];
    }
}

@end
