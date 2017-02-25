//
//  VHTabVCBackgroundView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/26.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

@interface VHTabVCBackgroundView : NSControl

@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)updateArrowWithStatusItemCenterX:(CGFloat)centerX;

- (NSRect)tabViewFrame;

- (NSRect)contentViewFrame;

@end
