//
//  VHStateView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHStateView.h"
#import "NSView+Position.h"

@interface VHStateView ()

@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSButton *retryButton;
@property (weak) IBOutlet NSImageView *retryImage;
@property (weak) IBOutlet NSTextField *retryLabel;


@end

@implementation VHStateView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        NSString *className = NSStringFromClass([self class]);
        if ([[NSBundle mainBundle] loadNibNamed:className
                                          owner:self
                                topLevelObjects:nil])
        {
            [self.view setFrame:[self bounds]];
            [self addSubview:self.view];
            
            [_progress startAnimation:nil];
            
            _retryImage.image = [NSImage imageNamed:@"icon_error"];
            _retryImage.imageScaling = NSImageScaleAxesIndependently;
            
            _retryLabel.alignment = NSTextAlignmentCenter;
            
            [self setState:VHStateViewStateTypeLoading];
        }
        return self;
    }
    return nil;
}

- (IBAction)onRetryButtonClicked:(id)sender
{
    [self setState:VHStateViewStateTypeLoading];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onRetryButtonClicked)])
    {
        [self.delegate onRetryButtonClicked];
    }
}

- (void)setState:(VHStateViewStateType)state
{
    _state = state;
    switch (state)
    {
        case VHStateViewStateTypeLoading:
            self.progress.hidden = NO;
            self.retryImage.hidden = YES;
            self.retryLabel.hidden = YES;
            self.retryButton.hidden = YES;
            self.hidden = NO;
            break;
        case VHStateViewStateTypeLoadFailed:
            self.progress.hidden = YES;
            self.retryImage.hidden = NO;
            self.retryLabel.hidden = NO;
            self.retryButton.hidden = NO;
            self.hidden = NO;
            break;
        case VHStateViewStateTypeLoadSuccessfully:
            self.progress.hidden = YES;
            self.retryImage.hidden = YES;
            self.retryLabel.hidden = YES;
            self.retryButton.hidden = YES;
            self.hidden = YES;
            break;
    }
}

- (void)setRetryText:(NSString *)retryText
{
    [self.retryLabel setStringValue:retryText];
}

@end
