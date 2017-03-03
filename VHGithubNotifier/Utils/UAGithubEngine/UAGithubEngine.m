//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAReachability.h"

#import "UAGithubJSONParser.h"
#import "UAGithubEngineConstants.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubURLConnection.h"

#import "NSString+UAGithubEngineUtilities.h"
#import "NSData+Base64.h"
#import "NSString+UUID.h"

#import "NSInvocation+Blocks.h"
#import "VHUtils+TransForm.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"api.github.com"


@interface UAGithubEngine (Private)

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page error:(NSError **)error;

@end


@implementation UAGithubEngine

@synthesize username, password, reachability, isReachable;

#pragma mark
#pragma mark Setup & Teardown
#pragma mark

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword withReachability:(BOOL)withReach
{
    self = [super init];
	if (self) 
	{
		username = aUsername;
		password = aPassword;
		if (withReach)
		{
			reachability = [[UAReachability alloc] init];
		}
	}
	
	
	return self;
		
}


#pragma mark 
#pragma mark Reachability 
#pragma mark 

- (BOOL)isReachable
{
	return [self.reachability currentReachabilityStatus];
}	


- (UAReachability *)reachability
{
	if (!reachability)
	{
		reachability = [[UAReachability alloc] init];
	}
	
	return reachability;
}


#pragma mark 
#pragma mark Request Management
#pragma mark 

