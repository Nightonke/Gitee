//
//  VHRecord.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/5.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>

@interface VHRecord : RLMObject

@property NSDate *date;
@property long long number;

+ (NSArray<VHRecord *> *)anytimeRecordsFromRecords:(NSArray<VHRecord *> *)records;

+ (NSArray<VHRecord *> *)dayRecordsFromRecords:(NSArray<VHRecord *> *)records;

+ (NSArray<VHRecord *> *)weekRecordsFromRecords:(NSArray<VHRecord *> *)records;

+ (NSArray<VHRecord *> *)monthRecordsFromRecords:(NSArray<VHRecord *> *)records;

+ (NSArray<VHRecord *> *)yearRecordsFromRecords:(NSArray<VHRecord *> *)records;

- (instancetype)initWithNumber:(long long)number;

@end

RLM_ARRAY_TYPE(VHRecord)
