//
//  VHGithubNotifierManager.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHGithubNotifierManager.h"
#import "UAGithubEngine.h"
#import "VHGithubNotifierManager_Private.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHGithubNotifierManager+Realm.h"

@interface VHGithubNotifierManager ()

@property (nonatomic, strong) NSTimer *basicInfoTimer;
@property NSMutableArray<VHRepository*> *updateRepositories;

@end

@implementation VHGithubNotifierManager

#pragma mark - Public Methods

- (void)startTimerOfBasicInfo
{
    MUST_IN_MAIN_THREAD;
    BasicInfoLog(@"Start Timer");
    self.basicInfoTimer = [NSTimer scheduledTimerWithTimeInterval:[self basicInfoUpdateTime]
                                                           target:self
                                                         selector:@selector(innerUpdateBasicInfo)
                                                         userInfo:nil
                                                          repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.basicInfoTimer forMode:NSDefaultRunLoopMode];
    [self.basicInfoTimer fire];
}

- (void)stopTimerOfBasicInfo
{
    MUST_IN_MAIN_THREAD;
    BasicInfoLog(@"Stop Timer");
    [self.basicInfoTimer invalidate];
    self.basicInfoTimer = nil;
}

- (void)updateBasicInfo
{
    IN_MAIN_THREAD({
        BasicInfoLog(@"Update basic info");
        [self stopTimerOfBasicInfo];
        [self startTimerOfBasicInfo];
    });
}

- (void)redirectLogToDocuments
{
    RELEASE_CODE(freopen([[[self logFileURL] path] cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr));
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
                ConfirmLog(@"Incorrect username or password");
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyUserAccountConfirmIncorrectUsernameOrPassword);
            }
            else
            {
                ConfirmLog(@"Other error: %@", error);
                NOTIFICATION_POST_IN_MAIN_THREAD(kNotifyUserAccountConfirmInternetFailed);
            }
        }];
    });
}

- (BOOL)userAccountInfoExist
{
    return [self userAccount] && [self userPassword];
}

+ (instancetype)sharedManager
{
    static VHGithubNotifierManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
    });
    return sharedManager;
}

#pragma mark - Private Methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(innerUpdateRepositories)
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
    SystemLog(@"Wake up");
    [self stopTimerOfBasicInfo];
    [self startTimerOfBasicInfo];
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

- (void)innerUpdateRepositories
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
                RELEASE_CODE(BasicInfoLog(@"Update repositories in page %d successed: %@", page, responseObject));
                DEBUG_CODE(BasicInfoLog(@"Update repositories in page %d successed", page));
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
                            BasicInfoLog(@"%@: %@ %@ ",
                                         [NSString stringWithFormat:@"% 3d", ++i + (page - 1) * 30],
                                         [NSString stringWithFormat:@"% 5lld", repository.starNumber],
                                         repository.name);
                        }
                    }
                    [self.updateRepositories addObjectsFromArray:newRepositories];
                }
                dispatch_group_leave(requestGroup);
            } failure:^(NSError *error) {
                BasicInfoLog(@"Update repositories in page %d failed with error: %@", page, error);
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
                BasicInfoLog(@"Repositories total star number: %lu", (unsigned long)[user starNumber]);
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
            BasicInfoLog(@"Not all of page of repositories updated successfully");
        }
    });
}

- (void)innerUpdateBasicInfo
{
    BasicInfoLog(@"Update basic info");
    RLMThreadSafeReference *userRef = nil;
    if (self.user)
    {
        userRef = [RLMThreadSafeReference referenceWithThreadConfined:self.user];
    }
    dispatch_async(GLOBAL_QUEUE, ^{
        // userWithSuccess spends a long time
        [[self engine] userWithSuccess:^(id responseObject) {
            RELEASE_CODE(BasicInfoLog(@"Update basic info successfully: %@", responseObject));
            DEBUG_CODE(BasicInfoLog(@"Update basic info successfully"));
            NSArray *array = SAFE_CAST(responseObject, [NSArray class]);
            if ([array count] != 0)
            {
                NSDictionary *dictionary = SAFE_CAST([array objectAtIndex:0], [NSDictionary class]);
                if (dictionary != nil)
                {
                    if (self.user == nil)
                    {
                        IN_MAIN_THREAD(self.user = [[VHUser alloc] initWithDataDictionary:dictionary];);
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
            BasicInfoLog(@"Update basic info failed with error: %@", error);
        }];
    });
}

@end