- (void)sendRequest:(NSString *)path
            success:(UAGithubEngineSuccessBlock)successBlock
            failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self) {
        [self sendRequest:path
              requestType:0
             responseType:0
           withParameters:nil
                     page:0
          pathNeedsPrefix:NO
                    error:nil];
    } success:successBlock failure:failureBlock];
}

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page pathNeedsPrefix:(BOOL)pathNeedsPrefix error:(NSError **)error
{
    
    NSMutableString *urlString = pathNeedsPrefix ? [NSMutableString stringWithFormat:@"%@%@/%@", API_PROTOCOL, API_DOMAIN, path] : [NSMutableString stringWithString:path];
    NSData *jsonData = nil;
    NSError *serializationError = nil;
    
    if ([params count] > 0)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&serializationError];
        
        if (serializationError)
        {
            *error = serializationError;
            return nil;
        }
    }
    

    NSMutableString *querystring = nil;

    if (!jsonData && [params count] > 0) 
	{
        // Is the querystring already present (ie a question mark is present in the path)? Create it if not.        
        if ([path rangeOfString:@"?"].location == NSNotFound)
        {
            querystring = [NSMutableString stringWithString:@"?"];
        }
        
		for (NSString *key in [params allKeys]) 
		{
			[querystring appendFormat:@"%@%@=%@", [querystring length] <= 1 ? @"" : @"&", key, [[params valueForKey:key] encodedString]];
		}
	}
    
    if (page > 0)
    {
        if (querystring) 
        {
            [querystring appendFormat:@"&page=%ld", page];
        }
        else
        {
            querystring = [NSMutableString stringWithFormat:@"?page=%ld", page];
        }
    }

    if ([querystring length] > 0)
	{
		[urlString appendString:querystring];
	}

	NSURL *theURL = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
	if (self.username && self.password)
	{
		[urlRequest setValue:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]] forHTTPHeaderField:@"Authorization"];	
	}

	if (jsonData)
    {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:jsonData];
    }

	switch (requestType) 
    {
        case UAGithubIssueAddRequest:
		case UAGithubRepositoryCreateRequest:
		case UAGithubRepositoryDeleteConfirmationRequest:
        case UAGithubMilestoneCreateRequest:
		case UAGithubDeployKeyAddRequest:
		case UAGithubDeployKeyDeleteRequest:
		case UAGithubIssueCommentAddRequest:
        case UAGithubPublicKeyAddRequest:            
        case UAGithubRepositoryLabelAddRequest:
        case UAGithubIssueLabelAddRequest:            
        case UAGithubTreeCreateRequest:            
        case UAGithubBlobCreateRequest:            
        case UAGithubReferenceCreateRequest:
        case UAGithubRawCommitCreateRequest:
        case UAGithubGistCreateRequest:
        case UAGithubGistCommentCreateRequest:
        case UAGithubGistForkRequest:
        case UAGithubPullRequestCreateRequest:
        case UAGithubPullRequestCommentCreateRequest:
        case UAGithubEmailAddRequest:    
        case UAGithubTeamCreateRequest:
		{
			[urlRequest setHTTPMethod:@"POST"];
		}
			break;

		case UAGithubCollaboratorAddRequest:
        case UAGithubIssueLabelReplaceRequest:
        case UAGithubFollowRequest:
        case UAGithubGistStarRequest:
        case UAGithubPullRequestMergeRequest:            
        case UAGithubOrganizationMembershipPublicizeRequest:
        case UAGithubTeamMemberAddRequest:
        case UAGithubTeamRepositoryManagershipAddRequest:
        case UAGithubNotificationThreadSetSubscriptionRequest:
        case UAGithubNotificationMarkReadForRepositoryRequest:
        {
            [urlRequest setHTTPMethod:@"PUT"];
        }
            break;
            
		case UAGithubRepositoryUpdateRequest:
        case UAGithubMilestoneUpdateRequest:
        case UAGithubIssueEditRequest:
        case UAGithubIssueCommentEditRequest:
        case UAGithubPublicKeyEditRequest:
        case UAGithubUserEditRequest:
        case UAGithubRepositoryLabelEditRequest:
        case UAGithubReferenceUpdateRequest:
        case UAGithubGistUpdateRequest:
        case UAGithubGistCommentUpdateRequest:
        case UAGithubPullRequestUpdateRequest:
        case UAGithubPullRequestCommentUpdateRequest:
        case UAGithubOrganizationUpdateRequest:
        case UAGithubTeamUpdateRequest:
        case UAGithubNotificationMarkReadRequest:
        {
            [urlRequest setHTTPMethod:@"PATCH"];
        }
            break;
            
        case UAGithubMilestoneDeleteRequest:
        case UAGithubIssueDeleteRequest:
        case UAGithubIssueCommentDeleteRequest:
        case UAGithubUnfollowRequest:
        case UAGithubPublicKeyDeleteRequest:
		case UAGithubCollaboratorRemoveRequest:            
        case UAGithubRepositoryLabelRemoveRequest:
        case UAGithubIssueLabelRemoveRequest:
        case UAGithubGistUnstarRequest:
        case UAGithubGistDeleteRequest:
        case UAGithubGistCommentDeleteRequest:
        case UAGithubPullRequestCommentDeleteRequest:
        case UAGithubEmailDeleteRequest:
        case UAGithubOrganizationMemberRemoveRequest:
        case UAGithubOrganizationMembershipConcealRequest:
        case UAGithubTeamDeleteRequest:
        case UAGithubTeamMemberRemoveRequest:
        case UAGithubTeamRepositoryManagershipRemoveRequest:
        {
            [urlRequest setHTTPMethod:@"DELETE"];
        }
            break;
            
		default:
			break;
	}
	
    NSError __block __strong *blockError = nil;
    NSError *connectionError = nil;

    id returnValue = [UAGithubURLConnection asyncRequest:urlRequest 
                                success:^(NSData *data, NSURLResponse *response)
                                {
                                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                    NSInteger statusCode = resp.statusCode;
                                    
                                    
                                    if ([[[resp allHeaderFields] allKeys] containsObject:@"X-Ratelimit-Remaining"] && [[[resp allHeaderFields] valueForKey:@"X-Ratelimit-Remaining"] isEqualToString:@"1"])
                                    {         
                                        blockError = [NSError errorWithDomain:UAGithubAPILimitReached code:statusCode userInfo:[NSDictionary dictionaryWithObject:urlRequest forKey:@"request"]];
                                        return (id)[NSNull null];
                                    }
                                    
                                    if (statusCode >= 400) 
                                    {
                                        if (statusCode == 404)
                                        {
                                            switch (requestType)
                                            {
                                                case UAGithubFollowingRequest:
                                                case UAGithubGistStarStatusRequest:
                                                case UAGithubOrganizationMembershipStatusRequest:
                                                case UAGithubTeamMembershipStatusRequest:
                                                case UAGithubTeamRepositoryManagershipStatusRequest:
                                                {
                                                    return (id)[NSNumber numberWithBool:NO];
                                                }
                                                    break;
                                                default:
                                                    break;
                                            }
                                        }
                                        
                                        blockError = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:[NSDictionary dictionaryWithObject:urlRequest forKey:@"request"]];
                                        
                                        return (id)[NSNull null];
                                                                                
                                    }
                                    
                                    else if (statusCode == UAGithubResetContentResponse)
                                    {
                                        return (id)[NSNumber numberWithInteger:UAGithubResetContentResponse];
                                    }
                                    
                                    else if (statusCode == 204)
                                    {
                                        return (id)[NSNumber numberWithBool:YES];
                                    }
                                    
                                    else
                                    {
                                        return [UAGithubJSONParser parseJSON:data error:&blockError];
                                    }

                                }
                                error:&connectionError];
   
    if (blockError)
    {
        if (*error)
        {
            *error = blockError;
        }
        return nil;
    }
    else if (connectionError)
    {
        if (*error)
        {
            *error = connectionError;
        }
        return nil;
    }

    // If returnValue is of class NSArray, it contains an array of NSDictionary objects.
    // If it's an NSNumber YES, then we're looking at a successful call that expects a No Content response.
    // If it's an NSNumber NO then that's a successful call to a method that returns an expected 404 response.
    
    return returnValue;
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error
{
    return [self sendRequest:path
                 requestType:requestType
                responseType:responseType
              withParameters:params
                        page:0
             pathNeedsPrefix:YES
                       error:error];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error
{
    return [self sendRequest:path
                 requestType:requestType
                responseType:responseType
              withParameters:nil
                        page:page
             pathNeedsPrefix:YES
                       error:error];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error
{
    return [self sendRequest:path
                 requestType:requestType
                responseType:responseType
              withParameters:nil
                        page:0
             pathNeedsPrefix:YES
                       error:error];
}


- (void)invoke:(void (^)(id obj))invocationBlock success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSError __unsafe_unretained *error = nil;
    NSError * __unsafe_unretained *errorPointer = &error;
    id __unsafe_unretained result;

    NSInvocation *invocation = [NSInvocation jr_invocationWithTarget:self block:invocationBlock];
    // Method signatures differ between invocations, but the last argument is always where the NSError lives
    [invocation setArgument:&errorPointer atIndex:[[invocation methodSignature] numberOfArguments] - 1];
    [invocation invoke];
    [invocation getReturnValue:&result];
    
    if (error)
    {
        failureBlock(error);
        return;
    }

    successBlock(result);
}


- (void)invoke:(void (^)(id obj))invocationBlock booleanSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    
    NSError __unsafe_unretained *error = nil;
    NSError * __unsafe_unretained *errorPointer = &error;
    BOOL result;
    
    NSInvocation *invocation = [NSInvocation jr_invocationWithTarget:self block:invocationBlock];
    [invocation setArgument:&errorPointer atIndex:[[invocation methodSignature] numberOfArguments] - 1];
    [invocation invoke];
    [invocation getReturnValue:&result];
    
    if (error)
    {
        failureBlock(error);
        return;
    }
    
    successBlock(result);
}


