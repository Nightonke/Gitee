//
//  VHTrendChartParser.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/4.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHRecord.h"

@interface VHTrendChartParser : NSObject

+ (NSString *)chartHtmlContentWithTitle:(NSString *)title withRecords:(NSArray<VHRecord *> *)records withYValueName:(NSString *)yValueName;

@end
