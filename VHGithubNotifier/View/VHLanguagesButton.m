//
//  VHLanguagesButton.m
//  VHGithubNotifier
//
//  Created by Nightonke on 2017/9/23.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHLanguagesButton.h"
#import "VHLanguageDotView.h"
#import "NSView+Position.h"
#import "VHLanguage.h"

@implementation VHLanguagesButton

- (void)setSelectedLanguageIDs:(NSSet<NSNumber *> *)languageIDs
{
    [self removeAllSubViews];
    
    CGFloat startX = 10;
    CGFloat paddingX = 10;
    CGFloat width = 10;
    __block NSInteger index = 0;
    [languageIDs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        CGFloat x = startX + index * (width + paddingX);
        if (x + width > self.width)
        {
            *stop = YES;
        }
        else
        {
            RLMResults<VHLanguage *> *languages = [VHLanguage objectsWhere:@"languageId = %d", [obj integerValue]];
            VHLanguage *language = [languages firstObject];
            VHLanguageDotView *dot = [[VHLanguageDotView alloc] initWithFrame:NSMakeRect(startX + index * (width + paddingX), 0, width, width)];
            [dot setLanguageColor:language.color];
            [dot setVCenter:self.height / 2];
            [self addSubview:dot];
            index++;
        }
    }];
}

@end
