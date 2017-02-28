//  NSInvocation+Blocks.m - http://github.com/rentzsch/NSInvocation-blocks
//      Copyright (c) 2010 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//      Some rights reserved: http://opensource.org/licenses/mit-license.php

#import "NSInvocation+Blocks.h"

@interface JRInvocationGrabber : NSProxy {
    id              target;
    NSInvocation    *invocation;
}
@property (retain) id target;
@property (retain) NSInvocation *invocation;
@end

@implementation JRInvocationGrabber
@synthesize target, invocation;

- (id)initWithTarget:(id)target_ {
    self.target = target_;
    return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector_ {
    return [self.target methodSignatureForSelector:selector_];
}

- (void)forwardInvocation:(NSInvocation*)invocation_ {
    [invocation_ setTarget:self.target];
    self.invocation = invocation_;
}

- (void)dealloc {
    self.target = nil;
    self.invocation = nil;
}
@end


@implementation NSInvocation (jr_block)

+ (id)jr_invocationWithTarget:(id)target_ block:(void (^)(id target))block_ {
    JRInvocationGrabber *grabber = [[JRInvocationGrabber alloc] initWithTarget:target_];
    block_(grabber);
    return grabber.invocation;
}

@end