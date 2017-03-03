//
//  CNUserNotificationCenter.h
//
//  Created by Frank Gregor on 16.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2013 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

@class CNUserNotification;
@protocol CNUserNotificationCenterDelegate;


NS_CLASS_AVAILABLE(10_7, NA)
@interface CNUserNotificationCenter : NSObject

#pragma mark - Creating a User Notification Center
/** @name Creating a User Notification Center */

/**
 Returns the default user notification center.

 Creating an instance this way let the `CNUserNotificationCenter` class decide which implementation of notification center will be used regarding the environmental OS X version.


 @note <br>**OS X 10.7** - will return a `CNUserNotificationCenter` object<br>**OS X 10.8+** - will return a `NSUserNotificationCenter` object

 */
+ (instancetype)defaultUserNotificationCenter;

/**
 Allways returns the custom user notification center.

 Creating an instance this way the custom implementation of `CNUserNotificationCenter` will be used. `NSUserNotificationCenter` will be ignored.
 */
+ (instancetype)customUserNotificationCenter;


#pragma mark - Managing the Scheduled Notification Queue
/** @name Managing the Scheduled Notification Queue */

/**
 Schedules the specified user notification.

 Scheduled notifications are added to the end of the notification queue.

 @param notification    The user notification.
 */
//- (void)scheduleNotification:(CNUserNotification *)notification;

/**

 */
//@property (copy) NSArray *scheduledNotifications;

/**
 Removes the specified user notification for the scheduled notifications.

 If the notification is not in the scheduled list, nothing happens.

 @param notification    The user notification.
 */
//- (void)removeScheduledNotification:(CNUserNotification *)notification;


#pragma mark - Managing the Delivered Notifications
/** @name Managing the Delivered Notifications */

/**
 Deliver the specified user notification.

 The notification will be presented to the user. The presented property of the `NSUserNotification` object will always be set to `YES` if a notification is delivered using this method.

 @param notification	 The user notification.
 */
- (void)deliverNotification:(CNUserNotification *)notification;


#pragma mark - Getting and Setting the Delegate
/** @name Getting and Setting the Delegate */

/**
 Specifies the notification center delegate.

 The delegate must conform to the `CNUserNotificationCenterDelegate` protocol.
 */
@property (weak) id<CNUserNotificationCenterDelegate> delegate;
@end
