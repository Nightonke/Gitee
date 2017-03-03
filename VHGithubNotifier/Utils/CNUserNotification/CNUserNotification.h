//
//  CNUserNotification.h
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
#import "CNUserNotificationCenter.h"
#import "CNUserNotificationCenterDelegate.h"
#import "CNUserNotificationFeature.h"


/// notification names
extern NSString *const CNUserNotificationHasBeenPresentedNotification;
extern NSString *const CNUserNotificationDismissBannerNotification;
extern NSString *const CNUserNotificationActivatedWithTypeNotification;
extern NSString *const CNUserNotificationDefaultSound;

extern NSString *const NSUserNotificationDefaultSoundName;


/**
 These attributes describes the way a notification was activated.
 */
typedef NS_ENUM (NSInteger, CNUserNotificationActivationType) {
/**
 No notification was activated. This is the default value.
 */
    CNUserNotificationActivationTypeNone = 0,
/**
 The user has clicked the notification banner itself.
 */
    CNUserNotificationActivationTypeContentsClicked,
/**
 The user has clicked the action button of a notification.
 */
    CNUserNotificationActivationTypeActionButtonClicked
};


NS_CLASS_AVAILABLE(10_7, NA)
@interface CNUserNotification : NSObject <NSCopying>

#pragma mark - Display Information
/** @name Display Information */

/**
 Specifies the title of the notification.
 
 This value should localized as it will be presented to the user. The string will be truncated to a length appropriate for 
 display and the property will be modified to reflect the truncation.

 @see subtitle
 @see informativeText
 */
@property (copy) NSString *title;

/**
 Specifies the subtitle of the notification.
 
 This value should localized as it will be presented to the user. The string will be truncated to a length appropriate for 
 display and the property will be modified to reflect the truncation.

 @see title
 @see informativeText
 */
@property (copy) NSString *subtitle;

/**
 The body text of the notification.
 
 This value should localized as it will be presented to the user. The string will be truncated to a length appropriate for 
 display and the property will be modified to reflect the truncation.

 @see title
 @see subtitle
 */
@property (copy) NSString *informativeText;


#pragma mark - Displayed Notification Buttons
/** @name Displayed Notification Buttons */

/**
 Specifies whether the notification displays an action button.
 
 Set to `NO` if the notification has no action button. This will be the case for notifications that are purely for 
 informational purposes and have no user action.
 
 The default value is `YES`.

 @see actionButtonTitle
 @see otherButtonTitle
 */
@property BOOL hasActionButton;

/**
 Specifies the title of the action button displayed in the notification.
 
 This value should localized as it will be presented to the user. The string will be truncated to a length appropriate for 
 display and the property will be modified to reflect the truncation.

 @see hasActionButton
 @see otherButtonTitle
 */
@property (copy) NSString *actionButtonTitle;

/**
 Specifies a custom title for the close button in an alert-style notification.
 
 This value should localized as it will be presented to the user. The string will be truncated to a length appropriate for 
 display and the property will be modified to reflect the truncation.
 
 An empty string will cause the default localized text to be used. A `nil` value is invalid.

 @see hasActionButton
 @see actionButtonTitle
 */
@property (copy) NSString *otherButtonTitle;


#pragma mark - Delivery Timing
/** @name User Delivery Timing */

@property (copy) NSDate *deliveryDate;

@property (readonly) NSDate *actualDeliveryDate;

@property (copy) NSDateComponents *deliveryRepeatInterval;

@property (copy) NSTimeZone *deliveryTimeZone;


#pragma mark - Delivery Information
/** @name User Delivery Information */

@property (readonly, getter=isPresented) BOOL presented;

@property (readonly, getter=isRemote) BOOL remote;

/**
 Specifies the name of the sound to play when the notification is delivered.
 
 Passing the `NSUserNotificationDefaultSoundName` constant causes the default notification center sound to be played.
 A value of nil means no sound is played.
 
 Default value is `nil`.
 */
@property (copy) NSString *soundName;


#pragma mark - User Notification Activation Method
/** @name User Notification Activation Method */

/**
 Specifies what caused a user notification to occur. (read-only)
 
 This property specifies why the user notification was sent to to the CNUserNotificationCenterDelegate method 
 `userNotificationCenter:didActivateNotification:`.
 The supported values are described in `CNUserNotificationActivationType`.
 */
@property (readonly) CNUserNotificationActivationType activationType;


#pragma mark - User Notification User Information
/** @name User Notification User Information */

/**
 Application-specific user info that can be attached to the notification.
 
 All items must be property list types or an exception will be thrown.
 */
@property (copy) NSDictionary *userInfo;


#pragma mark - User Notification Additional Features
/** @name User Notification Additional Features */

/**
 Returns the CNUserNotificationFeature extension object.
 */
- (CNUserNotificationFeature *)feature;

/**
 Sets the CNUserNotificationFeature extension object.
 */
- (void)setFeature:(CNUserNotificationFeature *)theFeature;

@end



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSUserNotification+CNUserNotificationAdditions

@interface NSUserNotification (CNUserNotificationAdditions)
- (CNUserNotificationFeature *)feature;
- (void)setFeature:(CNUserNotificationFeature *)theFeature;
@end
