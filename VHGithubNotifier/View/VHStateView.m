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
@property (weak) IBOutlet NSButton *button;
@property (weak) IBOutlet NSImageView *image;
@property (weak) IBOutlet NSTextField *label;

@property (nonatomic, strong) NSString *retryText;
@property (nonatomic, strong) NSString *emptyImage;
@property (nonatomic, strong) NSString *emptyText;
@property (nonatomic, strong) NSString *loadingText;

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
            
            _image.imageScaling = NSImageScaleAxesIndependently;
            _label.alignment = NSTextAlignmentCenter;
            
            _retryText = @"";
            _emptyImage = @"icon_error";
            _emptyText = @"";
            _loadingText = @"Loading...";
            
            [self setState:VHStateViewStateTypeLoading];
        }
        return self;
    }
    return nil;
}

- (IBAction)onButtonClicked:(id)sender
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
            self.image.hidden = YES;
            self.label.hidden = NO;
            self.label.stringValue = self.loadingText;
            self.button.hidden = YES;
            self.hidden = NO;
            break;
        case VHStateViewStateTypeLoadFailed:
            self.progress.hidden = YES;
            self.image.hidden = NO;
            self.image.image = [NSImage imageNamed:@"icon_error"];
            self.label.hidden = NO;
            self.label.stringValue = self.retryText;
            self.button.hidden = NO;
            self.hidden = NO;
            break;
        case VHStateViewStateTypeLoadSuccessfully:
            self.progress.hidden = YES;
            self.image.hidden = YES;
            self.label.hidden = YES;
            self.button.hidden = YES;
            self.hidden = YES;
            break;
        case VHStateViewStateTypeEmpty:
            self.progress.hidden = YES;
            self.image.hidden = NO;
            self.image.image = [NSImage imageNamed:self.emptyImage];
            self.label.hidden = NO;
            self.label.stringValue = self.emptyText;
            self.button.hidden = YES;
            self.hidden = NO;
            break;
    }
}

- (void)setRetryText:(NSString *)retryText
{
    if (retryText)
    {
        _retryText = retryText;
        [self.label setStringValue:retryText];
    }
    else
    {
        NSAssert(NO, @"Retry text is null!");
    }
}

- (void)setEmptyText:(NSString *)emptyText
{
    if (emptyText)
    {
        _emptyText = emptyText;
        [self.label setStringValue:emptyText];
    }
    else
    {
        NSAssert(NO, @"Empty text is null!");
    }
}

- (void)setLoadingText:(NSString *)loadingText
{
    if (loadingText)
    {
        _loadingText = loadingText;
        [self.label setStringValue:loadingText];
    }
    else
    {
        NSAssert(NO, @"Loading text is null!");
    }
}

- (void)setEmptyImage:(NSString *)emptyImage
{
    _emptyImage = emptyImage;
    [self setState:self.state];
}

@end
