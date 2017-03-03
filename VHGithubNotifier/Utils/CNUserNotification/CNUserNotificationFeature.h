//
//  CNUserNotificationFeature.h
//  CNUserNotification Example
//
//  Created by Frank Gregor on 26.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 `CNUserNotificationFeature` is the real extension for the user notifications. It holds additional features that gives you
 more flexibility using notifications.
 */


NS_CLASS_AVAILABLE(10_7, NA)
@interface CNUserNotificationFeature : NSObject

/**
 Property that specifies the banner dismiss delay time.
 */
@property (assign) NSTimeInterval dismissDelayTime;

/**
 Specifies the `NSLineBreakMode` for the [CNUserNotification informativeText].
 
 The value of this property specifies the appearance of the notification banner. All truncating values such as `NSLineBreakByTruncatingHead`,
 `NSLineBreakByTruncatingMiddle`, `NSLineBreakByTruncatingTail` and the `NSLineBreakByClipping` will present the [CNUserNotification informativeText]
 in single line mode. 
 
 `NSLineBreakByWordWrapping` and `NSLineBreakByCharWrapping` instead shows the `informativeText` in multiple lines
 and the notification banner height may grow.
 
 Use one of these constants from the AppKit.framework:
 
    enum {
        NSLineBreakByWordWrapping = 0,     	// Wrap at word boundaries, default
        NSLineBreakByCharWrapping,          // Wrap at character boundaries
        NSLineBreakByClipping,              // Simply clip
        NSLineBreakByTruncatingHead,        // Truncate at head of line: "...wxyz"
        NSLineBreakByTruncatingTail,        // Truncate at tail of line: "abcd..."
        NSLineBreakByTruncatingMiddle       // Truncate middle of line:  "ab...yz"
    };
    typedef NSUInteger NSLineBreakMode;
 */
@property (assign) NSLineBreakMode lineBreakMode;

/**
 Specifies an alternate notification banner image.
 
 If you don't set an own value for this property, the default will be set to the current application icon.
 */
@property (strong) NSImage *bannerImage;

@end
