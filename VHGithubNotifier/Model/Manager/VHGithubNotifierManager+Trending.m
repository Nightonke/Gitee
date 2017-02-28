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
#import "VHGithubNotifierUserDefaults.h"

static const NSUInteger REPOSITORIES_IN_ONE_PAGE = 25;
static VHLoadStateType trendingContentLoadState = VHLoadStateTypeDidNotLoad;
static NSTimer *trendingTimer;

@implementation VHGithubNotifierManager (Trending)

#pragma mark - Public Methods

- (void)updateTrendingContent
{
    IN_MAIN_THREAD([self resetTrendingTimer]);
}

- (VHLoadStateType)trendingContentLoadState
{
    return trendingContentLoadState;
}

#pragma mark - Private Methods

- (void)resetTrendingTimer
{
    [trendingTimer invalidate];
    trendingTimer = nil;
    trendingTimer = [NSTimer scheduledTimerWithTimeInterval:TRENDING_UPDATE_TIME
                                                    repeats:YES
                                                      block:^(NSTimer * _Nonnull timer) {
        NSLog(@"[Notifier] Update trending");
        [self innerUpdateTrendingContent];
    }];
    [[NSRunLoop currentRunLoop] addTimer:trendingTimer forMode:NSDefaultRunLoopMode];
    [trendingTimer fire];
}

- (void)innerUpdateTrendingContent
{
    [self updateTrendingContentByLanguageIndex:[[VHGithubNotifierManager sharedManager] trendingContentSelectedIndex]
                                     timeIndex:[[VHGithubNotifierManager sharedManager] trendingTimeSelectedIndex]];
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
    NSLog(@"[Notifier] Update trending with URL: %@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            NSLog(@"[Notifier] Update trending failed with error: %@", error);
            trendingContentLoadState = VHLoadStateTypeLoadFailed;
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedFailed);
        }
        else
        {
            responseObject = [self fillEmptyRepositoryDescription:responseObject];
            self.trendingRepositories = [self trendingRepositoriesFromHtmlString:responseObject];
            if (self.trendingRepositories.count == 0)
            {
                NSLog(@"[Notifier] Update trending failed because trending repositories results are currently being dissected.");
                trendingContentLoadState = VHLoadStateTypeLoadFailed;
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedFailed);
            }
            else
            {
                NSLog(@"[Notifier] Update trending successfully with repositories number: %zd", self.trendingRepositories.count);
                trendingContentLoadState = VHLoadStateTypeLoadSuccessfully;
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyTrendingLoadedSuccessfully);
            }
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
        if ([[element objectForKey:@"class"] isEqualToString:@"float-right"])
        {
            repository.trendingTip = [self trendingTipStringFromOriginalString:element.content];
        }
    }
    
    // Number of stars and forks
    dataArray = [hpple searchWithXPathQuery:@"//a"];
    for (TFHppleElement *element in dataArray)
    {
        if ([[element objectForKey:@"class"] isEqualToString:@"muted-link tooltipped tooltipped-s mr-3"])
        {
            if ([[element objectForKey:@"aria-label"] isEqualToString:@"Stargazers"])
            {
                repository.starNumber = [self starNumberStringFromOriginalString:element.content];
            }
            else if ([[element objectForKey:@"aria-label"] isEqualToString:@"Forks"])
            {
                repository.forkNumber = [self forkNumberStringFromOriginalString:element.content];
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

@end
