//
//  AppDelegate.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/24.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "AppDelegate.h"
#import "NSView+Position.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+Realm.h"
#import "VHGithubNotifierManager+Language.h"
#import "VHGithubNotifierManager+Trending.h"
#import "VHGithubNotifierManager+Notification.h"
#import "VHStatusBarButton.h"
#import "VHUtils.h"
#import "VHBasicInfoView.h"
#import "VHRepositoryView.h"
#import "VHWindow.h"
#import "VHAccountInfoWC.h"

@interface AppDelegate ()<VHStatusBarButtonProtocol, NSMenuDelegate, VHWindowProtocol, VHAccountInfoWCDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenu *repositoriesMenu;

@property (nonatomic, strong) VHWindow *menuWindow;
@property (nonatomic, strong) VHAccountInfoWC *infoWC;

@end

@implementation AppDelegate

#pragma mark - Life

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    config.schemaVersion = 1;
    
    // Set the block which will be called automatically when opening a Realm with a
    // schema version lower than the one set above
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    };
    
    // Tell Realm to use this new configuration object for the default Realm
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    [RLMRealm defaultRealm];
    
    [[VHGithubNotifierManager sharedManager] loadUser];
    [[VHGithubNotifierManager sharedManager] redirectLogToDocuments];
    [[VHGithubNotifierManager sharedManager] updateLanguages];
    [self createStatusBarButton];
    self.repositoriesMenu.delegate = self;
    
    [self addNotifications];
    
    if ([[VHGithubNotifierManager sharedManager] userAccountInfoExist])
    {
        [self startWorkWhichNeedsUserAccountInfo];
    }
    else
    {
        self.infoWC = [[VHAccountInfoWC alloc] initWithWindowNibName:@"VHAccountInfoWC"];
        self.infoWC.accountInfoDelegate = self;
        [self.infoWC showWindow:self];        
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[VHGithubNotifierManager sharedManager] stop];
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Logic Methods

- (VHWindow *)menuWindow
{
    if (_menuWindow == nil)
    {
        _menuWindow = [[VHWindow alloc] initWithStatusItem:self.statusItem withDelegate:self];
    }
    return _menuWindow;
}

- (void)showMenu
{
    if ([self.menuWindow isVisible])
    {
        [[NSAnimationContext currentContext] setDuration:0.15];
        [[self.menuWindow animator] setAlphaValue:0.0];
        
        [self.menuWindow performSelector:@selector(orderOut:) withObject:self afterDelay:0.3];
    }
    else
    {
//        [self populate];
        NOTIFICATION_POST(kNotifyWindowWillAppear);
        NSRect statusItemFrame = [[self.statusItem.view window] convertRectToScreen:self.statusItem.view.frame];
        [self.menuWindow updateArrowWithStatusItemCenterX:statusItemFrame.origin.x + statusItemFrame.size.width / 2
                                      withStatusItemFrame:statusItemFrame];
        
        [self.menuWindow setAlphaValue:0.0];
        [self.menuWindow makeKeyAndOrderFront:self];
        [[NSAnimationContext currentContext] setDuration:0.15];
        [[self.menuWindow animator] setAlphaValue:1.0];
    }
}

- (void)hideMenu
{
    if ([self.menuWindow isVisible])
    {
        [[NSAnimationContext currentContext] setDuration:0.15];
        [[self.menuWindow animator] setAlphaValue:0.0];
        
        [self.menuWindow performSelector:@selector(orderOut:) withObject:self afterDelay:0.3];
    }
}

- (void)startWorkWhichNeedsUserAccountInfo
{
    [[VHGithubNotifierManager sharedManager] startTimerOfUpdatingUserAccountInfoAndRepositoriesOfUser];
    [[VHGithubNotifierManager sharedManager] startTimerOfNotification];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideMenu)
                                                 name:kNotifyWindowShouldHide
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

#pragma mark - NSMenuDelegate

- (NSInteger)numberOfItemsInMenu:(NSMenu*)menu
{
    if (menu == self.repositoriesMenu)
    {
        return [[[[VHGithubNotifierManager sharedManager] user] allRepositories] count];
    }
    return 0;
}

- (BOOL)menu:(NSMenu*)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel
{
    if (menu == self.repositoriesMenu)
    {
        VHRepositoryView *repositoryView = (VHRepositoryView *)SAFE_CAST(item.view, [VHRepositoryView class]);
        if (repositoryView == nil)
        {
            repositoryView = [[VHRepositoryView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        }
        [repositoryView setRepository:[[VHGithubNotifierManager sharedManager].user.allRepositories objectAtIndex:index]];
        item.view = repositoryView;
    }
    return YES;
}

#pragma mark - VHWindowProtocol

- (void)onMouseClickedOutside
{
    [self hideMenu];
}

#pragma mark - Create Methods

- (void)createStatusBarButton
{
    VHStatusBarButton *statusBarButton = [[VHStatusBarButton alloc] init];
    statusBarButton.statusBarButtonDelegate = self;
    self.statusItem.view = statusBarButton;
}

- (NSStatusItem *)statusItem
{
    if (_statusItem == nil)
    {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    }
    return _statusItem;
}

#pragma mark - VHStatusBarButtonProtocol

- (void)onStatusBarButtonClicked
{
    [self showMenu];
}

- (void)onStatusBarButtonMoved
{
    [self hideMenu];
}

#pragma mark - VHAccountInfoWCDelegate

- (void)onUserAccountConfirmed
{
    [self startWorkWhichNeedsUserAccountInfo];
}

- (void)onAccountInfoWindowClosed
{
    if ([[VHGithubNotifierManager sharedManager] userAccountInfoExist] == NO)
    {
        [NSApp terminate:nil];
    }
}

@end
