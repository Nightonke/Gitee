//
//  VHUtils+Json.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils.h"

@interface VHUtils (Json)

+ (NSString *)getStringFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (NSString *)getStringFromDictionaryWithDefaultEmptyString:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (NSString *)getStringFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSString *)withDefault;

// returns zero if fails
+ (int64_t)getIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (int64_t)getIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(int64_t)withDefault;

// returns zero if fails
+ (uint64_t)getUnsignedIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (uint64_t)getUnsignedIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(uint64_t)withDefault;

// returns zero if fails
+ (double)getDoubleFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (double)getDoubleFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(double)withDefault;

// returns nil if fails
+ (NSArray *)getArrayFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (NSArray *)getArrayFromDictionaryWithDefaultEmptyArray:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (NSArray *)getArrayFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSArray *)withDefault;;

// returns nil if fails
+ (NSDictionary *)getDicFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key;
// dictionary，失败返回一个空的dictionary，never return nil
+ (NSDictionary *)getDicFromDictionaryWithDefaultEmptyDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key;
+ (NSDictionary *)getDicFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSDictionary *)withDefault;

// returns nil if fails
+ (id)getObjectFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType;
// return a empty Class if fails
+ (id)getObjectFromDictionaryWithDefaultEmptyObject:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType;
// if default is nil, then it returns nil if fails
+ (id)getObjectFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType withDefault:(id)withDefault;

@end
