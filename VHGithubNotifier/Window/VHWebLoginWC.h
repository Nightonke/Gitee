//
//  VHWebLoginWC.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@protocol VHWebLoginWCDelegate <NSObject>

@required
- (void)onWebLoginWindowClosed;

@end

@interface VHWebLoginWC : NSWindowController

@property (nonatomic, weak) id<VHWebLoginWCDelegate> webLoginDelegate;

@end
