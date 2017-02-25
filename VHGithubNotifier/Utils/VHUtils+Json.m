//
//  VHUtils+Json.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/25.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils+Json.h"

@implementation VHUtils (Json)

+ (NSString *)getStringFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getStringFromDictionary:dict forKey:key withDefault:nil];
}

+ (NSString *)getStringFromDictionaryWithDefaultEmptyString:(NSDictionary *)dict forKey:(id<NSCopying>)key;
{
    return [VHUtils getStringFromDictionary:dict forKey:key withDefault:@""];
}

+ (NSString *)getStringFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSString *)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        NSString *value = SAFE_CAST([dict objectForKey:key], [NSString class]);
        if (value != nil)
        {
            withDefault = value;
        }
    }
    return withDefault;
}

+ (int64_t)getIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getIntegerFromDictionary:dict forKey:key withDefault:0];
}

+ (int64_t)getIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(int64_t)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        id value = [dict objectForKey:key];
        withDefault = [VHUtils getIntegerFromObject:value withDefault:withDefault];
    }
    return withDefault;
}

+ (uint64_t)getUnsignedIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getUnsignedIntegerFromDictionary:dict forKey:key withDefault:0];
}

+ (uint64_t)getUnsignedIntegerFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(uint64_t)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        id value = [dict objectForKey:key];
        withDefault = [VHUtils getUnsignedIntegerFromObject:value withDefault:withDefault];
    }
    return withDefault;
}

+ (double)getDoubleFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getDoubleFromDictionary:dict forKey:key withDefault:0.0];
}

+ (double)getDoubleFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(double)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        id value = [dict objectForKey:key];
        withDefault = [VHUtils getDoubleFromObject:value withDefault:withDefault];
    }
    return withDefault;
}

+ (NSArray *)getArrayFromDictionaryWithDefaultEmptyArray:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getArrayFromDictionary:dict forKey:key withDefault:[NSArray array]];
}

+ (NSArray *)getArrayFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getArrayFromDictionary:dict forKey:key withDefault:nil];
}

+ (NSArray *)getArrayFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSArray *)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        NSArray *value = SAFE_CAST([dict objectForKey:key], [NSArray class]);
        if (value != nil)
        {
            withDefault = value;
        }
    }
    return withDefault;
}

+ (id)getObjectFromDictionaryWithDefaultEmptyObject:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType
{
    id defaultClass = [classType new];
    return [VHUtils getObjectFromDictionary:dict forKey:key classType:classType withDefault:defaultClass];
}

+ (id)getObjectFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType
{
    return [VHUtils getObjectFromDictionary:dict forKey:key classType:classType withDefault:nil];
}


+ (id)getObjectFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key classType:(Class)classType withDefault:(id)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if (NO == [withDefault isKindOfClass:[classType class]])
    {
        withDefault = nil;
    }
    if ((dict != nil) && (key != nil))
    {
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[classType class]])
        {
            withDefault = value;
        }
    }
    return withDefault;
}

+ (NSDictionary *)getDicFromDictionaryWithDefaultEmptyDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getDicFromDictionary:dict forKey:key withDefault:[NSDictionary dictionary]];
}

+ (NSDictionary *)getDicFromDictionaryWithDefaultNil:(NSDictionary *)dict forKey:(id<NSCopying>)key
{
    return [VHUtils getDicFromDictionary:dict forKey:key withDefault:nil];
}

+ (NSDictionary *)getDicFromDictionary:(NSDictionary *)dict forKey:(id<NSCopying>)key withDefault:(NSDictionary *)withDefault
{
    dict = SAFE_CAST(dict, [NSDictionary class]);
    if ((dict != nil) && (key != nil))
    {
        NSDictionary *value = SAFE_CAST([dict objectForKey:key], [NSDictionary class]);
        if (value != nil)
        {
            withDefault = value;
        }
    }
    return withDefault;
}


+ (int64_t)getIntegerFromObject:(id)object withDefault:(uint64_t)withDefault
{
    NSString *string = SAFE_CAST(object, [NSString class]);
    NSNumber *number = SAFE_CAST(object, [NSNumber class]);
    
    if (nil != number)
    {
        string = [number stringValue];
    }
    if (nil != string)
    {
        withDefault = strtoll([string UTF8String], NULL, 10);
    }
    
    return withDefault;
}

+ (uint64_t)getUnsignedIntegerFromObject:(id)object withDefault:(uint64_t)withDefault
{
    NSString *string = SAFE_CAST(object, [NSString class]);
    NSNumber *number = SAFE_CAST(object, [NSNumber class]);
    
    if (nil != number)
    {
        uint64_t convertNum = [number unsignedLongLongValue];
        if (convertNum <= UINT32_MAX)
        {
            return convertNum;
        }
        else
        {
            string = [number stringValue];
        }
    }
    
    if (nil != string)
    {
        withDefault = strtoull([string UTF8String], NULL, 10);
    }
    
    return withDefault;
}

+ (double)getDoubleFromObject:(id)object withDefault:(double)withDefault
{
    NSString *string = SAFE_CAST(object, [NSString class]);
    NSNumber *number = SAFE_CAST(object, [NSNumber class]);
    if (nil != string)
    {
        withDefault = [string doubleValue];
    }
    else if (nil != number)
    {
        withDefault = [number doubleValue];
    }
    return withDefault;
}

@end
