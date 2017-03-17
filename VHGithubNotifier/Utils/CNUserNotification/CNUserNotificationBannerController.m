//
//  CNUserNotificationBannerController.m
//
//  Created by Frank Gregor on 16.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2013 Frank Gregor, <phranck@cocoanaut.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>
#import "CNUserNotificationBannerController.h"
#import "CNUserNotificationBannerBackgroundView.h"
#import "CNUserNotificationBannerButton.h"
#import "VHUserNotificationWindow.h"

static NSTimeInterval slideInAnimationDuration = 0.7;
static NSTimeInterval slideOutAnimationDuration = 1;
static NSDictionary *titleAttributes, *subtitleAttributes, *informativeTextAttributes;
static NSRect presentationBeginRect, presentationRect, presentationEndRect;
static CGFloat bannerTopMargin = 20;
static CGFloat bannerTrailingMargin = 20;
static CGFloat bannerContentPadding = 8;
static CGFloat bannerContentLabelPadding = 1;


CGFloat CNGetMaxCGFloat(CGFloat left, CGFloat right) {
    return (left > right ? left : right);
}

@interface CNUserNotificationBannerController () {
    NSDictionary *_userInfo;
    CNUserNotification *_userNotification;
    CNUserNotificationBannerActivationHandler _bannerActivationHandler;
    CGFloat _labelWidth;
    NSLineBreakMode _informativeTextLineBreakMode;
    CGFloat _calculatedButtonWidth;
    BOOL _hasActionButton;
    CGSize _bannerSize;
    CGSize _bannerImageSize;
    CGSize _buttonSize;
}
@property (strong, nonatomic) NSTextField *title;
@property (strong, nonatomic) NSTextField *subtitle;
@property (strong, nonatomic) NSTextField *informativeText;
@property (strong, nonatomic) NSImageView *bannerImageView;
@property (strong) CNUserNotificationBannerButton *actionButton;
@property (strong) CNUserNotificationBannerButton *otherButton;
@property (assign) BOOL animationIsRunning;
@property (strong) NSTimer *dismissTimer;
@end

@implementation CNUserNotificationBannerController

#pragma mark - Initialization

- (instancetype)initWithNotification:(CNUserNotification *)theNotification
                            delegate:(id <CNUserNotificationCenterDelegate> )theDelegate
              usingActivationHandler:(CNUserNotificationBannerActivationHandler)activationHandler {
    self = [super init];
    if (self) {
        _bannerSize = NSMakeSize(344, 63);
        _bannerImageSize = NSMakeSize(36.0, 36.0);
        _buttonSize = NSMakeSize(80.0, 32.0);
        
        _bannerActivationHandler = [activationHandler copy];
        _animationIsRunning = NO;
        _userInfo = theNotification.userInfo;
        _delegate = theDelegate;
        _userNotification = theNotification;
        _informativeTextLineBreakMode = _userNotification.feature.lineBreakMode;
        
        _actionButton = nil;
        _otherButton = nil;
        _hasActionButton = NO;
        
        [self adjustTextFieldAttributes];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismissBanner)
                                                     name:CNUserNotificationDismissBannerNotification
                                                   object:nil];
    }
    return self;
}

- (void)cleanSelf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
}

- (void)dealloc
{
    
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
}

#pragma mark - API

- (void)presentBanner {
    if (self.animationIsRunning) return;
    self.animationIsRunning = YES;
    
    [self prepareNotificationBanner];
    //	[NSApp activateIgnoringOtherApps:YES];
    
    NSWindow *window = [self window];
    [window setFrame:presentationBeginRect display:NO];
    [window setLevel:kCGMaximumWindowLevel];
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
        context.duration = slideInAnimationDuration;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [[window animator] setAlphaValue:1.0];
        [[window animator] setFrame:presentationRect display:YES];
        
    } completionHandler: ^{
        self.animationIsRunning = NO;
        [window orderFront:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CNUserNotificationHasBeenPresentedNotification object:nil];
    }];
}

- (void)presentBannerDismissAfter:(NSTimeInterval)dismissTimerInterval {
    [self presentBanner];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:dismissTimerInterval
                                                         target:self
                                                       selector:@selector(timedBannerDismiss:)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)dismissBanner {
    if (self.animationIsRunning) return;
    
    self.animationIsRunning = YES;
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
        context.duration = slideOutAnimationDuration;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [[[self window] animator] setAlphaValue:0.0];
        [[[self window] animator] setFrame:presentationEndRect display:YES];
    } completionHandler: ^{
        self.animationIsRunning = NO;
        [self cleanSelf];
        [[self window] close];
    }];
}

