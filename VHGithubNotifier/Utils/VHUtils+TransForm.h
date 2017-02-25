//
//  VHUtils+TransForm.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2016/12/28.
//  Copyright © 2016年 黄伟平. All rights reserved.
//

#import "VHUtils.h"

@interface VHUtils (TransForm)

+ (NSImage *)imageFromGithubContentType:(VHGithubContentType)type;

+ (NSColor *)colorFromHexColorCodeInString:(NSString *)string;

+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

@end
