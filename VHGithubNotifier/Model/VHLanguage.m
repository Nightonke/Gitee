//
//  VHLanguage.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/20.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHLanguage.h"
#import <YAML-Framework/YAMLSerialization.h>
#import "VHUtils+Json.h"
#import "VHUtils+TransForm.h"

@interface VHLanguage ()

@property (nonatomic, strong) NSColor *color;

@end

@implementation VHLanguage

#pragma mark - Public Methods

+ (NSArray<VHLanguage *> *)languagesFromData:(NSString *)data
{
    __block NSMutableArray<VHLanguage *> *languages = [NSMutableArray array];
    NSError *yamlSerializationError = nil;
    NSMutableArray *yamlDatas = [YAMLSerialization objectsWithYAMLString:data
                                                                 options:kYAMLReadOptionStringScalars
                                                                   error:&yamlSerializationError];
    if (yamlSerializationError != nil)
    {
        LanguageLog(@"Languagesa serialized failed with error: %@", yamlSerializationError);
    }
    else
    {
        NSDictionary *yamlData = [yamlDatas firstObject];
        [yamlData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *languageData = SAFE_CAST(obj, [NSDictionary class]);
            if (languageData)
            {
                if ([[VHUtils getStringFromDictionaryWithDefaultNil:languageData forKey:@"type"] isEqualToString:@"programming"])
                {
                    VHLanguage *language = [[VHLanguage alloc] init];
                    language.languageId = [VHUtils getIntegerFromDictionary:languageData forKey:@"language_id" withDefault:-1];
                    language.name = key;
                    language.colorValue = [VHUtils getStringFromDictionaryWithDefaultNil:languageData forKey:@"color"];
                    if ([language isValid])
                    {
                        [languages addObject:language];
                    }
                }
            }
        }];
    }
    return [languages copy];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _languageId = -1;
    }
    return self;
}

- (NSColor *)color
{
    if (_color == nil)
    {
        _color = [VHUtils colorFromHexColorCodeInString:self.colorValue];
    }
    return _color;
}

- (BOOL)isValid
{
    return self.languageId != -1 && self.name && self.colorValue;
}

#pragma mark - Private Methods

+ (NSArray<NSString *> *)ignoredProperties
{
    return @[@"color"];
}

+ (NSString *)primaryKey
{
    return @"languageId";
}

@end
