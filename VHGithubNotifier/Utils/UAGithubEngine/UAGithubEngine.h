//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UAReachability;

typedef void (^UAGithubEngineSuccessBlock)(id responseObject);
typedef void (^UAGithubEngineBooleanSuccessBlock)(BOOL);
typedef void (^UAGithubEngineFailureBlock)(NSError *error);

@interface UAGithubEngine : NSObject 

@property (strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UAReachability *reachability;
@property (nonatomic, assign, readonly) BOOL isReachable;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword withReachability:(BOOL)withReach;

#pragma mark
#pragma mark Basic Request
#pragma mark

- (void)sendRequest:(NSString *)path
            success:(UAGithubEngineSuccessBlock)successBlock
            failure:(UAGithubEngineFailureBlock)failureBlock;

/*
 Where methods take a 'whateverPath' argument, supply the full path to 'whatever'.
 For example, if the method calls for 'repositoryPath', supply @"username/repository".

 Where methods take a 'whateverName' argument, supply just the name of 'whatever'. The username used will be that set in the engine instance.
 
 For methods that take an NSDictionary as an argument, this should contain the relevant keys and values for the required API call.
 See the documentation for more details on updating repositories, and adding and editing issues.
*/

#pragma mark
#pragma mark Gists
#pragma mark

- (void)gistsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)gistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)starredGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)gist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createGist:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)starGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)unstarGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)gistIsStarred:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)forkGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Comments

- (void)commentsForGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)gistComment:(NSInteger)commentId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteGistComment:(NSInteger)commentId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark
#pragma mark Issues 
#pragma mark

- (void)assignedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createdIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)subscribedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)mentionedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)openIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)closedIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)closeIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)reopenIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Comments 

- (void)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Events

- (void)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)issueEventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Labels

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (void)labelsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)label:(NSString *)labelName inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (void)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Milestones 

- (void)milestonesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addIssue:(NSInteger)issueId toMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark
#pragma mark Organisations
#pragma mark

- (void)organizationsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)organizationsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)organization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Members

- (void)membersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)user:(NSString *)user isMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeUser:(NSString *)user fromOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicMembersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Teams

- (void)teamsInOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)team:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)membersOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addUser:(NSString *)user toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repositoriesForTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
                                                             

#pragma mark
#pragma mark Pull Requests
#pragma mark

- (void)pullRequestsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Comments

- (void)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark
#pragma mark Repositories
#pragma mark

- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repositoriesWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)contributorsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)languageBreakdownForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)teamsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)annotatedTagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)branchesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Collaborators

- (void)collaboratorsForRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Commits

- (void)commitsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Commit Comments

- (void)commitCommentsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Downloads

- (void)downloadsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
// See http://developer.github.com/v3/repos/downloads for more information: this is a two-part process.
- (void)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Forks

- (void)forksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)forkRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Keys

- (void)deployKeysForRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Watching

- (void)watchersForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)watchedRepositoriesForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)watchedRepositoriessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)repositoryIsWatched:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)watchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)unwatchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Hooks

- (void)hooksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark
#pragma mark Users
#pragma mark

- (void)user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)userWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)editUser:(NSDictionary *)userDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Emails

- (void)emailAddressessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addEmailAddresses:(NSArray *)emails success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deleteEmailAddresses:(NSArray *)emails success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Followers

- (void)followers:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)followersWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)following:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)follows:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)follow:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)unfollow:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Keys

- (void)publicKeysWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicKey:(NSInteger)keyId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)addPublicKey:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)deletePublicKey:(NSInteger)keyId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark
#pragma mark Events
#pragma mark

- (void)eventsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)eventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)eventsForNetwork:(NSString *)networkPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)eventsReceivedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)eventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicEventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)eventsForOrganization:(NSString *)organization user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)publicEventsForOrganization:(NSString *)organization success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;

#pragma mark -
#pragma mark Notification
#pragma mark -

- (void)notificationsAll:(BOOL)all
           participating:(BOOL)participating
                 success:(UAGithubEngineSuccessBlock)successBlock
                 failure:(UAGithubEngineFailureBlock)failureBlock;

- (void)markNotificationAsRead:(long long)notificationId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;

- (void)threadSubscription:(long long)notificationId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;

#pragma mark -
#pragma mark Git Database API
#pragma mark -

// The following methods access the Git Database API.
// See http://developer.github.com/v3/git/ for more information.

#pragma mark Trees

- (void)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Blobs

- (void)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
/*
- (void)blob:(NSString *)blobPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)rawBlob:(NSString *)blobPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
 */
 

#pragma mark References

- (void)reference:(NSString *)reference inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)referencesInRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)tagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Tags

- (void)tag:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


#pragma mark Raw Commits

- (void)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;


@end
