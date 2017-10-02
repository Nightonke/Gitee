//
//  VHSettingsWC.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/6.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSettingsWC.h"
#import "VHUtils.h"
#import "VHGithubNotifierManager+UserDefault.h"
#import "VHSettingsCellView.h"
#import "VHScroller.h"
#import "NSView+Position.h"

@interface VHSettingsWC ()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) VHScroller *scroller;
@property (nonatomic, strong) VHSettingsCellView *settingsCell;

@end

@implementation VHSettingsWC

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window.contentView setWantsLayer:YES];
    self.window.contentView.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.window.contentView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    self.window.toolbar.showsBaselineSeparator = NO;
    [self.window setMovableByWindowBackground:YES];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"VHSettingsCellView" bundle:nil]
                  forIdentifier:@"VHSettingsCellView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [NSColor clearColor];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    self.scrollView.drawsBackground = NO;
    self.scrollView.automaticallyAdjustsContentInsets = NO;
    [VHUtils scrollViewToTop:self.scrollView];
    
    self.scroller = [[VHScroller alloc] initWithFrame:NSMakeRect(self.window.contentView.width - 6, 10, 6, self.scrollView.height - 10)
                                       withImageFrame:NSMakeRect(0, self.scrollView.height - 60, 6, 60)
                                        withImageName:@"image_scroller"
                                 withPressedImageName:@"image_scroller_pressed"
                                       withScrollView:self.scrollView];
    [self.window.contentView addSubview:self.scroller];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 1103;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    self.settingsCell = [tableView makeViewWithIdentifier:@"VHSettingsCellView" owner:self];
    return self.settingsCell;
}

#pragma mark - Private Methods

- (void)showWindow:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
    [super showWindow:sender];
}

- (void)windowWillClose
{
    [self.settingsCell updateSettings];
    if (self.settingsWCDelegate && [self.settingsWCDelegate respondsToSelector:@selector(onSettingsWindowClosed)])
    {
        [self.settingsWCDelegate onSettingsWindowClosed];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
