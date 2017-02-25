//
//  VHRepositoryView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHRepositoryView.h"

@interface VHRepositoryView ()

@property (strong) IBOutlet NSView *view;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSView *languageIcon;
@property (weak) IBOutlet NSTextField *languageLabel;
@property (weak) IBOutlet NSImageView *starImageView;
@property (weak) IBOutlet NSTextField *starTextField;

@end

@implementation VHRepositoryView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if ([[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:nil])
        {
            [self.view setFrame:[self bounds]];
            [self addSubview:self.view];
        }
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setRepository:(VHRepository *)repository
{
    [self.nameTextField setStringValue:AVOID_NIL_STRING([repository name])];
    [self.languageLabel setStringValue:AVOID_NIL_STRING([repository language])];
    NSString *starNumberString = [NSString stringWithFormat:@"%lld", [repository starNumber]];
    [self.starTextField setStringValue:AVOID_NIL_STRING(starNumberString)];
    _repository = repository;
}

@end
