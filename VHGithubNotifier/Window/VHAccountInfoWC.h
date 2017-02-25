//
//  VHAccountInfoWC.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@protocol VHAccountInfoWCDelegate <NSObject>

@required
- (void)onAccountInfoWindowClosed;
- (void)onUserAccountConfirmed;

@end

@interface VHAccountInfoWC : NSWindowController

@property (nonatomic, weak) id<VHAccountInfoWCDelegate> accountInfoDelegate;

@end
