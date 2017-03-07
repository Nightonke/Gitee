//
//  VHTabView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHTabView.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "NSView+Position.h"
#import "NSMutableArray+Safe.h"
#import "VHCursorButton.h"
#import "VHUtils.h"

const static CGFloat BOTTOM_MARGIN = 0;
const static CGFloat ICON_WIDTH = 30;
const static CGFloat ICON_HEIGHT = 40;
const static CGFloat ICONS_MARGIN = 5;
const static CGFloat BUTTON_UNSELECTED_ALPHA = 0.7;
const static CGFloat BUTTON_SELECTED_ALPHA = 1;

@interface VHTabView ()

@property (nonatomic, strong) NSMutableArray<VHCursorButton *> *buttons;

@end

@implementation VHTabView

#pragma mark - Public Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTabs)
                                                     name:kNotifyGithubContentsChanged
                                                   object:nil];
        _buttons = [NSMutableArray array];
        [self updateTabs];
        [self setSelectedTab:0];
    }
    return self;
}

- (void)setSelectedTab:(NSUInteger)selectedTab
{
    for (NSButton *button in self.buttons)
    {
        button.alphaValue = BUTTON_UNSELECTED_ALPHA;
    }
    [self.buttons safeObjectAtIndex:_selectedTab].alphaValue = BUTTON_SELECTED_ALPHA;
    _selectedTab = selectedTab;
}

#pragma mark - Private Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTabs
{
    NSArray<NSImage *> *images = [[VHGithubNotifierManager sharedManager] imagesForGithubContentTypes];
    NSArray<NSNumber *> *tags = [[VHGithubNotifierManager sharedManager] githubContentTypes];
    NSArray<NSString *> *tooltips = [[VHGithubNotifierManager sharedManager] tooltipsForGithubContentTypes];
    self.buttons = [NSMutableArray arrayWithCapacity:tags.count];
    CGFloat startX = 10;
    for (int i = 0; i < images.count; i++)
    {
        VHCursorButton *button = [self iconWithImage:[images objectAtIndex:i]
                                             withTag:[[tags objectAtIndex:i] integerValue]];
        button.toolTip = [tooltips objectAtIndex:i];
        button.frame = NSMakeRect(startX + i * (ICON_WIDTH + ICONS_MARGIN),
                                  BOTTOM_MARGIN,
                                  ICON_WIDTH,
                                  ICON_HEIGHT);
        button.alphaValue = BUTTON_UNSELECTED_ALPHA;
        [self.buttons addObject:button];
        [self addSubview:button];
    }
}

- (VHCursorButton *)iconWithImage:(NSImage *)image withTag:(NSInteger)tag
{
    image.template = NO;
    image.size = NSMakeSize(20, 20);
    VHCursorButton *button = [[VHCursorButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [button setButtonType:NSButtonTypeMomentaryChange];
    button.bezelStyle = NSRoundRectBezelStyle;
    button.image = image;
    button.target = self;
    button.action = @selector(onIconClicked:);
    button.tag = tag;
    button.bordered = NO;
    return button;
}

- (void)onIconClicked:(NSButton *)button
{
    for (NSButton *button in self.buttons)
    {
        button.alphaValue = BUTTON_UNSELECTED_ALPHA;
    }
    [self.buttons safeObjectAtIndex:log(button.tag) / log(2)].alphaValue = BUTTON_SELECTED_ALPHA;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectGithubContentType:)])
    {
        [self.delegate didSelectGithubContentType:button.tag];
    }
}

@end
