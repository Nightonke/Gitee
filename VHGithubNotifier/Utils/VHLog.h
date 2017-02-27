//
//  VHLog.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/26.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#ifndef VHLog_h
#define VHLog_h

#ifdef __cplusplus
extern "C"
{
#endif
    void VHLog(NSString *category, NSString* format, ...) NS_FORMAT_FUNCTION(2, 3);
#ifdef DEBUG
    void setLogFilter(NSString *filterStr);//只打印包含filterStr的log内容 屏蔽掉其他log
#else
#define setLogFilter MyLog
#endif
    
#ifdef __cplusplus
}
#endif

#define PermanentLog(category,format,...) VHLog(category,format,##__VA_ARGS__)
#define NotificationLog(format,...) PermanentLog(@"Notification",format,##__VA_ARGS__)

#endif /* VHLog_h */
