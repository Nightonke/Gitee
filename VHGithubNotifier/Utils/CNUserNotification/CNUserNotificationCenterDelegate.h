//
//  CNUserNotificationCenterDelegate.h
//  CNUserNotification Example
//
//  Created by Frank Gregor on 17.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNUserNotificationCenter, CNUserNotification;

@protocol CNUserNotificationCenterDelegate <NSUserNotificationCenterDelegate>
@optional

/**
 Sent to the delegate when the user notification center has decided not to present your notification.

 @param center       The user notification center.
 @param notification The user notification object.

 @return notification should be displayed regardless; NO otherwise.
 */
- (BOOL)userNotificationCenter:(CNUserNotificationCenter *)center shouldPresentNotification:(CNUserNotification *)notification;

/**
 Sent to the delegate when a user clicks on a user notification presented by the user notification center.

 @param     center          The user notification center.
 @param     notification    The user notification object.
 */
- (void)userNotificationCenter:(CNUserNotificationCenter *)center didActivateNotification:(CNUserNotification *)notification;

/**
 Sent to the delegate when a notification delivery date has arrived.

 @param     center          The user notification center.
 @param     notification    The user notification object.
 
 This method is always called, regardless of your application state and even if you deliver the user notification yourself using deliverNotification:.

 This delegate method is invoked before the userNotificationCenter:shouldPresentNotification: delegate method.
 */
- (void)userNotificationCenter:(CNUserNotificationCenter *)center didDeliverNotification:(CNUserNotification *)notification;

/**
 Sent to the delegate when a notification is dismissed from screen.

 @param center       The user notification center.
 @param notification The user notification object.
 */
- (void)userNotificationCenter:(CNUserNotificationCenter *)center didRemoveNotification:(CNUserNotification *)notification;

@end
