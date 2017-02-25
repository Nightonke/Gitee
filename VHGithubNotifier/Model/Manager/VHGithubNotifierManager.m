//
//  VHGithubNotifierManager.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import "UAGithubEngine.h"
#import "VHGithubNotifierUserDefaults.h"
#import "VHGithubNotifierManager_Private.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHGithubNotifierManager+Realm.h"

@interface VHGithubNotifierManager ()

@property (nonatomic, strong) NSTimer *basicInfoTimer;
@property (nonatomic, strong) NSTimer *trendingTimer;
@property NSMutableArray<VHRepository*> *updateRepositories;


@end

@implementation VHGithubNotifierManager

#pragma mark - Public Methods

+ (instancetype)sharedManager
{
    static VHGithubNotifierManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
    });
    return sharedManager;
}

- (void)startTimerOfUpdatingUserAccountInfoAndRepositoriesOfUser
{
    NSLog(@"[Notifier] Start Timer of updating user account info and repositories of user");
    self.basicInfoTimer = [NSTimer scheduledTimerWithTimeInterval:BASIC_INFO_UPDATE_TIME
                                                          repeats:YES
                                                            block:^(NSTimer * _Nonnull timer) {
        NSLog(@"----------------------------------------------------------------------------------------------------------");
        NSLog(@"[Notifier] Update basic info");
        [self innerLoadProfile];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.basicInfoTimer forMode:NSDefaultRunLoopMode];
    [self.basicInfoTimer fire];
}

- (void)stop
{
    [self.basicInfoTimer invalidate];
    self.basicInfoTimer = nil;
    [self.trendingTimer invalidate];
    self.trendingTimer = nil;
}

- (void)redirectLogToDocuments
{
//    RELEASE_CODE(freopen([[[self logFileURL] path] cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr));
}

- (void)confirmUserAccount:(NSString *)username withPassword:(NSString *)password
{
    dispatch_async(GLOBAL_QUEUE, ^{
        // userWithSuccess spends a long time
        UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:username
                                                                 password:password
                                                         withReachability:YES];
        [engine userWithSuccess:^(id responseObject) {
            [self setUserAccount:username];
            [self setUserPassword:password];
            NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyUserAccountConfirmSuccessfully);
        } failure:^(NSError *error) {
            if (error.code == NSURLErrorUserCancelledAuthentication)
            {
                NSLog(@"[confirmUserAccount] Incorrect user name or password");
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyUserAccountConfirmIncorrectUsernameOrPassword);
            }
            else
            {
                NSLog(@"[confirmUserAccount] Other error: %@", error);
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyUserAccountConfirmInternetFailed);
            }
        }];
    });
}

- (BOOL)userAccountInfoExist
{
    return [self userAccount] && [self userPassword];
}

#pragma mark - Private Methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(innerLoadRepositories)
                                                     name:kNotifyProfileLoadedSuccessfully
                                                   object:nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(resetFromWakeNotification)
                                                                   name:NSWorkspaceDidWakeNotification
                                                                 object: NULL];
        [self innerInitializeProperties];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)recoverUser
{
    _user = self.backupUser;
}

- (void)resetFromWakeNotification
{
    NSLog(@"[Notifier] Wake up");
    [self stop];
    [self startTimerOfUpdatingUserAccountInfoAndRepositoriesOfUser];
}

- (NSURL *)logFileURL
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    NSURL *desktopUrl = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *directoryUrl = [desktopUrl URLByAppendingPathComponent:@"GithubNotifierLogs"];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryUrl withIntermediateDirectories:YES attributes:nil error:nil];
    NSURL *fileUrl = [directoryUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"GithubNotifierLog_%@.log", stringFromDate]];
    return fileUrl;
}

- (UAGithubEngine *)engine
{
    return [[UAGithubEngine alloc] initWithUsername:[self userAccount] password:[self userPassword] withReachability:YES];
}

