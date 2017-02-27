//
//  VHLog.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

static void VHInnerLog(NSString *category, NSString* format, va_list argList)
{
    va_list copyList;
    va_copy(copyList, argList);
    
    if ([format length] == 0)
    {
        return;
    }
    
    NSLogv([[NSMutableString alloc] initWithFormat:@"[%@] %@", category, format], argList);
}

void VHLog(NSString *category, NSString* format, ...)
{
    va_list argList;
    va_start(argList, format);
    VHInnerLog(category,format, argList);
    va_end(argList);
}
