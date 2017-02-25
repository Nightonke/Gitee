//
//  VHTrendTableCellView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/18.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHRecord.h"

@interface VHTrendTableCellView : NSTableCellView

@property (nonatomic, strong) NSColor *trendColor;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, strong) VHRecord *record;

@end
