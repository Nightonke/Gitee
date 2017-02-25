//
//  VHWindow.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/27.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHStatusBarButton.h"

@protocol VHWindowProtocol <NSObject>

@required
- (void)onMouseClickedOutside;

@end

@interface VHWindow : NSWindow

@property (nonatomic, weak) id<VHWindowProtocol> windowDelegate;

- (instancetype)initWithStatusItem:(NSStatusItem *)statusBarButton withDelegate:(id<VHWindowProtocol>)delegate;

- (void)updateArrowWithStatusItemCenterX:(CGFloat)centerX withStatusItemFrame:(CGRect)statusItemFrame;

@end
