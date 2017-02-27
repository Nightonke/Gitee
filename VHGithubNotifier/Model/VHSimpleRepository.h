//
//  VHSimpleRepository.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@interface VHSimpleRepository : NSObject<NSCopying>

@property (nonatomic, assign) long long repositoryId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *htmlUrl;

- (instancetype)initFromResponseDictionary:(NSDictionary *)dic;

- (BOOL)isValid;

- (BOOL)isEqualToRepository:(VHSimpleRepository *)repository;

@end
