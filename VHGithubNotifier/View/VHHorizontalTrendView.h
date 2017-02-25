//
//  VHHorizontalTrendView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VHHorizontalTrendView : NSView

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) NSColor *color;

- (void)setFrame:(CGRect)frame withValue:(CGFloat)value withMaxValue:(CGFloat)maxValue withColor:(NSColor *)color;

@end
