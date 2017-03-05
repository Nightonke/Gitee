//
//  VHStatusBarButton.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHStatusBarButton.h"
#import "NSView+Position.h"
#import "VHUtils.h"
#import "VHGithubNotifierManager.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHGithubNotifierManager+Notification.h"
#import "VHUserNotificationWindow.h"

const static CGFloat STATUS_ICON_WIDTH = 22;
const static CGFloat STATUS_BAR_HEIGHT = 22;
const static CGFloat STATUS_ICON_STAR_TEXT_HORIZONTAL_OFFSET = -3;
const static CGFloat STATUS_ICON_FOLLOWER_TEXT_HORIZONTAL_OFFSET = -1;
const static CGFloat STATUS_ICON_NOTIFICATION_TEXT_HORIZONTAL_OFFSET = -2;
const static CGFloat TEXT_EXTRA_PADDING = 5;

@interface VHStatusBarButton ()

@property (nonatomic, strong) NSImageView *githubIcon;

@property (nonatomic, strong) NSImageView *starImage;
@property (nonatomic, strong) NSTextField *starText;
@property (nonatomic, strong) NSTextField *animateStarText;
@property (nonatomic, copy) NSString *starString;
@property (nonatomic, copy) NSString *lastStarString;

@property (nonatomic, strong) NSImageView *followerImage;
@property (nonatomic, strong) NSTextField *followerText;
@property (nonatomic, strong) NSTextField *animateFollowerText;
@property (nonatomic, copy) NSString *followerString;
@property (nonatomic, copy) NSString *lastFollowerString;

@property (nonatomic, strong) NSImageView *notificationImage;
@property (nonatomic, strong) NSTextField *notificationText;
@property (nonatomic, strong) NSTextField *animateNotificationText;
@property (nonatomic, copy) NSString *notificationString;
@property (nonatomic, copy) NSString *lastNotificationString;

@property (nonatomic, assign) BOOL isDarkMode;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) BOOL isFirstMove;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation VHStatusBarButton

#pragma mark - Public Methods

- (instancetype)init
{
    return [self initWithFrame:NSMakeRect(0, 0, 0, STATUS_BAR_HEIGHT)];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _starString = @"0";
        _lastStarString = @"0";
        _followerString = @"0";
        _lastFollowerString = @"0";
        _notificationString = @"0";
        _lastNotificationString = @"0";
        _isDarkMode = [VHUtils isDarkMode];
        _isPressed = NO;
        _isFirstMove = YES;
        [self setBordered:NO];
        [self setSelectable:NO];
        
        [self loadViews];
        
        [self updateStringsAndPositions];
        [self updateColorsWithPressed:_isPressed];
        
        [self addNotifications];
        [self onNotifyRepositoriesLoadedSuccessfully:nil];
    }
    return self;
}

#pragma mark - Life

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Logic Methods

