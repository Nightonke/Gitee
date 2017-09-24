//
//  VHTrendingLanguageCellView.m
//  VHGithubNotifier
//
//  Created by Nightonke on 2017/9/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingLanguageCellView.h"

@interface VHTrendingLanguageCellView()

@property (weak) IBOutlet NSButton *checkBox;

@end

@implementation VHTrendingLanguageCellView

- (void)setLanguage:(VHLanguage *)language
{
    _language = language;
    self.checkBox.title = language.name;
    self.checkBox.bezelColor = language.color;
}

- (IBAction)onTrendingLanguageSelected:(NSButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onLanguage:selected:)])
    {
        BOOL isSelected = (self.checkBox.state == NSControlStateValueOn);
        [self.delegate onLanguage:self.language selected:isSelected];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected)
    {
        [self.checkBox setState:NSControlStateValueOn];
    }
    else
    {
        [self.checkBox setState:NSControlStateValueOff];
    }
}

@end
