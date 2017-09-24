//
//  VHTrendingLanguageCellView.h
//  VHGithubNotifier
//
//  Created by Nightonke on 2017/9/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VHLanguage.h"

@protocol VHTrendingLanguageCellViewDelegate <NSObject>

@required
- (void)onLanguage:(VHLanguage *)language selected:(BOOL)selected;

@end

@interface VHTrendingLanguageCellView : NSTableCellView

@property (nonatomic, strong) VHLanguage *language;
@property (nonatomic, weak) id<VHTrendingLanguageCellViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;

@end
