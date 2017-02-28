//
//  NSArray+Utilities.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//
//	Credit: http://troybrant.net/blog/2010/02/adding-firstobject-to-nsarray/

#import "NSArray+Utilities.h"


@implementation NSArray (Utilities)

- (id)firstObject
{
    if ([self count] > 0)
    {
        return [self objectAtIndex:0];
    }
    return nil;
}


- (NSArray *)sortedWithKey:(NSString *)theKey ascending:(BOOL)ascending 
{
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:theKey ascending:ascending selector:@selector(caseInsensitiveCompare:)]]];
}


@end