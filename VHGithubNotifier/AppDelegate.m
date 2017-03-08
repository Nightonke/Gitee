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
#import "VHGithubNotifierManager+Trend.h"
#import "VHGithubNotifierManager+Profile.h"
#import "VHStatusBarButton.h"
#import "VHUtils.h"
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
    config.schemaVersion = 2;
    
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
    
//    NSURL *desktopUrl = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
//    NSURL *parentUrl = [desktopUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"default.realm"]];
//    [[RLMRealm defaultRealm] writeCopyToURL:parentUrl encryptionKey:nil error:nil];
    
    [[VHGithubNotifierManager sharedManager] loadUser];
    [[VHGithubNotifierManager sharedManager] redirectLogToDocuments];
    [[VHGithubNotifierManager sharedManager] startTimerOfLanguage];
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
    [[VHGithubNotifierManager sharedManager] stopTimerOfBasicInfo];
    [[VHGithubNotifierManager sharedManager] stopTimerOfLanguage];
    [[VHGithubNotifierManager sharedManager] stopTimerOfTrending];
    [[VHGithubNotifierManager sharedManager] stopTimerOfNotification];
    [[VHGithubNotifierManager sharedManager] stopTimerOfProfile];
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
    NOTIFICATION_POST(kNotifyWindowWillShow);
    if ([self.menuWindow isVisible])
    {
        [self hideMenu];
    }
    else
    {
//        [self populate];
        NOTIFICATION_POST(kNotifyWindowWillAppear);
        NSRect statusItemFrame = [[self.statusItem.view window] convertRectToScreen:self.statusItem.view.frame];
//        NSLog(@"%zd", [NSScreen screens].count);
//        NSScreen *screen = [NSScreen mainScreen];
//        NSLog(@"%@", [[[NSApp currentEvent] window] screen]);
//        NSRect rect = [[[NSApp currentEvent] window] frame];
//        NSLog(@"%f, %f, %f, %f",
//              rect.origin.x,
//              rect.origin.y,
//              rect.size.width,
//              rect.size.height);
//        
//        for(NSScreen* screen in [NSScreen screens])
//        {
//            NSRect cocoaScreenFrame = [screen frame];
//            NSLog(@"Screen(%@) frame in Cocoa coordinate space: %@", screen, NSStringFromRect(cocoaScreenFrame));
//        }
//        
////        [self.menuWindow ]
//        [self.menuWindow constrainFrameRect:NSMakeRect(statusItemFrame.origin.x + statusItemFrame.size.width / 2,
//                                                       statusItemFrame.origin.y - self.menuWindow.frame.size.height - 5,
//                                                       self.menuWindow.frame.size.width,
//                                                       self.menuWindow.frame.size.height)
//                                   toScreen:[[[NSApp currentEvent] window] screen]];
//        NSLog(@"Window changed to %@", self.menuWindow.screen);
        [self.menuWindow updateArrowWithStatusItemCenterX:statusItemFrame.origin.x + statusItemFrame.size.width / 2
                                      withStatusItemFrame:statusItemFrame];
        
        [self.menuWindow setAlphaValue:0.0];
        [self.menuWindow makeKeyAndOrderFront:self];
        [[NSAnimationContext currentContext] setDuration:0.15];
        [[self.menuWindow animator] setAlphaValue:1.0];
    }
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (void)hideMenu
{
    NOTIFICATION_POST(kNotifyWindowWillHide);
    if ([self.menuWindow isVisible])
    {
        [[NSAnimationContext currentContext] setDuration:0.15];
        [[self.menuWindow animator] setAlphaValue:0.0];
        [self.menuWindow performSelector:@selector(orderOut:) withObject:self afterDelay:0.3];
    }
}

- (void)startWorkWhichNeedsUserAccountInfo
{
    [[VHGithubNotifierManager sharedManager] startTimerOfBasicInfo];
    [[VHGithubNotifierManager sharedManager] startTimerOfNotification];
    [[VHGithubNotifierManager sharedManager] startTimerOfProfile];
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
        SystemLog(@"Terminate in onAccountInfoWindowClosed method");
        [NSApp terminate:nil];
    }
}

@end