- (void)innerLoadRepositories
{
    NSUInteger repositoryPages;
    NSUInteger repositoryNumber = [[self user] repositoryNumber];
    if (repositoryNumber % 30 == 0)
    {
        repositoryPages = repositoryNumber / 30;
    }
    else
    {
        repositoryPages = repositoryNumber / 30 + 1;
    }
    dispatch_group_t requestGroup = dispatch_group_create();
    __block BOOL allSuccessful = NO;
    self.updateRepositories = [NSMutableArray array];
    for (int page = 1; page <= repositoryPages; page++)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_group_async(requestGroup, queue, ^{
            dispatch_group_enter(requestGroup);
            [[self engine] repositoriesForUser:[self userAccount] includeWatched:NO page:page success:^(id responseObject) {
                RELEASE_CODE(NSLog(@"Repositories in page %d successed: %@", page, responseObject));
                DEBUG_CODE(NSLog(@"Repositories in page %d successed", page));
                allSuccessful = YES;
                NSArray *array = SAFE_CAST(responseObject, [NSArray class]);
                if (array != nil)
                {
                    int i = 0;
                    NSMutableArray<VHRepository *> *newRepositories = [NSMutableArray arrayWithCapacity:[array count]];
                    for (id object in array)
                    {
                        NSDictionary *dictionary = SAFE_CAST(object, [NSDictionary class]);
                        if (dictionary != nil)
                        {
                            VHRepository *repository = [[VHRepository alloc] initWithDataDictionary:dictionary];
                            [newRepositories addObject:repository];
                            NSLog(@"%@: %@ %@ ",
                                  [NSString stringWithFormat:@"% 3d", ++i + (page - 1) * 30],
                                  [NSString stringWithFormat:@"% 5lld", repository.starNumber],
                                  repository.name);
                        }
                    }
                    [self.updateRepositories addObjectsFromArray:newRepositories];
                }
                dispatch_group_leave(requestGroup);
            } failure:^(NSError *error) {
                NSLog(@"Repositories failed: %@", error);
                allSuccessful = NO;
                dispatch_group_leave(requestGroup);
            }];
        });
    }
    RLMThreadSafeReference *userRef = nil;
    if (self.user)
    {
        userRef = [RLMThreadSafeReference referenceWithThreadConfined:self.user];
    }
    dispatch_group_notify(requestGroup, GLOBAL_QUEUE, ^{
        if (allSuccessful)
        {
            @autoreleasepool
            {
                RLMRealm *realm = [self realm];
                VHUser *user = [realm resolveThreadSafeReference:userRef];
                [user addRepositories:self.updateRepositories];
                NSLog(@"Repositories total star number: %lu", (unsigned long)[user starNumber]);
                // We need to reset star counter here.
                // Although the user above has updated the star count. Don't forget that
                // the starNumber is an ignored-property in RLMObject.
                // So, the starNumber of Manager.user is still zero.
                [self.user resetStarCount];
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyRepositoriesLoadedSuccessfully);
            }
        }
        else
        {
            NSLog(@"One of repository request failed.");
        }
    });
}

- (void)innerLoadProfile
{
    RLMThreadSafeReference *userRef = nil;
    if (self.user)
    {
        userRef = [RLMThreadSafeReference referenceWithThreadConfined:self.user];
    }
    dispatch_async(GLOBAL_QUEUE, ^{
        // userWithSuccess spends a long time
        [[self engine] userWithSuccess:^(id responseObject) {
            RELEASE_CODE(NSLog(@"Profile successed: %@", responseObject));
            DEBUG_CODE(NSLog(@"Profile successed"));
            NSArray *array = SAFE_CAST(responseObject, [NSArray class]);
            if ([array count] != 0)
            {
                NSDictionary *dictionary = SAFE_CAST([array objectAtIndex:0], [NSDictionary class]);
                if (dictionary != nil)
                {
                    if (self.user == nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.user = [[VHUser alloc] initWithDataDictionary:dictionary];
                        });
                    }
                    else
                    {
                        @autoreleasepool
                        {
                            RLMRealm *realm = [self realm];
                            VHUser *user = [realm resolveThreadSafeReference:userRef];
                            [user updateWithDataDictionary:dictionary];
                        }
                    }
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"Profile failed: %@", error);
        }];
    });
}

@end
