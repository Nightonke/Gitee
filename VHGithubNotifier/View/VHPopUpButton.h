//
//  VHPopUpButton.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface VHPopUpButton : NSPopUpButton

@property (nonatomic, assign) CGFloat menuWindowXOffset;
@property (nonatomic, assign) CGFloat menuWindowYOffset;
@property (nonatomic, assign) CGFloat menuWindowWidth;
@property (nonatomic, assign) CGFloat menuWindowHeight;

@property (nonatomic, strong) NSCursor *cursor;

- (void)setMenuWindowRelativeFrame:(NSRect)frame;

@end
