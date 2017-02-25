//
//  VHRecord.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/1/5.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHRecord.h"
#import "NSDate+Utils.h"
#import "VHGithubNotifierManager+UserDefault.h"

@implementation VHRecord

#pragma mark - Public Methods

+ (NSArray<VHRecord *> *)anytimeRecordsFromRecords:(NSArray<VHRecord *> *)records
{
    return records;
}

+ (NSArray<VHRecord *> *)dayRecordsFromRecords:(NSArray<VHRecord *> *)records
{
    __block NSMutableArray<VHRecord *> *dayRecords = [NSMutableArray array];
    __block NSDate *date = nil;
    [records enumerateObjectsUsingBlock:^(VHRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([date isSameDayAsDate:record.date] == NO)
        {
            [dayRecords addObject:record];
            date = record.date;
        }
        else
        {
            [dayRecords replaceObjectAtIndex:[dayRecords count] - 1 withObject:record];
        }
    }];
    return [self recordsRemovedDuplicateNumberRecordsFrom:dayRecords];
}

+ (NSArray<VHRecord *> *)weekRecordsFromRecords:(NSArray<VHRecord *> *)records
{
    __block NSMutableArray<VHRecord *> *weekRecords = [NSMutableArray array];
    __block NSDate *date = nil;
    [records enumerateObjectsUsingBlock:^(VHRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([date isSameWeekAsDate:record.date byWeekStartFrom:[[VHGithubNotifierManager sharedManager] weekStartFrom]] == NO)
        {
            [weekRecords addObject:record];
            date = record.date;
        }
        else
        {
            [weekRecords replaceObjectAtIndex:[weekRecords count] - 1 withObject:record];
        }
    }];
    return [self recordsRemovedDuplicateNumberRecordsFrom:weekRecords];
}

+ (NSArray<VHRecord *> *)monthRecordsFromRecords:(NSArray<VHRecord *> *)records
{
    __block NSMutableArray<VHRecord *> *monthRecords = [NSMutableArray array];
    __block NSDate *date = nil;
    [records enumerateObjectsUsingBlock:^(VHRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([date isSameMonthAsDate:record.date] == NO)
        {
            [monthRecords addObject:record];
            date = record.date;
        }
        else
        {
            [monthRecords replaceObjectAtIndex:[monthRecords count] - 1 withObject:record];
        }
    }];
    return [self recordsRemovedDuplicateNumberRecordsFrom:monthRecords];
}

+ (NSArray<VHRecord *> *)yearRecordsFromRecords:(NSArray<VHRecord *> *)records
{
    __block NSMutableArray<VHRecord *> *yearRecords = [NSMutableArray array];
    __block NSDate *date = nil;
    [records enumerateObjectsUsingBlock:^(VHRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([date isSameYearAsDate:record.date] == NO)
        {
            [yearRecords addObject:record];
            date = record.date;
        }
        else
        {
            [yearRecords replaceObjectAtIndex:[yearRecords count] - 1 withObject:record];
        }
    }];
    return [self recordsRemovedDuplicateNumberRecordsFrom:yearRecords];
}

- (instancetype)initWithNumber:(long long)number
{
    self = [[VHRecord alloc] init];
    if (self)
    {
        _number = number;
        _date = [NSDate date];
    }
    return self;
}

#pragma mark - Private Methods

+ (NSArray<VHRecord *> *)recordsRemovedDuplicateNumberRecordsFrom:(NSArray<VHRecord *> *)records
{
    __block NSMutableArray<VHRecord *> *dealedRecords = [NSMutableArray array];
    __block long long number = [records firstObject].number - 1;
    [records enumerateObjectsUsingBlock:^(VHRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        if (number != record.number)
        {
            [dealedRecords addObject:record];
            number = record.number;
        }
        else
        {
            [dealedRecords replaceObjectAtIndex:[dealedRecords count] - 1 withObject:record];
        }
    }];
    return [dealedRecords copy];
}

@end
