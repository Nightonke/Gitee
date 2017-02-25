//
//  VHTrendingRepositoryCellView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingRepository.h"
#import "VHLanguageDotView.h"

@protocol VHTrendingRepositoryCellViewDelegate <NSObject>

@required
- (void)onTrendingClicked:(VHTrendingRepository *)repository;

@end

@interface VHTrendingRepositoryCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *repositoryDescription;
@property (weak) IBOutlet VHLanguageDotView *languageDot;
@property (weak) IBOutlet NSTextField *language;
@property (weak) IBOutlet NSImageView *starImage;
@property (weak) IBOutlet NSTextField *starText;
@property (weak) IBOutlet NSImageView *forkImage;
@property (weak) IBOutlet NSTextField *forkText;
@property (weak) IBOutlet NSImageView *starTrendingImage;
@property (weak) IBOutlet NSTextField *starTrendingText;
@property (nonatomic, assign) BOOL isLastRow;
@property (nonatomic, weak) id<VHTrendingRepositoryCellViewDelegate> delegate;

- (void)setTrendingRepository:(VHTrendingRepository *)trendingRepository;

@end
