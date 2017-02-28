//  NSInvocation+Blocks.h - http://github.com/rentzsch/NSInvocation-blocks
//      Copyright (c) 2010 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//      Some rights reserved: http://opensource.org/licenses/mit-license.php

#import <Foundation/Foundation.h>

@interface NSInvocation (Blocks)

/*
    Usage example:
 
    NSInvocation *invocation = [NSInvocation jr_invocationWithTarget:myObject block:^(id myObject){
        [myObject someMethodWithArg:42.0];
    }];
 */

+ (id)jr_invocationWithTarget:(id)target block:(void (^)(id target))block;

@end
