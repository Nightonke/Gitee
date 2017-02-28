//
//  VHAccountInfoWC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHAccountInfoWC.h"
#import "NSView+Position.h"
#import "VHTextFieldCell.h"
#import <SYFlatButton.h>
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHTextField.h"
#import "VHGithubNotifierManager.h"

@interface VHAccountInfoWC ()<NSTextFieldDelegate, VHTextFieldDelegate>

@property (weak) IBOutlet VHTextField *userNameTextField;
@property (weak) IBOutlet VHTextField *userPasswordTextField;
@property (weak) IBOutlet SYFlatButton *startButton;
@property (weak) IBOutlet NSProgressIndicator *confirmProgress;

@end

@implementation VHAccountInfoWC

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window.contentView setWantsLayer:YES];
    self.window.contentView.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.window.contentView.layer.contents = [NSImage imageNamed:@"background_account_info_window"];
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    self.window.toolbar.showsBaselineSeparator = NO;
    [self.window setMovableByWindowBackground:YES];
    
    self.userNameTextField.wantsLayer = YES;
    self.userNameTextField.shadow = [self shadowForViews];
    self.userNameTextField.maximumNumberOfLines = 1;
    self.userNameTextField.editable = YES;
    self.userNameTextField.delegate = self;
    
    self.userPasswordTextField.wantsLayer = YES;
    self.userPasswordTextField.shadow = [self shadowForViews];
    self.userPasswordTextField.maximumNumberOfLines = 1;
    self.userPasswordTextField.editable = YES;
    self.userPasswordTextField.delegate = self;
    self.userPasswordTextField.textFieldDelegate = self;
    
    self.startButton.wantsLayer = YES;
    self.startButton.shadow = [self shadowForViews];
    self.startButton.enabled = NO;
    
    [self.confirmProgress startAnimation:nil];
    self.confirmProgress.hidden = YES;
    
    [self addNotifications];
}

#pragma mark - Notifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyUserAccountConfirmSuccessfully:)
                                                 name:kNotifyUserAccountConfirmSuccessfully
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyUserAccountConfirmInternetFailed:)
                                                 name:kNotifyUserAccountConfirmInternetFailed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyUserAccountConfirmIncorrectUsernameOrPassword:)
                                                 name:kNotifyUserAccountConfirmIncorrectUsernameOrPassword
                                               object:nil];
}

- (void)onNotifyUserAccountConfirmSuccessfully:(NSNotification *)notification
{
    self.startButton.title = @"Succeed!";
    self.confirmProgress.hidden = YES;
    if (self.accountInfoDelegate && [self.accountInfoDelegate respondsToSelector:@selector(onUserAccountConfirmed)])
    {
        [self.accountInfoDelegate onUserAccountConfirmed];
        [self close];
    }
}

- (void)onNotifyUserAccountConfirmInternetFailed:(NSNotification *)notification
{
    self.startButton.title = @"Internet failed!";
    self.confirmProgress.hidden = YES;
    DELAY_EXECUTE_IN_MAIN(1, self.startButton.title = @"Start!";);
}

- (void)onNotifyUserAccountConfirmIncorrectUsernameOrPassword:(NSNotification *)notification
{
    self.startButton.title = @"Incorrect username or password!";
    self.confirmProgress.hidden = YES;
    DELAY_EXECUTE_IN_MAIN(1, self.startButton.title = @"Start!";);
}

#pragma mark - Private Methods

- (void)adjustPositionOfWindowButton:(NSButton *)button
{
    [button removeFromSuperview];
    [self.window.contentView addSubview:button];
    [button setTop:self.window.contentView.height - button.height - 20];
}

- (NSShadow *)shadowForViews
{
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor grayColor]];
    [shadow setShadowOffset:NSMakeSize(0, 0)];
    [shadow setShadowBlurRadius:10];
    return shadow;
}

#pragma mark - Action

- (void)onTextFieldEnterButtonClicked:(VHTextField *)textField
{
    NSString *username = [self.userNameTextField stringValue];
    NSString *password = [self.userPasswordTextField stringValue];
    self.startButton.enabled = [username length] && [password length];
    if (self.startButton.enabled)
    {
        [self.startButton setButtonType:NSButtonTypeMomentaryChange];
        [self.startButton performClick:nil];
    }
    else if (username.length > 0)
    {
        [self.userPasswordTextField becomeFirstResponder];
        [[self.userPasswordTextField currentEditor] moveToEndOfLine:nil];
    }
}

- (IBAction)onStartButtonClicked:(SYFlatButton *)sender
{
    if ([self.startButton.title isEqualToString:@"Start!"])
    {
        [self confirmUserAccount];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSString *username = [self.userNameTextField stringValue];
    NSString *password = [self.userPasswordTextField stringValue];
    self.startButton.enabled = [username length] && [password length];
    if (self.startButton.enabled)
    {
        [self.startButton setButtonType:NSButtonTypeMomentaryChange];
    }
}

#pragma mark - Private Methods

- (void)confirmUserAccount
{
    self.startButton.title = @"";
    self.confirmProgress.hidden = NO;
    [[VHGithubNotifierManager sharedManager] confirmUserAccount:[self.userNameTextField stringValue]
                                                   withPassword:[self.userPasswordTextField stringValue]];
}

- (void)showWindow:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
    [super showWindow:sender];
}

- (void)windowWillClose
{
    if (self.accountInfoDelegate && [self.accountInfoDelegate respondsToSelector:@selector(onAccountInfoWindowClosed)])
    {
        [self.accountInfoDelegate onAccountInfoWindowClosed];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
