//
//  UAReachability.h
//  ReachTest
//
//  Created by Owain Hunt on 10/01/2011.
//  Copyright 2011 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NotReachable = 0,
	Reachable,
} NetworkStatus;


@interface UAReachability : NSObject {
	SCNetworkReachabilityRef reachabilityRef;
}


- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags;
- (NetworkStatus)currentReachabilityStatus;


@end
