//
//  UAGithubJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubJSONParser.h"
#import "NSArray+Utilities.h"
#import "NSString+UAGithubEngineUtilities.h"

@implementation UAGithubJSONParser

+ (id)parseJSON:(NSData *)theJSON error:(NSError **)error;
{
    NSArray *dateElements = [NSArray arrayWithObjects:@"created_at", @"updated_at", @"closed_at", @"due_on", @"pushed_at", @"committed_at", @"merged_at", @"date", @"expirationdate", nil];
    NSMutableArray *jsonArray;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:theJSON options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:error];
    
    jsonArray = ([jsonObj isKindOfClass:[NSDictionary class]]) ? [NSMutableArray arrayWithObject:jsonObj] : [jsonObj mutableCopy];

    if (!error)
    {
        if ([[[jsonArray firstObject] allKeys] containsObject:@"error"])
        {
            NSDictionary *dictionary = [jsonArray firstObject];
            *error = [NSError errorWithDomain:@"UAGithubEngineGithubError" code:0 userInfo:[NSDictionary dictionaryWithObject:[dictionary objectForKey:@"error"] forKey:@"errorMessage"]];
            NSLog(@"Error: %@", *error);
        }
        
        for (NSMutableDictionary *theDictionary in jsonArray)
		{
            NSArray *keys = [theDictionary allKeys];
			for (NSString *keyString in dateElements)
			{
				if ([keys containsObject:keyString]) {
                    NSDate *date = [[theDictionary objectForKey:keyString] dateFromGithubDateString];
                    if (date != nil) 
                    {
                        [theDictionary setObject:date forKey:keyString];
                    }
				}
			}
		}
        
    }
    
    return jsonArray;
}


@end
