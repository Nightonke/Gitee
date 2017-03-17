//
//  VHGithubNotifierManager+Profile.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager+Profile.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHHTTPResponseSerializer.h"

static NSTimer *profileTimer;
static VHLoadStateType contributionLoadState = VHLoadStateTypeDidNotLoad;
static NSArray<VHContributionBlock *> *contributionBlocks;
static VHContributionChartDrawer *contributionChartDrawer;
static NSUInteger yearContributions;

@implementation VHGithubNotifierManager (Profile)

#pragma mark - Public Methods

- (void)startTimerOfProfile
{
    MUST_IN_MAIN_THREAD;
    ProfileLog(@"Start Timer");
    profileTimer = [NSTimer scheduledTimerWithTimeInterval:[self profileUpdateTime]
                                                    target:self
                                                  selector:@selector(innerUpdateProfile)
                                                  userInfo:nil
                                                   repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:profileTimer forMode:NSDefaultRunLoopMode];
    [profileTimer fire];
}

- (void)stopTimerOfProfile
{
    MUST_IN_MAIN_THREAD;
    ProfileLog(@"Stop Timer");
    [profileTimer invalidate];
    profileTimer = nil;
}

- (void)updateProfile
{
    IN_MAIN_THREAD({
        ProfileLog(@"Update profile");
        [self stopTimerOfProfile];
        [self startTimerOfProfile];
    });
}

- (VHLoadStateType)contributionLoadState
{
    return contributionLoadState;
}

- (NSArray<VHContributionBlock *> *)contributionBlocks
{
    if (contributionBlocks == nil)
    {
        contributionBlocks = [NSArray array];
    }
    return contributionBlocks;
}

- (BOOL)loginCookieExist:(BOOL)sendNotification
{
    BOOL loggedIn = NO;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies])
    {
        if ([cookie.name isEqualToString:@"logged_in"] && [cookie.value isEqualToString:@"yes"])
        {
            loggedIn = YES;
        }
    }
    
    if (sendNotification)
    {
        if (loggedIn)
        {
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLoginCookieGotSuccessfully);
        }
        else
        {
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyLoginCookieGotFailed);
        }
    }
    
    return loggedIn;
}

- (VHContributionChartDrawer *)contributionChartDrawer
{
    return contributionChartDrawer;
}

- (NSUInteger)yearContributions
{
    return yearContributions;
}

- (NSString *)yearContributionsTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    NSMutableString *timeString = [NSMutableString stringWithFormat:@""];
    NSString *firstContributionDate = [dateFormatter stringFromDate:[contributionBlocks firstObject].date];
    NSString *lastContributionDate = [dateFormatter stringFromDate:[contributionBlocks lastObject].date];
    if (firstContributionDate && lastContributionDate)
    {
        [timeString appendString:[dateFormatter stringFromDate:[contributionBlocks firstObject].date]];
        [timeString appendString:@" — "];
        [timeString appendString:[dateFormatter stringFromDate:[contributionBlocks lastObject].date]];
    }
    return [timeString copy];
}

- (NSUInteger)todayContributions
{
    return [contributionBlocks lastObject].contributions;
}

- (NSString *)todayContributionsTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    return [dateFormatter stringFromDate:[contributionBlocks lastObject].date];
}

- (void)updateContributionChartLocally
{
    dispatch_async(GLOBAL_QUEUE, ^{
        if (contributionChartDrawer == nil)
        {
            contributionChartDrawer = [[VHContributionChartDrawer alloc] init];
        }
        [contributionChartDrawer readyForDrawingFromContributionBlocks:contributionBlocks];
        NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyContributionChartChanged);
    });
}

#pragma mark - Private Methods

- (void)innerUpdateProfile
{
    [self innerUpdateContributions];
}

- (void)innerUpdateContributions
{
    ProfileLog(@"Update contributions");
    contributionLoadState = VHLoadStateTypeLoading;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [VHHTTPResponseSerializer serializer];
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString string];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies])
    {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // prevent duplicate cookies
    for (NSString *key in cookieDic)
    {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", self.user.account]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:cookieValue forHTTPHeaderField:@"Cookie"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            ProfileLog(@"Update contributions failed with error: %@", error);
            contributionLoadState = VHLoadStateTypeLoadFailed;
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyContributionBlocksLoadedFailed);
        }
        else
        {
            ProfileLog(@"Update contributions successfully");
            contributionLoadState = VHLoadStateTypeLoadSuccessfully;
            
            NSMutableArray<VHContributionBlock *> *blocks = [NSMutableArray arrayWithCapacity:365];
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:[responseObject dataUsingEncoding:NSUTF8StringEncoding]];
            NSArray *dataArray = [hpple searchWithXPathQuery:@"//rect"];
            for (TFHppleElement *element in dataArray)
            {
                if ([[element objectForKey:@"class"] isEqualToString:@"day"])
                {
                    [blocks addObject:[[VHContributionBlock alloc] initWithHppleElement:element]];
                }
            }
            contributionBlocks = [blocks copy];
            [self calculateYearContributions];
            
            if (contributionChartDrawer == nil)
            {
                contributionChartDrawer = [[VHContributionChartDrawer alloc] init];
            }
            [contributionChartDrawer readyForDrawingFromContributionBlocks:contributionBlocks];
            
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyContributionBlocksLoadedSuccessfully);
        }
    }];
    [dataTask resume];
}

- (void)calculateYearContributions
{
    yearContributions = 0;
    for (VHContributionBlock *contribution in contributionBlocks)
    {
        yearContributions += contribution.contributions;
    }
}

@end
