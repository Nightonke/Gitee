//
//  VHTabView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

@protocol VHTabViewDelegate <NSObject>

@required
- (void)didSelectGithubContentType:(VHGithubContentType)type;

@end

@interface VHTabView : NSView

@property (nonatomic, weak) id<VHTabViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger selectedTab;

@end