- (void)loadViews
{
    [self removeAllSubViews];
    
    NSUInteger contents = [[VHGithubNotifierManager sharedManager] statusBarButtonContents];
    CGFloat width = 0;
    if (contents == VHStatusBarButtonContentTypeGithubIcon)
    {
        self.githubIcon = [[NSImageView alloc] initWithFrame:CGRectMake(width, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:self.githubIcon];
        width = [self.githubIcon getRight];
    }
    if (contents & VHStatusBarButtonContentTypeStargazers)
    {
        self.starImage = [[NSImageView alloc] initWithFrame:CGRectMake(width, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:self.starImage];
        width = [self.starImage getRight];
        self.starText = [self textFieldWithFrame:CGRectMake(width + STATUS_ICON_STAR_TEXT_HORIZONTAL_OFFSET, 2, 0, STATUS_BAR_HEIGHT)];
        [self addSubview:self.starText];
        width = [self.starText getRight];
    }
    if (contents & VHStatusBarButtonContentTypeFollowers)
    {
        self.followerImage = [[NSImageView alloc] initWithFrame:CGRectMake(width, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:self.followerImage];
        width = [self.followerImage getRight];
        self.followerText = [self textFieldWithFrame:CGRectMake(width + STATUS_ICON_FOLLOWER_TEXT_HORIZONTAL_OFFSET, 2, 0, STATUS_BAR_HEIGHT)];
        [self addSubview:self.followerText];
        width = [self.followerText getRight];
    }
    if (contents & VHStatusBarButtonContentTypeNotifications)
    {
        self.notificationImage = [[NSImageView alloc] initWithFrame:CGRectMake(width, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:self.notificationImage];
        width = [self.notificationImage getRight];
        self.notificationText = [self textFieldWithFrame:CGRectMake(width + STATUS_ICON_NOTIFICATION_TEXT_HORIZONTAL_OFFSET, 2, 0, STATUS_BAR_HEIGHT)];
        [self addSubview:self.notificationText];
        width = [self.notificationText getRight];
    }
}

- (void)updateStringsAndPositions
{
    BOOL statusBarButtonContainsEmptyContent = [[VHGithubNotifierManager sharedManager] statusBarButtonContainsEmptyContent];
    CGFloat width = 0;
    
    if ([self.starString isEqualToString:@"0"] && statusBarButtonContainsEmptyContent)
    {
        self.starImage.hidden = YES;
        self.starText.hidden = YES;
    }
    else
    {
        self.starImage.hidden = NO;
        self.starText.hidden = NO;
        [self.starImage setLeft:width];
        width = [self.starImage getRight];
        [self.starText setLeft:width + STATUS_ICON_STAR_TEXT_HORIZONTAL_OFFSET];
        [self.starText setWidth:[VHUtils widthOfString:self.starString withFont:self.starText.font] + TEXT_EXTRA_PADDING];
        [self.starText setStringValue:self.starString];
        width = [self.starText getRight];
    }
    
    if ([self.followerString isEqualToString:@"0"] && statusBarButtonContainsEmptyContent)
    {
        self.followerImage.hidden = YES;
        self.followerText.hidden = YES;
    }
    else
    {
        self.followerImage.hidden = NO;
        self.followerText.hidden = NO;
        [self.followerImage setLeft:width];
        width = [self.followerImage getRight];
        [self.followerText setLeft:width + STATUS_ICON_FOLLOWER_TEXT_HORIZONTAL_OFFSET];
        [self.followerText setWidth:[VHUtils widthOfString:self.followerString withFont:self.followerText.font] + TEXT_EXTRA_PADDING];
        [self.followerText setStringValue:self.followerString];
        width = [self.followerText getRight];
    }
    
    if ([self.notificationString isEqualToString:@"0"] && statusBarButtonContainsEmptyContent)
    {
        self.notificationImage.hidden = YES;
        self.notificationText.hidden = YES;
    }
    else
    {
        self.notificationImage.hidden = NO;
        self.notificationText.hidden = NO;
        [self.notificationImage setLeft:width];
        width = [self.notificationImage getRight];
        [self.notificationText setLeft:width + STATUS_ICON_NOTIFICATION_TEXT_HORIZONTAL_OFFSET];
        [self.notificationText setWidth:[VHUtils widthOfString:self.notificationString withFont:self.notificationText.font] + TEXT_EXTRA_PADDING];
        [self.notificationText setStringValue:self.notificationString];
        width = [self.notificationText getRight];
    }
    
    if (width == 0)
    {
        // There is not any content in status bar button.
        // Then we will use the default one.
        if (self.githubIcon == nil)
        {
            self.githubIcon = [[NSImageView alloc] initWithFrame:CGRectMake(width, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
            [self addSubview:self.githubIcon];
            width = [self.githubIcon getRight];
        }
    }
    else
    {
        self.githubIcon.hidden = YES;
    }
    
    [self setWidth:width];
}

- (void)updateColorsWithPressed:(BOOL)pressed
{
    if (pressed)
    {
        [self.githubIcon setImage:[self imageWithName:@"icon_status_bar_github_pressed" withTemplate:NO]];
        [self.starImage setImage:[self imageWithName:@"icon_star_pressed" withTemplate:NO]];
        [self.starText setTextColor:RGB(255, 255, 255)];
        [self.followerImage setImage:[self imageWithName:@"icon_follower_pressed" withTemplate:NO]];
        [self.followerText setTextColor:RGB(255, 255, 255)];
        [self.notificationImage setImage:[self imageWithName:@"icon_status_bar_notification_pressed" withTemplate:NO]];
        [self.notificationText setTextColor:RGB(255, 255, 255)];
    }
    else
    {
        if (self.isDarkMode)
        {
            [self.githubIcon setImage:[self imageWithName:@"icon_status_bar_github_dark" withTemplate:NO]];
            [self.starImage setImage:[self imageWithName:@"icon_star_dark" withTemplate:YES]];
            [self.starText setTextColor:RGB(255, 255, 255)];
            [self.followerImage setImage:[self imageWithName:@"icon_follower_dark" withTemplate:YES]];
            [self.followerText setTextColor:RGB(255, 255, 255)];
            [self.notificationImage setImage:[self imageWithName:@"icon_status_bar_notification_dark" withTemplate:NO]];
            [self.notificationText setTextColor:RGB(255, 255, 255)];
        }
        else
        {
            [self.githubIcon setImage:[self imageWithName:@"icon_status_bar_github" withTemplate:NO]];
            [self.starImage setImage:[self imageWithName:@"icon_star" withTemplate:YES]];
            [self.starText setTextColor:RGB(0, 0, 0)];
            [self.followerImage setImage:[self imageWithName:@"icon_follower" withTemplate:YES]];
            [self.followerText setTextColor:RGB(0, 0, 0)];
            [self.notificationImage setImage:[self imageWithName:@"icon_status_bar_notification" withTemplate:NO]];
            [self.notificationText setTextColor:RGB(0, 0, 0)];
        }
    }
}

- (void)updateValues
{
    self.starString = [NSString stringWithFormat:@"%lu", [[[VHGithubNotifierManager sharedManager] user] starNumber]];
    self.followerString = [NSString stringWithFormat:@"%lld", [[[VHGithubNotifierManager sharedManager] user] followerNumber]];
    self.notificationString = [NSString stringWithFormat:@"%zd", [[VHGithubNotifierManager sharedManager] notificationNumber]];
    [self updateStringsAndPositions];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyRepositoriesLoadedSuccessfully:) name:kNotifyRepositoriesLoadedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyNotificationsChanged:) name:kNotifyNotificationsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyNotificationsChanged:) name:kNotifyNotificationsLoadedSuccessfully object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyWindowDidMove:) name:NSWindowDidMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyStatusBarButtonContentChanged:) name:kNotifyStatusBarButtonContentChanged object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNotifyRepositoriesLoadedSuccessfully:(NSNotification *)notification
{
    [self updateValues];
}

- (void)onNotifyNotificationsChanged:(NSNotification *)notification
{
    [self updateValues];
}

- (void)darkModeChanged:(NSNotification *)notification
{
    self.isDarkMode = [VHUtils isDarkMode];
    [self updateColorsWithPressed:NO];
}

- (void)onNotifyWindowDidMove:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[VHUserNotificationWindow class]])
    {
        return;
    }
    if (self.statusBarButtonDelegate != nil && [self.statusBarButtonDelegate respondsToSelector:@selector(onStatusBarButtonMoved)] && self.isFirstMove == NO)
    {
        [self.statusBarButtonDelegate onStatusBarButtonMoved];
    }
    self.isFirstMove = NO;
}

