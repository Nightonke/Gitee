//
//  VHScrollerThumb.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VHDragDirectionType)
{
    VHDragDirectionTypeNeither    = 0,
    VHDragDirectionTypeHorizontal = 1,
    VHDragDirectionTypeVertical   = 2,
    VHDragDirectionTypeBoth       = 3,
};

@protocol VHScrollerThumbDelegate <NSObject>

@required
- (void)onThumbScrolled:(CGFloat)progress;

@end

@interface VHScrollerThumb : NSImageView

@property (nonatomic, assign) VHDragDirectionType dragDirection;
@property (nonatomic, weak) id<VHScrollerThumbDelegate> delegate;

- (instancetype)initWithFrame:(NSRect)frameRect withImageName:(NSString *)imageName;

@end
