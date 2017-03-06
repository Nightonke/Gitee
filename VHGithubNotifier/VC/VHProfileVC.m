//
//  VHProfileVC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/29.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHProfileVC.h"
#import "VHSettingsWC.h"
#import "VHCursorButton.h"

@interface VHProfileVC ()

@property (weak) IBOutlet VHCursorButton *settingsButton;
@property (weak) IBOutlet VHCursorButton *exitButton;

@property (nonatomic, strong) VHSettingsWC *settingsWC;

@end

@implementation VHProfileVC

#pragma mark - Life

- (void)loadView
{
    [super loadView];
    
    self.settingsButton.image.template = YES;
    self.settingsButton.toolTip = @"Settings";
    self.exitButton.image.template = YES;
    self.exitButton.toolTip = @"Quit Gitee";
}

#pragma mark - Actions

- (IBAction)onSettingsButtonClicked:(id)sender
{
    NOTIFICATION_POST(kNotifyWindowShouldHide);
    if (self.settingsWC == nil)
    {
        self.settingsWC = [[VHSettingsWC alloc] initWithWindowNibName:@"VHSettingsWC"];
    }
    [self.settingsWC showWindow:self];
}

- (IBAction)onExitButtonClicked:(id)sender
{
    SystemLog(@"Terminate in profile vc");
    [NSApp terminate:nil];
}


@end
