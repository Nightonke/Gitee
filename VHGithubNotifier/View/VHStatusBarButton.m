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

const static CGFloat STATUS_ICON_WIDTH = 22;
const static CGFloat STATUS_BAR_HEIGHT = 22;
const static CGFloat STATUS_ICON_STAR_TEXT_HORIZONTAL_OFFSET = -3;
const static CGFloat STATUS_ICON_FOLLOWER_TEXT_HORIZONTAL_OFFSET = -1;
const static CGFloat TEXT_EXTRA_PADDING = 5;

@interface VHStatusBarButton ()

@property (nonatomic, strong) NSImageView *starImage;
@property (nonatomic, strong) NSTextField *starText;
@property (nonatomic, strong) NSImageView *followerImage;
@property (nonatomic, strong) NSTextField *followerText;

@property (nonatomic, copy) NSString *starString;
@property (nonatomic, copy) NSString *followerString;
@property (nonatomic, assign) BOOL isDarkMode;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) BOOL isFirstMove;

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
        _starString = @"...";
        _followerString = @"...";
        _isDarkMode = [VHUtils isDarkMode];
        _isPressed = NO;
        _isFirstMove = YES;
        [self setBordered:NO];
        [self setSelectable:NO];
        
        _starImage = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:_starImage];
        
        _starText = [self textFieldWithFrame:CGRectMake([_starImage getRight] + STATUS_ICON_STAR_TEXT_HORIZONTAL_OFFSET, 2, 0, STATUS_BAR_HEIGHT)];
        [self addSubview:_starText];
        
        _followerImage = [[NSImageView alloc] initWithFrame:CGRectMake([self.starText getRight], 0, STATUS_ICON_WIDTH, STATUS_BAR_HEIGHT)];
        [self addSubview:_followerImage];
        
        _followerText = [self textFieldWithFrame:CGRectMake([self.followerImage getRight] + STATUS_ICON_FOLLOWER_TEXT_HORIZONTAL_OFFSET, 2, 0, STATUS_BAR_HEIGHT)];
        [self addSubview:_followerText];
        
        [_starText setStringValue:_starString];
        
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

- (void)updateStringsAndPositions
{
    [self.starText setWidth:[VHUtils widthOfString:self.starString withFont:self.starText.font] + TEXT_EXTRA_PADDING];
    [self.starText setStringValue:self.starString];
    [self.followerImage setLeft:[self.starText getRight]];
    [self.followerText setLeft:[self.followerImage getRight]];
    [self.followerText setStringValue:self.followerString];
    [self.followerText setWidth:[VHUtils widthOfString:self.followerString withFont:self.followerText.font] + TEXT_EXTRA_PADDING];
    [self setWidth:[self.followerText getRight]];
}

- (void)updateColorsWithPressed:(BOOL)pressed
{
    if (pressed)
    {
        [self.starImage setImage:[self imageWithName:@"icon_star_pressed" withTemplate:NO]];
        [self.starText setTextColor:RGB(255, 255, 255)];
        [self.followerImage setImage:[self imageWithName:@"icon_follower_pressed" withTemplate:NO]];
        [self.followerText setTextColor:RGB(255, 255, 255)];
    }
    else
    {
        if (self.isDarkMode)
        {
            [self.starImage setImage:[self imageWithName:@"icon_star_dark" withTemplate:YES]];
            [self.starText setTextColor:RGB(255, 255, 255)];
            [self.followerImage setImage:[self imageWithName:@"icon_follower_dark" withTemplate:YES]];
            [self.followerText setTextColor:RGB(255, 255, 255)];
        }
        else
        {
            [self.starImage setImage:[self imageWithName:@"icon_star" withTemplate:YES]];
            [self.starText setTextColor:RGB(0, 0, 0)];
            [self.followerImage setImage:[self imageWithName:@"icon_follower" withTemplate:YES]];
            [self.followerText setTextColor:RGB(0, 0, 0)];
        }
    }
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyRepositoriesLoadedSuccessfully:) name:kNotifyRepositoriesLoadedSuccessfully object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyWindowDidMove) name:NSWindowDidMoveNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNotifyRepositoriesLoadedSuccessfully:(NSNotification *)notification
{
    self.starString = [NSString stringWithFormat:@"%lu", [[[VHGithubNotifierManager sharedManager] user] starNumber]];
    self.followerString = [NSString stringWithFormat:@"%lld", [[[VHGithubNotifierManager sharedManager] user] followerNumber]];
    [self updateStringsAndPositions];
}

- (void)onNotifyWindowDidMove
{
    if (self.statusBarButtonDelegate != nil && [self.statusBarButtonDelegate respondsToSelector:@selector(onStatusBarButtonMoved)] && self.isFirstMove == NO)
    {
        [self.statusBarButtonDelegate onStatusBarButtonMoved];
    }
    self.isFirstMove = NO;
}

-(void)darkModeChanged:(NSNotification *)notif
{
    self.isDarkMode = [VHUtils isDarkMode];
    [self updateColorsWithPressed:NO];
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
    [self toNormal:[VHUtils CGPoint:mouseLocation notOutOfRect:statusBarButtonRect] == NO];
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