#pragma mark - Actions

- (void)actionButtonAction {
    _bannerActivationHandler(CNUserNotificationActivationTypeActionButtonClicked);
}

- (void)otherButtonAction {
    [self dismissBanner];
}

#pragma mark - Private Helper

- (void)adjustTextFieldAttributes {
    NSShadow *textShadow = [[NSShadow alloc] init];
    [textShadow setShadowColor:[[NSColor whiteColor] colorWithAlphaComponent:0.5]];
    [textShadow setShadowOffset:NSMakeSize(0, -1)];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment:NSLeftTextAlignment];
    [textStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [textStyle setTighteningFactorForTruncation:0];
    
    titleAttributes = @{
                        NSShadowAttributeName:          textShadow,
                        NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.280 alpha:1.000],
                        NSFontAttributeName:            [NSFont fontWithName:@"LucidaGrande-Bold" size:12],
                        NSParagraphStyleAttributeName:  textStyle
                        };
    
    subtitleAttributes = @{
                           NSShadowAttributeName:          textShadow,
                           NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.280 alpha:1.000],
                           NSFontAttributeName:            [NSFont fontWithName:@"LucidaGrande" size:11],
                           NSParagraphStyleAttributeName:  textStyle
                           };
    
    [textStyle setLineBreakMode:_informativeTextLineBreakMode];
    NSMutableParagraphStyle *informativeParagraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [informativeParagraphStyle setAlignment:NSTextAlignmentRight];
    [informativeParagraphStyle setTighteningFactorForTruncation:0];
    informativeTextAttributes = @{
                                  NSShadowAttributeName:          textShadow,
                                  NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.500 alpha:1.000],
                                  NSFontAttributeName:            [NSFont fontWithName:@"LucidaGrande" size:11],
                                  NSParagraphStyleAttributeName:  informativeParagraphStyle
                                  };
}

- (void)timedBannerDismiss:(NSTimer *)theTimer {
    [self dismissBanner];
}

- (void)calculateBannerPositions {
    NSRect mainScreenFrame = [[NSScreen screens][0] frame];
    CGFloat statusBarThickness = [[NSStatusBar systemStatusBar] thickness];
    CGFloat calculatedBannerHeight = bannerContentPadding + self.title.intrinsicContentSize.height * 2 + [self informativeTextHeightForWidth:(_labelWidth)] + bannerContentLabelPadding * 2 + bannerContentPadding;
    CGFloat delta = _bannerSize.height - calculatedBannerHeight;
    CGFloat bannerheight = (delta < 0 ? _bannerSize.height :  _bannerSize.height + delta * -1 );
    
    // window position before slide in animation
    presentationBeginRect = NSMakeRect(NSMaxX(mainScreenFrame) + 20,
                                       NSMaxY(mainScreenFrame) - statusBarThickness - bannerheight - bannerTopMargin,
                                       _bannerSize.width,
                                       bannerheight);
    
    // window position after slide in animation
    presentationRect = NSMakeRect(NSMaxX(mainScreenFrame) - _bannerSize.width - bannerTrailingMargin,
                                  NSMaxY(mainScreenFrame) - statusBarThickness - bannerheight - bannerTopMargin,
                                  _bannerSize.width,
                                  bannerheight);
    
    // window position after slide out animation
    presentationEndRect = NSMakeRect(NSMaxX(mainScreenFrame) + 20,
                                     NSMaxY(mainScreenFrame) - statusBarThickness - bannerheight - bannerTopMargin,
                                     _bannerSize.width,
                                     bannerheight);
}

- (void)prepareNotificationBanner {
    [self configureNotificationBannerWindow];
    [self configureNotificationBannerImage];
    [self configureNotificationBannerTexts];
    [self configureNotificationBannerButtons];
    [self configureNotificationBannerConstraints];
    [self calculateBannerPositions];
    [self showWindow:nil];
}