#pragma mark 
#pragma mark Gists
#pragma mark

- (void)gistsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/gists", user] requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)gistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"gists" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil];} success:successBlock failure:failureBlock];

}

- (void)publicGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"gists/public" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)starredGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"gists/starred" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)gist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistRequest responseType:UAGithubGistResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createGist:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"gists" requestType:UAGithubGistCreateRequest responseType:UAGithubGistResponse withParameters:gistDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistUpdateRequest responseType:UAGithubGistResponse withParameters:gistDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)starGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)unstarGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistUnstarRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)gistIsStarred:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)forkGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/fork", gistId] requestType:UAGithubGistForkRequest responseType:UAGithubGistResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Comments

- (void)commentsForGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentsRequest responseType:UAGithubGistCommentsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)gistComment:(NSInteger)commentId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentRequest responseType:UAGithubGistCommentResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentCreateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentUpdateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteGistComment:(NSInteger)commentId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark
#pragma mark Issues 
#pragma mark

- (void)assignedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"issues?state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil];} success:successBlock failure:failureBlock];  
}


- (void)createdIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"issues?filter=created&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil];} success:successBlock failure:failureBlock];  
}


- (void)subscribedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"issues?filter=subscribed&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil];} success:successBlock failure:failureBlock];  
}


- (void)mentionedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"issues?filter=mentioned&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil];} success:successBlock failure:failureBlock];      
}


