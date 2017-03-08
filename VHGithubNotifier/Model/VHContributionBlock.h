//
//  VHContributionBlock.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/8.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "TFHpple.h"

@interface VHContributionBlock : NSObject

@property (nonatomic, assign) Byte level;
@property (nonatomic, assign) NSUInteger contributions;
@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithHppleElement:(TFHppleElement *)element;

- (NSColor *)leftFaceColor;

- (NSColor *)rightFaceColor;

- (NSColor *)topFaceColor;

@end
