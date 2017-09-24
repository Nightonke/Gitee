//
//  VHTrendingRepository.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface VHTrendingRepository : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ownerAccount;
@property (nonatomic, strong) NSString *repositoryDescription;
@property (nonatomic, strong) NSString *languageName;
@property (nonatomic, strong) NSColor *languageColor;
@property (nonatomic, strong) NSString *starNumberString;
@property (nonatomic, assign, readonly) NSInteger starNumber;
@property (nonatomic, strong) NSString *forkNumberString;
@property (nonatomic, assign, readonly) NSInteger forkNumber;
@property (nonatomic, strong) NSArray<NSString *> *contributorAvatars;
@property (nonatomic, strong) NSString *trendingTip;
@property (nonatomic, assign, readonly) NSInteger trendingTipStarNumber;

- (BOOL)isValid;

@end
