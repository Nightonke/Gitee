//
//  CNUserNotificationFeature.m
//  CNUserNotification Example
//
//  Created by Frank Gregor on 26.05.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import "CNUserNotificationFeature.h"

@implementation CNUserNotificationFeature

- (id)init
{
    self = [super init];
    if (self) {
        _dismissDelayTime = 5;
        _lineBreakMode = NSLineBreakByTruncatingTail;
        _bannerImage = [NSApp applicationIconImage];
    }
    return self;
}

@end