- (void)onNotifyStatusBarButtonContentChanged:(NSNotification *)notification
{
    
}

#pragma mark - Touches

- (void)mouseDown:(NSEvent *)event
{
    [self toPress];
}

- (void)mouseUp:(NSEvent *)event
{
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSRect statusBarButtonRect = [[self window] convertRectToScreen:self.frame];
    [self toNormal:[VHUtils point:mouseLocation notOutOfRect:statusBarButtonRect] == NO];
}

- (void)mouseExited:(NSEvent *)event
{
    [self toNormal:YES];
}

- (void)toNormal:(BOOL)isCanceled
{
    if (self.isPressed && isCanceled == NO)
    {
        if (self.statusBarButtonDelegate != nil && [self.statusBarButtonDelegate respondsToSelector:@selector(onStatusBarButtonClicked)])
        {
            [self.statusBarButtonDelegate onStatusBarButtonClicked];
        }
    }
    self.isPressed = NO;
    [self setBackgroundColor:[NSColor clearColor]];
    [self updateColorsWithPressed:NO];
}

- (void)toPress
{
    self.isPressed = YES;
    [self setBackgroundColor:STATUS_ITEM_PRESSED_LIGHT];
    [self updateColorsWithPressed:YES];
}

- (void)updateTrackingAreas
{
    if(self.trackingArea != nil)
    {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

#pragma mark - Support Methods

- (NSImage *)imageWithName:(NSString *)name withTemplate:(BOOL)template
{
    NSImage *image = [NSImage imageNamed:name];
    image.template = template;
    return image;
}

- (NSTextField *)textFieldWithFrame:(CGRect)frame
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setSelectable:NO];
    [textField setBordered:NO];
    [textField setBackgroundColor:[NSColor clearColor]];
    [textField setAlignment:NSTextAlignmentLeft];
    [textField setFont:[NSFont systemFontOfSize:14]];
    return textField;
}

@end
