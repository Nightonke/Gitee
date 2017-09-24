//
//  VHGithubNotifierManager+Trending.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Trending.h"
#import "VHTrendingRepository.h"
#import "TFHpple.h"
#import "VHHTTPResponseSerializer.h"
#import "VHUtils+TransForm.h"
#import "NSMutableArray+Safe.h"
#import "NSArray+Safe.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager_Private.h"

static const NSUInteger REPOSITORIES_IN_ONE_PAGE = 25;
static VHLoadStateType trendingContentLoadState = VHLoadStateTypeDidNotLoad;
static NSTimer *trendingTimer;

@implementation VHGithubNotifierManager (Trending)

#pragma mark - Public Methods

- (void)startTimerOfTrending
{
    MUST_IN_MAIN_THREAD;
    TrendingLog(@"Start Trending");
    trendingTimer = [NSTimer scheduledTimerWithTimeInterval:[self trendingUpdateTime]
                                                     target:self
                                                   selector:@selector(innerUpdateTrending)
                                                   userInfo:nil
                                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:trendingTimer forMode:NSDefaultRunLoopMode];
    [trendingTimer fire];
}

- (void)stopTimerOfTrending
{
    MUST_IN_MAIN_THREAD;
    TrendingLog(@"Stop Timer");
    [trendingTimer invalidate];
    trendingTimer = nil;
}

- (void)updateTrending
{
    IN_MAIN_THREAD({
        TrendingLog(@"Update notification");
        [self stopTimerOfTrending];
        [self startTimerOfTrending];
    });
}

- (VHLoadStateType)trendingContentLoadState
{
    return trendingContentLoadState;
}

- (BOOL)hasValidTrendingData
{
    return self.trendingContentLoadState == VHLoadStateTypeLoadSuccessfully && self.trendingRepositories.count > 0;
}

#pragma mark - Private Methods

- (void)innerUpdateTrending
{
    [self updateTrendingContentByLanguageIDs:[[VHGithubNotifierManager sharedManager] trendingSelectedLanguageIDs]
                                   timeIndex:[[VHGithubNotifierManager sharedManager] trendingTimeSelectedIndex]];
}

- (void)updateTrendingContentByLanguageIDs:(NSArray<NSNumber *> *)languageIDs timeIndex:(NSUInteger)timeIndex
{
    trendingContentLoadState = VHLoadStateTypeLoading;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [VHHTTPResponseSerializer serializer];
    
    dispatch_queue_t queue = dispatch_queue_create("Gitee", DISPATCH_QUEUE_CONCURRENT);
    manager.completionQueue = queue;
    
    NSString *timeString = [[NSArray arrayWithObjects:@"today", @"weekly", @"monthly", nil] safeObjectAtIndex:timeIndex];
    NSArray<NSString *> *languageNames = [self languageRequestNamesFromIDs:languageIDs];
    
    dispatch_group_t group = dispatch_group_create();
    __block NSUInteger successNumber = 0;
    __block NSMutableArray<VHTrendingRepository *> *trendingRepositories = [NSMutableArray arrayWithCapacity:languageNames.count * 25];
    for (NSString *languageName in languageNames)
    {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/trending/%@?since=%@", languageName, timeString]];
        TrendingLog(@"Update trending with URL: %@", URL);
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        dispatch_group_enter(group);
        WEAK_SELF(self);
        dispatch_async(queue, ^{
            NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                STRONG_SELF(self);
                if (error)
                {
                    TrendingLog(@"%@ - Update trending failed with error: %@", languageName, error);
                    dispatch_group_leave(group);
                }
                else
                {
                    IN_GLOBAL_THREAD({
                        @synchronized(trendingRepositories)
                        {
                            id filledResponseObject = [self fillEmptyRepositoryDescription:responseObject];
                            NSArray<VHTrendingRepository *> *partTrendingRepositories = [self trendingRepositoriesFromHtmlString:filledResponseObject];
                            if (partTrendingRepositories.count == 0)
                            {
                                TrendingLog(@"%@ - Update trending failed because trending repositories results are currently being dissected", languageName);
                            }
                            else
                            {
                                TrendingLog(@"%@ - Update trending successfully with repositories number: %zd", languageName, partTrendingRepositories.count);
                                successNumber++;
                                [trendingRepositories addObjectsFromArray:partTrendingRepositories];
                            }
                            dispatch_group_leave(group);
                        }
                    });
                }
            }];
            [dataTask resume];
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        TrendingLog(@"Update trending for %lu languages, %zd success", (unsigned long)languageNames.count, successNumber);
        if (trendingRepositories.count == 0)
        {
            if (!self.hasLoadedTrendingsSuccessfully)
            {
                TrendingLog(@"Update trending failed because trending repositories results are currently being dissected");
                trendingContentLoadState = VHLoadStateTypeLoadFailed;
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedFailed);
            }
            else
            {
                TrendingLog(@"Use the old trendings");
                [self trendingLoadedSuccessfully:nil];
            }
        }
        else
        {
            [self trendingLoadedSuccessfully:trendingRepositories];
        }
    });
}

