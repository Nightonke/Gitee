//
//  UAGithubURLConnection.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 26/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAGithubEngineRequestTypes.h"

@interface UAGithubURLConnection : NSURLConnection 
{
    NSMutableData *data;                   
    UAGithubRequestType requestType;      
	UAGithubResponseType responseType;
    NSString *identifier;
}


@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) UAGithubRequestType requestType;
@property (nonatomic, assign) UAGithubResponseType responseType;
@property (nonatomic, strong) NSString *identifier;

+ (id)asyncRequest:(NSURLRequest *)request success:(id(^)(NSData *, NSURLResponse *))successBlock failure:(id(^)(NSError *))failureBlock_;
+ (id)asyncRequest:(NSURLRequest *)request success:(id(^)(NSData *, NSURLResponse *))successBlock error:(NSError *__strong *)error;

@end
