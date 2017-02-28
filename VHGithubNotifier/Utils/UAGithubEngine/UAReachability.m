//
//  UAReachability.m
//  ReachTest
//
//  Created by Owain Hunt on 10/01/2011.
//  Copyright 2011 Owain R Hunt. All rights reserved.
//

#import "UAReachability.h"
#import "UAGithubEngineConstants.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation UAReachability

// http://www.cocoabuilder.com/archive/cocoa/166350-detecting-internet-code-part-1.html#166364

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:UAGithubReachabilityStatusDidChangeNotification object:(__bridge NSDictionary *)info];
}


- (void)dealloc
{
    if (reachabilityRef != NULL)
    {
        CFRelease(reachabilityRef);
    }
}


- (id)init
{
	if ((self = [super init]))
	{
		reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [@"www.github.com" UTF8String]);
		SCNetworkReachabilityContext context = {0, (__bridge void *)(self), CFRetain, CFRelease, NULL};
		SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallback, &context);
		SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);		
	}
	
	return self;
}	


- (NetworkStatus)currentReachabilityStatus
{
	SCNetworkReachabilityFlags flags;
	return (SCNetworkReachabilityGetFlags(reachabilityRef, &flags) && (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired));
}


- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	return (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
}
										   

@end
