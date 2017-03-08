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
        }
        else
        {
            ProfileLog(@"Update contributions successfully");
        }
    }];
    [dataTask resume];
}

@end