- (void)trendingLoadedSuccessfully:(NSMutableArray<VHTrendingRepository *> *)newTrendings
{
    if (newTrendings.count > 0)
    {
        self.hasLoadedTrendingsSuccessfully = YES;
        self.trendingRepositories = newTrendings;
        [self removeDuplicateAndSortForRepositories];
        TrendingLog(@"Update trending successfully with repositories number: %zd", self.trendingRepositories.count);
    }
    trendingContentLoadState = VHLoadStateTypeLoadSuccessfully;
    NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedSuccessfully);
}

- (void)updateTrendingContentByLanguageIndex:(NSUInteger)languageIndex timeIndex:(NSUInteger)timeIndex
{
    trendingContentLoadState = VHLoadStateTypeLoading;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [VHHTTPResponseSerializer serializer];
    
    NSString *timeString = [[NSArray arrayWithObjects:@"today", @"weekly", @"monthly", nil] safeObjectAtIndex:timeIndex];
    NSString *languageString = @"";
    if (languageIndex == 0)
    {
        languageString = @"";
    }
    else if (languageIndex == 1)
    {
        languageString = @"unknown";
    }
    else if (languageIndex >= 2 && languageIndex < self.languages.count + 2)
    {
        VHLanguage *language = [self.languages safeObjectAtIndex:languageIndex - 2];
        languageString = [VHUtils encodeToPercentEscapeString:language.name];
    }
    else
    {
        languageString = @"";
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/trending/%@?since=%@",
                                       languageString,
                                       timeString]];
    TrendingLog(@"Update trending with URL: %@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    WEAK_SELF(self);
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        STRONG_SELF(self);
        [manager invalidateSessionCancelingTasks:YES];
        if (error)
        {
            TrendingLog(@"Update trending failed with error: %@", error);
            trendingContentLoadState = VHLoadStateTypeLoadFailed;
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedFailed);
        }
        else
        {
            IN_GLOBAL_THREAD({
                id filledResponseObject = [self fillEmptyRepositoryDescription:responseObject];
                self.trendingRepositories = [self trendingRepositoriesFromHtmlString:filledResponseObject];
                IN_MAIN_THREAD({
                    if (self.trendingRepositories.count == 0)
                    {
                        TrendingLog(@"Update trending failed because trending repositories results are currently being dissected");
                        trendingContentLoadState = VHLoadStateTypeLoadFailed;
                        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedFailed);
                    }
                    else
                    {
                        TrendingLog(@"Update trending successfully with repositories number: %zd", self.trendingRepositories.count);
                        trendingContentLoadState = VHLoadStateTypeLoadSuccessfully;
                        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedSuccessfully);
                    }
                });
            });
        }
    }];
    [dataTask resume];
}

