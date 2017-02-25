//
//  VHScroller.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface VHScroller : NSView

- (instancetype)initWithFrame:(NSRect)frameRect
               withImageFrame:(NSRect)imageFrame
                withImageName:(NSString *)imageName
               withScrollView:(NSScrollView *)scrollView;

@end
