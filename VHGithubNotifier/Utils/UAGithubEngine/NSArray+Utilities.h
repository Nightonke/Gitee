//
//  NSArray+Utilities.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities) 

- (id)firstObject;
- (NSArray *)sortedWithKey:(NSString *)theKey ascending:(BOOL)ascending;


@end