- (NSTextField *)labelWithidentifier:(NSString *)theIdentifier attributedTextValue:(NSAttributedString *)theTextValue superView:(NSView *)theSuperView {
    NSTextField *aTextField = [NSTextField new];
    aTextField.translatesAutoresizingMaskIntoConstraints = NO;
    aTextField.attributedStringValue = theTextValue;
    aTextField.identifier = theIdentifier;
    aTextField.drawsBackground = NO;
    [aTextField setSelectable:NO];
    [aTextField setEditable:NO];
    [aTextField setBordered:NO];
    [aTextField setAlignment:NSLeftTextAlignment];
    [theSuperView addSubview:aTextField];
    
    return aTextField;
}

#pragma mark - Banner Window Configurations

- (void)configureNotificationBannerWindow {
    if (![self window]) {
        [self setWindow:[[VHUserNotificationWindow alloc] initWithContentRect:NSZeroRect
                                                                    styleMask:NSBorderlessWindowMask
                                                                      backing:NSBackingStoreBuffered
                                                                        defer:NO
                                                                       screen:[NSScreen screens][0]]];
    }
    
    [[self window] setHasShadow:YES];
    [[self window] setDisplaysWhenScreenProfileChanges:YES];
    [[self window] setReleasedWhenClosed:NO];
    [[self window] setAlphaValue:0.0];
    [[self window] setOpaque:NO];
    [[self window] setLevel:NSStatusWindowLevel];
    [[self window] setBackgroundColor:[NSColor clearColor]];
    [[self window] setCollectionBehavior:(NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary)];
    [[self window] setDelegate:self.windowDelegate];
    
    /// now we build the banner content
    CNUserNotificationBannerBackgroundView *contentView = [CNUserNotificationBannerBackgroundView new];
    [[self window] setContentView:contentView];
}

- (void)configureNotificationBannerImage {
    self.bannerImageView = [NSImageView new];
    self.bannerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bannerImageView.image = _userNotification.feature.bannerImage;
    [[[self window] contentView] addSubview:self.bannerImageView];
}

- (void)configureNotificationBannerTexts {
    self.title = [self labelWithidentifier:@"titleLabel"
                       attributedTextValue:[[NSAttributedString alloc] initWithString:AVOID_NIL_STRING(_userNotification.title) attributes:titleAttributes]
                                 superView:[[self window] contentView]];
    
    self.subtitle = [self labelWithidentifier:@"subtitleLabel"
                          attributedTextValue:[[NSAttributedString alloc] initWithString:AVOID_NIL_STRING(_userNotification.subtitle) attributes:subtitleAttributes]
                                    superView:[[self window] contentView]];
    
    self.informativeText = [self labelWithidentifier:@"informativeTextLabel"
                                 attributedTextValue:[[NSAttributedString alloc] initWithString:AVOID_NIL_STRING(_userNotification.informativeText) attributes:informativeTextAttributes]
                                           superView:[[self window] contentView]];
    switch (_informativeTextLineBreakMode) {
        case NSLineBreakByClipping:
        case NSLineBreakByTruncatingHead:
        case NSLineBreakByTruncatingTail:
        case NSLineBreakByTruncatingMiddle:
            [self.informativeText.cell setUsesSingleLineMode:YES];
            break;
            
        default:
            [self.informativeText.cell setUsesSingleLineMode:NO];
            break;
    }
}

- (void)configureNotificationBannerButtons {
    if (_userNotification.hasActionButton) {
        self.otherButton = [CNUserNotificationBannerButton new];
        self.otherButton.target = self;
        self.otherButton.action = @selector(otherButtonAction);
        if (!_userNotification.otherButtonTitle) {
            self.otherButton.title = NSLocalizedString(@"Close", @"CNUserNotificationBannerController: Other-Button title");
        }
        else {
            self.otherButton.title = (![_userNotification.otherButtonTitle isEqualToString:@""] ? _userNotification.otherButtonTitle : NSLocalizedString(@"Close", @"CNUserNotificationBannerController: Other-Button title"));
        }
        [[[self window] contentView] addSubview:self.otherButton];
        
        self.actionButton = [CNUserNotificationBannerButton new];
        self.actionButton.target = self;
        self.actionButton.action = @selector(actionButtonAction);
        if (!_userNotification.actionButtonTitle) {
            self.actionButton.title = NSLocalizedString(@"Show", @"CNUserNotificationBannerController: Activation-Button title");
        }
        else {
            self.actionButton.title = (![_userNotification.actionButtonTitle isEqualToString:@""] ? _userNotification.actionButtonTitle : NSLocalizedString(@"Show", @"CNUserNotificationBannerController: Activation-Button title"));
        }
        [[[self window] contentView] addSubview:self.actionButton];
        
        _calculatedButtonWidth = CNGetMaxCGFloat(self.otherButton.intrinsicContentSize.width, self.actionButton.intrinsicContentSize.width);
    }
}

