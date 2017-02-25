//
//  VHStateView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VHStateViewStateType)
{
    VHStateViewStateTypeLoading          = 1,
    VHStateViewStateTypeLoadFailed       = 2,
    VHStateViewStateTypeLoadSuccessfully = 3,
};

@protocol VHStateViewDelegate <NSObject>

@required
- (void)onRetryButtonClicked;

@end

@interface VHStateView : NSView

@property (nonatomic, strong) IBOutlet NSView *view;

@property (nonatomic, assign) VHStateViewStateType state;

@property (nonatomic, weak) id<VHStateViewDelegate> delegate;

- (void)setRetryText:(NSString *)retryText;

@end