- (void)openIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:parameters error:nil];} success:successBlock failure:failureBlock];
}


- (void)closedIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:parameters error:nil];} success:successBlock failure:failureBlock];
}


- (void)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary error:nil];} success:successBlock failure:failureBlock];	
}


- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary error:nil];} success:successBlock failure:failureBlock];	
}


- (void)closeIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *paramsDictionary = @{ @"state" : @"closed" };
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:paramsDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)reopenIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *paramsDictionary = @{ @"state" : @"open" };
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:paramsDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	
}


#pragma mark Comments

- (void)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
	
}


- (void)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Events

- (void)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/events", repositoryPath, issueId] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)issueEventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events", repositoryPath] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events/%ld", repositoryPath, eventId] requestType:UAGithubIssueEventRequest responseType:UAGithubIssueEventResponse error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Labels

- (void)labelsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)label:(NSString *)labelName inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse error:nil];} success:successBlock failure:failureBlock];
}

- (void)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary error:nil];} success:successBlock failure:failureBlock];	
}


- (void)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	
}


- (void)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels error:nil];} success:successBlock failure:failureBlock];
}


- (void)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	
}


- (void)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueNumber] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels error:nil];} success:successBlock failure:failureBlock];
}


- (void)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Milestones

- (void)milestonesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary error:nil];} success:successBlock failure:failureBlock]; 
}


- (void)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)addIssue:(NSInteger)issueNumber toMilestone:(NSInteger)milestoneNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = @{ @"milestone" : [NSString stringWithFormat:@"%ld", milestoneNumber] };
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:params error:nil];} success:successBlock failure:failureBlock];

}



#pragma mark
#pragma mark Organizations
#pragma mark

- (void)organizationsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{ 
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/orgs", user] requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)organizationsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/orgs" requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)organization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationRequest responseType:UAGithubOrganizationResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationUpdateRequest responseType:UAGithubOrganizationResponse withParameters:orgDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Members

- (void)membersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)user:(NSString *)user isMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)removeUser:(NSString *)user fromOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMemberRemoveRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)publicMembersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipPublicizeRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipConcealRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Teams

- (void)teamsInOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamsRequest responseType:UAGithubTeamsResponse error:nil];} success:successBlock failure:failureBlock];    
}


- (void)team:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamRequest responseType:UAGithubTeamResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamCreateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamUpdateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)membersOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/members", teamId] requestType:UAGithubTeamMembersRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)addUser:(NSString *)user toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMemberAddRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMemberRemoveRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)repositoriesForTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos", teamId] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipAddRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipRemoveRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (void)pullRequestsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestsRequest responseType:UAGithubPullRequestsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld", repositoryPath, pullRequestId] requestType:UAGithubPullRequestRequest responseType:UAGithubPullRequestResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestCreateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld", repositoryPath, pullRequestId] requestType:UAGithubPullRequestUpdateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/commits", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommitsRequest responseType:UAGithubPullRequestCommitsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/files", repositoryPath, pullRequestId] requestType:UAGithubPullRequestFilesRequest responseType:UAGithubPullRequestFilesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeStatusRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeRequest responseType:UAGithubPullRequestMergeSuccessStatusResponse error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Comments

- (void)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentsRequest responseType:UAGithubPullRequestCommentsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentRequest responseType:UAGithubPullRequestCommentResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentCreateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentUpdateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentDeleteRequest responseType:UAGithubPullRequestCommentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark
#pragma mark Repositories
#pragma mark

- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self repositoriesForUser:aUser includeWatched:watched page:1 success:successBlock failure:failureBlock];	
}

#pragma mark TODO watched repos?
- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/repos?page=%d", page] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)repositoriesWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/repos" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:@"user/repos" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary error:nil];} success:successBlock failure:failureBlock];	
}


- (void)repository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)contributorsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
   	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/contributitors", repositoryPath] requestType:UAGithubRepositoryContributorsRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)languageBreakdownForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)teamsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/teams", repositoryPath] requestType:UAGithubRepositoryTeamsRequest responseType:UAGithubRepositoryTeamsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)annotatedTagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)branchesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse error:nil];} success:successBlock failure:failureBlock];	
}


