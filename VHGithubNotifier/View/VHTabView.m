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

const static CGFloat BOTTOM_MARGIN = 0;
const static CGFloat ICON_WIDTH = 40;
const static CGFloat ICON_HEIGHT = 40;
const static CGFloat ICONS_MARGIN = 5;
const static CGFloat BUTTON_UNSELECTED_ALPHA = 0.3;
const static CGFloat BUTTON_SELECTED_ALPHA = 1;

@interface VHTabView ()

@property (nonatomic, strong) NSMutableArray<NSButton *> *buttons;

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
    self.buttons = [NSMutableArray arrayWithCapacity:tags.count];
    CGFloat startX;
    if (images.count % 2 == 1)
    {
        startX = self.width / 2 - images.count / 2 * (ICONS_MARGIN + ICON_WIDTH) - ICON_WIDTH / 2;
    }
    else
    {
        startX = self.width / 2 - images.count / 2 * (ICONS_MARGIN + ICON_WIDTH) + ICONS_MARGIN / 2;
    }
    for (int i = 0; i < images.count; i++)
    {
        NSButton *button = [self iconWithImage:[images objectAtIndex:i]
                                       withTag:[[tags objectAtIndex:i] integerValue]];
        button.frame = NSMakeRect(startX + i * (ICON_WIDTH + ICONS_MARGIN),
                                  BOTTOM_MARGIN,
                                  ICON_WIDTH,
                                  ICON_HEIGHT);
        button.alphaValue = BUTTON_UNSELECTED_ALPHA;
        [self.buttons addObject:button];
        [self addSubview:button];
    }
}

- (NSButton *)iconWithImage:(NSImage *)image withTag:(NSInteger)tag
{
    image.template = NO;
    image.size = NSMakeSize(20, 20);
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    button.image = image;
    button.target = self;
    button.action = @selector(onIconClicked:);
    button.tag = tag;
    button.bordered = NO;
    [button setButtonType:NSButtonTypeMomentaryChange];
    button.bezelStyle = NSRoundRectBezelStyle;
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
