//
//  VHNotificationGroupBodyCellView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHNotification.h"

@interface VHNotificationGroupBodyCellView : NSTableCellView

@property (nonatomic, strong) VHNotification *notification;
@property (nonatomic, assign) BOOL isLastBody;

@end