- (VHTrendingRepository *)trendingRepositoryFromElement:(TFHppleElement *)element
{
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:[element.raw dataUsingEncoding:NSUTF8StringEncoding]];
    VHTrendingRepository *repository = [[VHTrendingRepository alloc] init];
    
    // Urls, names and owner accounts
    NSArray *dataArray = [hpple searchWithXPathQuery:@"//div"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"d-inline-block col-9 mb-1"])
        {
            if (element.children.count > 1)
            {
                TFHppleElement *h3Element = [element.children objectAtIndex:1];
                if (h3Element.children.count > 1)
                {
                    TFHppleElement *aElement = [h3Element.children objectAtIndex:1];
                    repository.url = [NSString stringWithFormat:@"https://github.com%@", [aElement objectForKey:@"href"]];
                    if (aElement.children.count > 2)
                    {
                        TFHppleElement *spanElement = [aElement.children objectAtIndex:1];
                        repository.ownerAccount = [self ownerAccountStringFromOriginalString:spanElement.content];
                        TFHppleElement *nodeContentElement = [aElement.children objectAtIndex:2];
                        repository.name = [self nameStringFromOriginalString:nodeContentElement.content];
                    }
                }
            }
        }
    }
    
    // Descriptions
    dataArray = [hpple searchWithXPathQuery:@"//p"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"col-9 d-inline-block text-gray m-0 pr-4"])
        {
            repository.repositoryDescription = [self repositoryDescriptionStringFromOriginalString:element.content];
        }
    }
    
    // Languages
    dataArray = [hpple searchWithXPathQuery:@"//span"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"itemprop"] isEqualToString:@"programmingLanguage"])
        {
            repository.languageName = [self languageNameStringFromOriginalString:element.content];
        }
    }
    
    // Colors of languages
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"repo-language-color ml-0"])
        {
            repository.languageColor = [self languageColorFromOriginalString:[element objectForKey:@"style"]
                                                            fromLanguageName:repository.languageName];
        }
    }
    
    // Trending tips
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"d-inline-block float-sm-right"])
        {
            repository.trendingTip = [self trendingTipStringFromOriginalString:element.content];
        }
    }
    
    // Number of stars and forks
    dataArray = [hpple searchWithXPathQuery:@"//a"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"muted-link d-inline-block mr-3"])
        {
            TFHppleElement *svgElement = SAFE_CAST([[element searchWithXPathQuery:@"//svg"] firstObject], [TFHppleElement class]);
            if (svgElement)
            {
                if ([[svgElement objectForKey:@"aria-label"] isEqualToString:@"star"])
                {
                    repository.starNumberString = [self starNumberStringFromOriginalString:element.content];
                }
                else if ([[svgElement objectForKey:@"aria-label"] isEqualToString:@"fork"])
                {
                    repository.forkNumberString = [self forkNumberStringFromOriginalString:element.content];
                }
            }
        }
    }
    
    // Avatars of contributors
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"no-underline"])
        {
            NSMutableArray<NSString *> *avatars = [NSMutableArray array];
            for (TFHppleElement *imgElement in element.children)
            {
                if ([[imgElement objectForKey:@"class"] isEqualToString:@"avatar mb-1"])
                {
                    [avatars addObject:[imgElement objectForKey:@"src"]];
                }
            }
            repository.contributorAvatars = avatars;
        }
    }

    return repository;
}

- (NSArray<VHTrendingRepository *> *)trendingRepositoriesFromHtmlString:(NSString *)htmlString
{
    NSMutableArray<VHTrendingRepository *> *repositories = [NSMutableArray arrayWithCapacity:REPOSITORIES_IN_ONE_PAGE];
    
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *dataArray = [hpple searchWithXPathQuery:@"//li"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"col-12 d-block width-full py-4 border-bottom"])
        {
            VHTrendingRepository *repository = [self trendingRepositoryFromElement:element];
            if ([repository isValid])
            {
                [repositories addObject:repository];
            }
            else
            {
                NSAssert(NO, @"Trending repository is invalid!");
            }
        }
    }
    return [repositories copy];
}

- (NSString *)fillEmptyRepositoryDescription:(NSString *)htmlString
{
    return [htmlString stringByReplacingOccurrencesOfString:@"<div class=\"py-1\">\n  </div>"
                                                 withString:@"<div class=\"py-1\">\n      <p class=\"col-9 d-inline-block text-gray m-0 pr-4\">\n      </p>\n  </div>"];
}

- (NSString *)ownerAccountStringFromOriginalString:(NSString *)originalString
{
    if (originalString.length >= 3)
    {
        return [originalString substringToIndex:originalString.length - 3];
    }
    else
    {
        return originalString;
    }
}

- (NSString *)nameStringFromOriginalString:(NSString *)originalString
{
    if (originalString.length >= 1)
    {
        return [originalString substringToIndex:originalString.length - 1];
    }
    else
    {
        return originalString;
    }
}

