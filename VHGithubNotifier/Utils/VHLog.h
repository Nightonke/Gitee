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
#define NetLog(format,...) PermanentLog(@"Net",format,##__VA_ARGS__)
#define SystemLog(format,...) PermanentLog(@"System",format,##__VA_ARGS__)
#define BasicInfoLog(format,...) PermanentLog(@"BasicInfo",format,##__VA_ARGS__)
#define ConfirmLog(format,...) PermanentLog(@"Confirm",format,##__VA_ARGS__)
#define LanguageLog(format,...) PermanentLog(@"Language",format,##__VA_ARGS__)
#define TrendLog(format,...) PermanentLog(@"Trend",format,##__VA_ARGS__)
#define TrendingLog(format,...) PermanentLog(@"Trending",format,##__VA_ARGS__)
#define NotificationLog(format,...) PermanentLog(@"Notification",format,##__VA_ARGS__)
#define ProfileLog(format,...) PermanentLog(@"Profile",format,##__VA_ARGS__)
#define ViewLog(format,...) PermanentLog(@"View",format,##__VA_ARGS__)

#endif /* VHLog_h */
