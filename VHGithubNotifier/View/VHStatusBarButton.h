//
//  VHStatusBarButton.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

@protocol VHStatusBarButtonProtocol <NSObject>

@required
- (void)onStatusBarButtonClicked;
- (void)onStatusBarButtonMoved;

@end

@interface VHStatusBarButton : NSTextField

@property (nonatomic, weak) id<VHStatusBarButtonProtocol> statusBarButtonDelegate;

@end
