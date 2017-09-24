//
//  VHLanguage.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>

@interface VHLanguage : RLMObject

@property long long languageId;
@property NSString *name;
@property NSString *requestName;
@property NSString *colorValue;

+ (NSArray<VHLanguage *> *)languagesFromData:(NSString *)data;

- (NSColor *)color;

- (BOOL)isValid;

@end

RLM_ARRAY_TYPE(VHLanguage)