- (void)configureNotificationBannerConstraints {
    NSView *contentView = [[self window] contentView];
    
    NSDictionary *defaultViews = @{
                                   @"bannerImage":     self.bannerImageView,
                                   @"title":           self.title,
                                   @"subtitle":        self.subtitle,
                                   @"informativeText": self.informativeText,
                                   @"contentView":     contentView
                                   };
    NSDictionary *defaultMetrics = @{
                                     @"padding":         @(bannerContentPadding),
                                     @"labelPaddingBetweenTitleAndSubTitle":@(bannerContentLabelPadding + 2),
                                     @"labelPadding":    @(bannerContentLabelPadding + 1),
                                     @"labelHeight":     @(self.title.intrinsicContentSize.height),
                                     @"imageWidth":      @(_bannerImageSize.width),
                                     @"imageHeight":     @(_bannerImageSize.height)
                                     };
    
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:defaultViews];
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:defaultMetrics];
    
    _labelWidth = 0;
    if (_userNotification.hasActionButton) {
        [views setValue:self.actionButton forKey:@"actionButton"];
        [views setValue:self.otherButton forKey:@"otherButton"];
        [metrics setValue:@(_calculatedButtonWidth) forKey:@"buttonWidth"];
        
        _labelWidth = _bannerSize.width - (bannerContentPadding + _bannerImageSize.width + bannerContentPadding + bannerContentPadding + _calculatedButtonWidth + bannerContentPadding);
    }
    
    else {
        _labelWidth = _bannerSize.width - (bannerContentPadding + _bannerImageSize.width + bannerContentPadding + bannerContentPadding);
    }
    [metrics setValue:@(_labelWidth) forKey:@"labelWidth"];
    
    float newHeight = [self.title intrinsicContentSize].height;
    if (![self.informativeText.cell usesSingleLineMode]) {
        newHeight *= (ceilf([self.informativeText intrinsicContentSize].width / _labelWidth));
        [self.informativeText setFrameSize:NSMakeSize(_labelWidth, newHeight)];
        _bannerSize.height += newHeight;
    }
    [metrics setValue:@(newHeight) forKey:@"informativeTextHeight"];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView]-(<=1)-[bannerImage(imageHeight)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[title(labelHeight)]-labelPaddingBetweenTitleAndSubTitle-[subtitle(labelHeight)]-labelPadding-[informativeText(>=informativeTextHeight)]"
                                                                        options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
    if (_userNotification.hasActionButton) {
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[otherButton]-padding-[actionButton]" options:0 metrics:metrics views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[bannerImage(imageWidth)]-padding-[title(labelWidth)]-padding-[otherButton(buttonWidth)]-padding-|" options:0 metrics:metrics views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[actionButton(==otherButton)]-padding-|" options:0 metrics:metrics views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subtitle(==title)]" options:0 metrics:metrics views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[informativeText(==title)]" options:0 metrics:metrics views:views]];
    }
    
    else {
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[bannerImage(imageWidth)]-padding-[title(labelWidth)]-padding-|" options:0 metrics:metrics views:views]];
    }
}

- (CGFloat)informativeTextHeightForWidth:(CGFloat)theWidth {
    NSFont *font = [NSFont fontWithName:@"LucidaGrande" size:11];
    CGFloat height = 0;
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self.informativeText.stringValue];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(theWidth, FLT_MAX)];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void)[layoutManager glyphRangeForTextContainer:textContainer];
    height = [layoutManager usedRectForTextContainer:textContainer].size.height + 5;
    return height;
}

#pragma mark - NSResponder

- (void)mouseUp:(NSEvent *)event
{
    [super mouseUp:event];
    if (NSPointInRect([event locationInWindow], self.window.contentView.bounds))
    {
        _bannerActivationHandler(CNUserNotificationActivationTypeContentsClicked);
        
    }
}

@end