#pragma mark Collaborators

- (void)collaboratorsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, user] requestType:UAGithubCollaboratorsRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Commits

- (void)commitsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse error:nil];} success:successBlock failure:failureBlock];	
}


#pragma mark Commit Comments

- (void)commitCommentsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Downloads

- (void)downloadsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadsRequest responseType:UAGithubDownloadsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%ld", repositoryPath, downloadId] requestType:UAGithubDownloadRequest responseType:UAGithubDownloadResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadAddRequest responseType:UAGithubDownloadResponse withParameters:downloadDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%ld", repositoryPath, downloadId] requestType:UAGithubDownloadDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Forks

- (void)forksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForksRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    if (org)
    {
        [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:[NSDictionary dictionaryWithObject:org forKey:@"org"] error:nil];} success:successBlock failure:failureBlock];
    }
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)forkRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self forkRepository:repositoryPath inOrganization:nil success:successBlock failure:failureBlock];
}


#pragma mark Keys

- (void)deployKeysForRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryPath, keyId] requestType:UAGithubDeployKeyRequest responseType:UAGithubDeployKeyResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params error:nil];} success:successBlock failure:failureBlock];
    
}


- (void)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryPath, keyId] requestType:UAGithubDeployKeyEditRequest responseType:UAGithubDeployKeyResponse withParameters:keyDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryName, keyId] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
    
}


#pragma mark Watching

- (void)watchersForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/watchers", repositoryPath] requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)watchedRepositoriesForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/watched", user] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)watchedRepositoriessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/watched" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];} success:successBlock failure:failureBlock];
}



- (void)repositoryIsWatched:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchingRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)watchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	 
}


- (void)unwatchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Hooks

- (void)hooksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHooksRequest responseType:UAGithubRepositoryHooksResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookRequest responseType:UAGithubRepositoryHookResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHookAddRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookEditRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookTestRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark
#pragma mark Users
#pragma mark 

- (void)user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)userWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)editUser:(NSDictionary *)userDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Emails

- (void)emailAddressessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/emails" requestType:UAGithubEmailsRequest responseType:UAGithubEmailsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addEmailAddresses:(NSArray *)emails success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/emails" requestType:UAGithubEmailAddRequest responseType:UAGithubEmailsResponse withParameters:emails error:nil];} success:successBlock failure:failureBlock];
}


- (void)deleteEmailAddresses:(NSArray *)emails success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/emails" requestType:UAGithubEmailDeleteRequest responseType:UAGithubNoContentResponse withParameters:emails error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


#pragma mark Followers
// List a user's followers
- (void)followers:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse error:nil];} success:successBlock failure:failureBlock];	    
    
}

// List the authenticated user's followers
- (void)followersWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/followers" requestType:UAGithubUsersRequest responseType:UAGithubFollowersResponse error:nil];} success:successBlock failure:failureBlock];
}

// List who a user is following
- (void)following:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse error:nil];} success:successBlock failure:failureBlock];	    
}

// List who the authenticated user is following
- (void)followingWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/following" requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse error:nil];} success:successBlock failure:failureBlock];
}

// Check if the authenticated user follows another user
- (void)follows:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowingRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}

// Follow a user
- (void)follow:(NSString *)user  success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	    
   
}

// Unfollow a user
- (void)unfollow:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];	        
}


#pragma mark Keys

- (void)publicKeysWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)publicKey:(NSInteger)keyId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)addPublicKey:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)deletePublicKey:(NSInteger)keyId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse error:nil];} booleanSuccess:successBlock failure:failureBlock];
}


- (void)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags", repositoryPath] requestType:UAGithubTagObjectCreateRequest responseType:UAGithubAnnotatedTagResponse withParameters:tagDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark
#pragma mark Events
#pragma mark

- (void)eventsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:@"events" requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)eventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/events", repositoryPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)eventsForNetwork:(NSString *)networkPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"networks/%@/events", networkPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}
                         

- (void)eventsReceivedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/received_events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)eventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)publicEventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/events/public", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)eventsForOrganization:(NSString *)organization user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"users/%@/events/orgs/%@", user, organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)publicEventsForOrganization:(NSString *)organization success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"orgs/%@/events", organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil];} success:successBlock failure:failureBlock];
}