- (NSString *)repositoryDescriptionStringFromOriginalString:(NSString *)originalString
{
    NSString *result = [originalString stringByReplacingOccurrencesOfString:@"\n        " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n      " withString:@""];
    return result;
}

- (NSString *)languageNameStringFromOriginalString:(NSString *)originalString
{
    NSString *result = [originalString stringByReplacingOccurrencesOfString:@"\n        " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n      " withString:@""];
    return result;
}

- (NSColor *)languageColorFromOriginalString:(NSString *)originalString fromLanguageName:(NSString *)name
{
    if (originalString.length >= 24)
    {
        return [VHUtils colorFromHexColorCodeInString:[originalString substringWithRange:NSMakeRange(17, 7)]];
    }
    else
    {
        __block NSColor *resultColor = nil;
        [[VHGithubNotifierManager sharedManager].languages enumerateObjectsUsingBlock:^(VHLanguage * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([language.name isEqualToString:name])
            {
                resultColor = language.color;
                *stop = YES;
            }
        }];
        if (resultColor)
        {
            return resultColor;
        }
        else
        {
            return [VHUtils randomColor];
        }
    }
}

- (NSString *)starNumberStringFromOriginalString:(NSString *)originalString
{
    NSString *result = [originalString stringByReplacingOccurrencesOfString:@"\n        " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n      " withString:@""];
    return result;
}

- (NSString *)forkNumberStringFromOriginalString:(NSString *)originalString
{
    NSString *result = [originalString stringByReplacingOccurrencesOfString:@"\n        " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n      " withString:@""];
    return result;
}

- (NSString *)trendingTipStringFromOriginalString:(NSString *)originalString
{
    NSString *result = [originalString stringByReplacingOccurrencesOfString:@"\n        " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n      " withString:@""];
    return result;
}

- (NSArray<NSString *> *)languageRequestNamesFromIDs:(NSArray<NSNumber *> *)IDs
{
    __block NSMutableArray<NSString *> *languageNames = [NSMutableArray arrayWithCapacity:IDs.count];
    [IDs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *IDNumber = SAFE_CAST(obj, [NSNumber class]);
        if (IDNumber)
        {
            NSInteger ID = [IDNumber integerValue];
            for (VHLanguage *language in self.languages)
            {
                if (language.languageId == ID)
                {
                    [languageNames addObject:language.requestName];
                    break;
                }
            }
        }
    }];
    if (languageNames.count == 0)
    {
        [languageNames addObject:@""];  // All language by default
    }
    return [languageNames copy];
}

- (void)removeDuplicateAndSortForRepositories
{
    NSMutableArray<VHTrendingRepository *> *mutableTrendingRepositories = [NSMutableArray arrayWithArray:[self.trendingRepositories sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        VHTrendingRepository *r1 = SAFE_CAST(obj1, [VHTrendingRepository class]);
        VHTrendingRepository *r2 = SAFE_CAST(obj2, [VHTrendingRepository class]);
        if (r1.trendingTipStarNumber > r2.trendingTipStarNumber)
        {
            return NSOrderedAscending;
        }
        else if (r1.trendingTipStarNumber < r2.trendingTipStarNumber)
        {
            return NSOrderedDescending;
        }
        else
        {
            if (r1.starNumber > r2.starNumber)
            {
                return NSOrderedAscending;
            }
            else if (r1.starNumber < r2.starNumber)
            {
                return NSOrderedDescending;
            }
            else
            {
                if (r1.forkNumber > r2.forkNumber)
                {
                    return NSOrderedAscending;
                }
                else if (r1.forkNumber < r2.forkNumber)
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return [r1.name compare:r2.name];
                }
            }
        }
    }]];
    
    for (unsigned long i = mutableTrendingRepositories.count - 1; i > 0; i--)
    {
        if (i > 0)
        {
            if ([mutableTrendingRepositories[i].url isEqualToString:mutableTrendingRepositories[i - 1].url])
            {
                [mutableTrendingRepositories removeObjectAtIndex:i];
            }
        }
    }
    
    self.trendingRepositories = [mutableTrendingRepositories copy];
}

@end
