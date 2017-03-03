//
//  VHNotificationGroupHeaderCellView.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/28.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSimpleRepository.h"

@interface VHNotificationGroupHeaderCellView : NSTableCellView

@property (nonatomic, strong) VHSimpleRepository *repository;

- (void)setNotificationNumber:(NSUInteger)notificationNumber;

@end
