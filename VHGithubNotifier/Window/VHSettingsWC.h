//
//  VHSettingsWC.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/6.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@protocol VHSettingsWCDelegate <NSObject>

@required
- (void)onSettingsWindowClosed;

@end

@interface VHSettingsWC : NSWindowController

@property (nonatomic, weak) id<VHSettingsWCDelegate> settingsWCDelegate;

@end