#pragma mark -
#pragma mark Notification
#pragma mark -

- (void)notificationsAll:(BOOL)all
           participating:(BOOL)participating
                 success:(UAGithubEngineSuccessBlock)successBlock
                 failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self) {
        NSString *url = [NSString stringWithFormat:@"notifications?all=%d&participating=%d", all, participating];
        [self sendRequest:url requestType:UAGithubNotificationListRequest responseType:UAGithubNotificationResponse error:nil];
    } success:successBlock failure:failureBlock];
}

- (void)markNotificationAsRead:(long long)notificationId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self) {
        NSString *url = [NSString stringWithFormat:@"notifications/threads/%lld", notificationId];
        [self sendRequest:url requestType:UAGithubNotificationMarkReadRequest responseType:UAGithubNotificationResponse error:nil];
    } success:successBlock failure:failureBlock];
}

- (void)threadSubscription:(long long)notificationId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self) {
        NSString *url = [NSString stringWithFormat:@"notifications/threads/%lld/subscription", notificationId];
        [self sendRequest:url requestType:UAGithubNotificationThreadGetSubscriptionRequest responseType:UAGithubNotificationResponse error:nil];
    } success:successBlock failure:failureBlock];
}

- (void)setThreadSubscription:(long long)notificationId subscribed:(BOOL)subscribed success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self) {
        NSString *url = [NSString stringWithFormat:@"notifications/threads/%lld/subscription", notificationId];
        [self sendRequest:url
              requestType:UAGithubNotificationThreadSetSubscriptionRequest
             responseType:UAGithubNotificationResponse
           withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@(NO), @"subscribed", @(YES), @"ignored", nil]
                    error:nil];
    } success:successBlock failure:failureBlock];
}

- (void)markNotificationAsReadInRepository:(NSString *)repositoryName ofOwner:(NSString *)ownerName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NetLog(@"%@", [VHUtils githubTimeStringFromDate:[NSDate date]]);
    [self invoke:^(id self) {
        NSString *url = [NSString stringWithFormat:@"repos/%@/%@/notifications", ownerName, repositoryName];
        [self sendRequest:url
              requestType:UAGithubNotificationMarkReadForRepositoryRequest
             responseType:UAGithubNotificationResponse
           withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[VHUtils githubTimeStringFromDate:[NSDate date]], @"last_read_at", nil]
                    error:nil];
    } success:successBlock failure:failureBlock];
}

#pragma mark -
#pragma mark Git Database API
#pragma mark -

#pragma mark Trees

- (void)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees/%@%@", repositoryPath, sha, recursive ? @"?recursive=1" : @""] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees", repositoryPath] requestType:UAGithubTreeCreateRequest responseType:UAGithubTreeResponse withParameters:treeDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Blobs

- (void)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs/%@", repositoryPath, sha] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse error:nil];} success:successBlock failure:failureBlock];	
}


- (void)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs", repositoryPath] requestType:UAGithubBlobCreateRequest responseType:UAGithubSHAResponse withParameters:blobDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark References

- (void)reference:(NSString *)reference inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceRequest responseType:UAGithubReferenceResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)referencesInRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)tagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/tags", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferenceCreateRequest responseType:UAGithubReferenceResponse withParameters:refDictionary error:nil];} success:successBlock failure:failureBlock];
}


- (void)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceUpdateRequest responseType:UAGithubReferenceResponse withParameters:referenceDictionary error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Tags

- (void)tag:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags/%@", repositoryPath, sha] requestType:UAGithubTagObjectRequest responseType:UAGithubAnnotatedTagResponse error:nil];} success:successBlock failure:failureBlock];
}


#pragma mark Raw Commits

- (void)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits/%@", repositoryPath, commit] requestType:UAGithubRawCommitRequest responseType:UAGithubRawCommitResponse error:nil];} success:successBlock failure:failureBlock];
}


- (void)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:^(id self){[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits", repositoryPath] requestType:UAGithubRawCommitCreateRequest responseType:UAGithubRawCommitResponse withParameters:commitDictionary error:nil];} success:successBlock failure:failureBlock];
}

@end
