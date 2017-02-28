//
//  UAGithubEngineRequestTypes.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//



typedef enum UAGithubRequestType 
{
    UAGithubUsersRequest = 0,// Get more than one non-specific user
	UAGithubUserRequest,							// Get exactly one specific user
    UAGithubUserEditRequest,                        // Edit the authenticated user
    UAGithubEmailsRequest,                          // Get one or more email addresses
    UAGithubEmailAddRequest,                        // Add one or more email addresses
    UAGithubEmailDeleteRequest,                     // Delete one or more email addresses
	UAGithubRepositoriesRequest,					// Get more than one non-specific repository
	UAGithubRepositoryRequest,						// Get exactly one specific repository
	UAGithubRepositoryUpdateRequest,				// Update repository metadata
    UAGithubRepositoryWatchingRequest,              // Auth'd user watching a specific repository?
	UAGithubRepositoryWatchRequest,					// Watch a repository
	UAGithubRepositoryUnwatchRequest,				// Unwatch a repository
    UAGithubRepositoryForksRequest,                 // Get one or more forks
	UAGithubRepositoryForkRequest,					// Fork a repository
	UAGithubRepositoryCreateRequest,				// Create a repository
	UAGithubRepositoryPrivatiseRequest,				// Make a repository private
	UAGithubRepositoryPubliciseRequest,				// Make a repository public
	UAGithubRepositoryDeleteRequest,				// Delete a repository
	UAGithubRepositoryDeleteConfirmationRequest,	// Confirm deletion of a repository
	UAGithubDeployKeysRequest,						// Get repository-specific deploy keys
    UAGithubDeployKeyRequest,                       // Get exactly one specific deploy key
	UAGithubDeployKeyAddRequest,					// Add a repository-specific deploy key
    UAGithubDeployKeyEditRequest,                   // Edit a deploy key
	UAGithubDeployKeyDeleteRequest,					// Delete a repository-specific deploy key
	UAGithubRepositoryLanguageBreakdownRequest,		// Get the language breakdown for a repository
    UAGithubRepositoryContributorsRequest,          // Get one or more contributors
    UAGithubRepositoryTeamsRequest,                 // Get one or more teams
	UAGithubTagsRequest,							// Tags for a repository
	UAGithubBranchesRequest,						// Branches for a repository
	UAGithubCollaboratorsRequest,					// Collaborators for a repository
	UAGithubCollaboratorAddRequest,					// Add a collaborator
	UAGithubCollaboratorRemoveRequest,				// Remove a collaborator
    UAGithubDownloadsRequest,                       // Get one or more downloads
    UAGithubDownloadRequest,                        // Get exactly one specific download
    UAGithubDownloadAddRequest,                     // Add a download
    UAGithubDownloadDeleteRequest,                  // Delete a download
    UAGithubRepositoryHooksRequest,                 // Get one or more repository hooks
    UAGithubRepositoryHookRequest,                  // Get one specific repository hook
    UAGithubRepositoryHookAddRequest,               // Add a repository hook
    UAGithubRepositoryHookEditRequest,              // Edit a repository hook
    UAGithubRepositoryHookTestRequest,              // Test a repository hook
    UAGithubRepositoryHookDeleteRequest,            // Delete a repository hook
	UAGithubCommitsRequest,							// Get more than one non-specific commit
	UAGithubCommitRequest,							// Get exactly one specific commit
    UAGithubCommitCommentsRequest,                  // Get one or more commit comments
    UAGithubCommitCommentRequest,                   // Get exactly one commit comment
    UAGithubCommitCommentAddRequest,                // Add a commit comment
    UAGithubCommitCommentEditRequest,               // Edit a commit comment
    UAGithubCommitCommentDeleteRequest,             // Delete a commit comment
	UAGithubIssuesOpenRequest,						// Get open issues
	UAGithubIssuesClosedRequest,					// Get closed issues
    UAGithubIssuesRequest,                          // Get all issues
	UAGithubIssueRequest,							// Get exactly one specific issue
	UAGithubIssueAddRequest,						// Add an issue
	UAGithubIssueEditRequest,						// Edit an issue
	UAGithubIssueCloseRequest,						// Close an issue
	UAGithubIssueReopenRequest,						// Reopen a closed issue
    UAGithubIssueDeleteRequest,                     // Delete an issue
	UAGithubRepositoryLabelsRequest,				// Get repository-wide issue labels
	UAGithubRepositoryLabelAddRequest,				// Add a repository-wide issue label
    UAGithubRepositoryLabelEditRequest,             // Edit a repository-wide issue label
	UAGithubRepositoryLabelRemoveRequest,			// Remove a repository-wide issue label
    UAGithubIssueLabelsRequest,                     // Get one or more issue labels
    UAGithubIssueLabelRequest,                      // Get exactly one specific issue label
	UAGithubIssueLabelAddRequest,					// Add a label to a specific issue
	UAGithubIssueLabelRemoveRequest,				// Remove a label from a specific issue
    UAGithubIssueLabelReplaceRequest,               // Replace all labels on a specific issue
	UAGithubIssueCommentsRequest,					// Get more than one non-specific issue comment
	UAGithubIssueCommentRequest,					// Get exactly one specific issue comment
	UAGithubIssueCommentAddRequest,					// Add a comment to an issue
    UAGithubIssueCommentEditRequest,                // Edit an issue comment
    UAGithubIssueCommentDeleteRequest,              // Delete an issue comment
    UAGithubFollowingRequest,                       // Following
    UAGithubFollowersRequest,                       // Followers
    UAGithubFollowRequest,                          // Follow a User
    UAGithubUnfollowRequest,                        // Unfollow a user
    UAGithubMilestonesRequest,                      // Get one or more milestones
    UAGithubMilestoneRequest,                       // Get exactly one specific milestone
    UAGithubMilestoneCreateRequest,                 // Create a new milestone
    UAGithubMilestoneUpdateRequest,                 // Edit an existing milestone
    UAGithubMilestoneDeleteRequest,                 // Delete a milestone
    UAGithubPublicKeysRequest,                      // Get one or more public keys
    UAGithubPublicKeyRequest,                       // Get exactly one public key
    UAGithubPublicKeyAddRequest,                    // Add a public key
    UAGithubPublicKeyEditRequest,                   // Edit a public key
    UAGithubPublicKeyDeleteRequest,                 // Delete a public key
	UAGithubTreeRequest,							// Get the listing of a tree by SHA
    UAGithubTreeCreateRequest,                      // Create a new tree
	UAGithubBlobsRequest,							// Get the names and SHAs of all blobs for a specific tree SHA
	UAGithubBlobRequest,							// Get data about a single blob by tree SHA and path
    UAGithubBlobCreateRequest,                      // Create a new blob
	UAGithubRawBlobRequest,							// Get the raw data for a blob
    UAGithubReferencesRequest,                      // Get one or more references
    UAGithubReferenceRequest,                       // Get exactly one reference
    UAGithubReferenceCreateRequest,                 // Create a new reference
    UAGithubReferenceUpdateRequest,                 // Edit an existing reference
    UAGithubTagObjectRequest,                       // Get exactly one annotated tag object
    UAGithubTagObjectCreateRequest,                 // Create a new annotated tag object
    UAGithubRawCommitRequest,                       // Get exactly one raw commit
    UAGithubRawCommitCreateRequest,                 // Create a new raw commit
    UAGithubGistsRequest,                           // Get one or more gists
    UAGithubGistRequest,                            // Get exactly one gist
    UAGithubGistCreateRequest,                      // Create a new gist
    UAGithubGistUpdateRequest,                      // Edit a gist
    UAGithubGistStarRequest,                        // Star a gist
    UAGithubGistUnstarRequest,                      // Unstar a gist
    UAGithubGistStarStatusRequest,                  // Get star status of a gist
    UAGithubGistForkRequest,                        // Fork a gist
    UAGithubGistDeleteRequest,                      // Delete a gist
    UAGithubGistCommentsRequest,                    // Get one or more gist comments
    UAGithubGistCommentRequest,                     // Get exactly one gist comment
    UAGithubGistCommentCreateRequest,               // Create a new gist comment
    UAGithubGistCommentUpdateRequest,               // Edit a gist comment
    UAGithubGistCommentDeleteRequest,               // Delete a gist comment
    UAGithubIssueEventsRequest,                     // Get one or more issue events
    UAGithubIssueEventRequest,                           // Get exactly one issue event
    UAGithubPullRequestsRequest,                    // Get one or more pull requests
    UAGithubPullRequestRequest,                     // Get exactly one pull request
    UAGithubPullRequestCreateRequest,               // Create a pull request
    UAGithubPullRequestUpdateRequest,               // Edit a pull request
    UAGithubPullRequestCommitsRequest,              // Get commits in a pull request
    UAGithubPullRequestFilesRequest,                // Get files in a pull request
    UAGithubPullRequestMergeStatusRequest,          // Get the merge status of a pull request
    UAGithubPullRequestMergeRequest,                // Merge a pull request
    UAGithubPullRequestCommentsRequest,             // Get one or more pull request comments
    UAGithubPullRequestCommentRequest,              // Get exactly one pull request comments
    UAGithubPullRequestCommentCreateRequest,        // Create a pull request comment
    UAGithubPullRequestCommentUpdateRequest,        // Update a pull request comment
    UAGithubPullRequestCommentDeleteRequest,        // Delete a pull request comment
    UAGithubEventsRequest,                          // Get one or more events of unspecified type
    UAGithubOrganizationsRequest,                   // Get one or more organizations
    UAGithubOrganizationRequest,                    // Get exactly one organization
    UAGithubOrganizationUpdateRequest,              // Update an existing organization
    UAGithubOrganizationMembersRequest,             // Get one or more organization members
    UAGithubOrganizationMembershipStatusRequest,    // Get whether user is member of a specified organization
    UAGithubOrganizationMemberRemoveRequest,        // Remove a user from am organization
    UAGithubOrganizationMembershipPublicizeRequest, // Publicize user's membership of organization
    UAGithubOrganizationMembershipConcealRequest,   // Concel user's membership of organization
    UAGithubTeamsRequest,                           // Get one or more organization teams
    UAGithubTeamRequest,                            // Get exactly one organization team
    UAGithubTeamCreateRequest,                      // Create a new team
    UAGithubTeamUpdateRequest,                      // Update an existing team
    UAGithubTeamDeleteRequest,                      // Delete an existing team
    UAGithubTeamMembersRequest,                     // Get one or more team members
    UAGithubTeamMembershipStatusRequest,
    UAGithubTeamMemberAddRequest,
    UAGithubTeamMemberRemoveRequest,                // Remove a user from a team
    UAGithubTeamRepositoryManagershipStatusRequest, // Get whether a team manages a specific repository
    UAGithubTeamRepositoryManagershipAddRequest,    // Add a specific repository to a team
    UAGithubTeamRepositoryManagershipRemoveRequest, // Remove a specific repository from a team

                                                    // Notifications
    UAGithubNotificationListRequest,                // List your notifications
    UAGithubNotificationListForRepositoryRequest,   // List your notifications in a repository
    UAGithubNotificationMarkReadRequest,            // Mark as read
    UAGithubNotificationMarkReadForRepositoryRequest, // Mark notifications as read in a repository
    UAGithubNotificationThreadGetSubscriptionRequest, // Get a Thread Subscription
    UAGithubNotificationThreadSetSubscriptionRequest,  // Set a Thread Subscription
    UAgithubNotificationThreadDeleteSubscriptionRequest,  // Delete a Thread Subscription

} UAGithubRequestType;


typedef enum UAGithubResponseType 
{
    UAGithubNoContentResponse = 0,                  // No content expected
	UAGithubUsersResponse,                          // One or more users
	UAGithubUserResponse,							// Exactly one user
    UAGithubEmailsResponse,                         // One or more email addresses
	UAGithubRepositoriesResponse,					// One or more repositories 
	UAGithubRepositoryResponse,						// Exactly one repository
    UAGithubRepositoryTeamsResponse,                // One or more teams
    UAGithubDeployKeysResponse,                     // One or more deploy keys
    UAGithubDeployKeyResponse,                      // Exactly one deploy key
    UAGithubDownloadsResponse,                      // One or more downloads
    UAGithubDownloadResponse,                       // Exactly one download
	UAGithubRepositoryLanguageBreakdownResponse,	// Breakdown in language-bytes pairs
	UAGithubBranchesResponse,						// One or more branches
	UAGithubCollaboratorsResponse,					// One or more users
    UAGithubRepositoryHooksResponse,                // One or more repository hooks
    UAGithubRepositoryHookResponse,                 // Exactly one repository hook
	UAGithubCommitsResponse,						// One or more commits
	UAGithubCommitResponse,							// Exactly one commit
    UAGithubCommitCommentsResponse,                 // One or more commit comments
    UAGithubCommitCommentResponse,                  // Exactly one commit comment
	UAGithubIssuesResponse,							// One or more issues
	UAGithubIssueResponse,							// Exactly one issue
	UAGithubIssueCommentsResponse,					// One or more issue comments
	UAGithubIssueCommentResponse,					// Exactly one issue comment
	UAGithubIssueLabelsResponse,					// One or more issue labels
    UAGithubIssueLabelResponse,                     // Exactly one issue label
	UAGithubRepositoryLabelsResponse,				// One or more repository-wide issue labels
    UAGithubRepositoryLabelResponse,                // Exactly one repository-wide issue label
	UAGithubBlobsResponse,							// Name and SHA for all files in given tree SHA
	UAGithubBlobResponse,							// Metadata and file data for given tree SHA and path 
    UAGithubFollowingResponse,                      // Following
    UAGithubFollowersResponse,                      // Followers  
    UAGithubFollowedResponse,                       // User was followed
    UAGithubUnfollowedResponse,                     // User was unfollowed
    UAGithubMilestonesResponse,                     // One or more milestones
    UAGithubMilestoneResponse,                      // Exactly one milestone
    UAGithubPublicKeysResponse,                     // One or more public keys
    UAGithubPublicKeyResponse,                      // Exactly one public key
    UAGithubSHAResponse,                            // SHA
	UAGithubTreeResponse,							// Metadata for all files in given commit
    UAGithubReferencesResponse,                     // One or more references
    UAGithubReferenceResponse,                      // Exactly one reference
    UAGithubAnnotatedTagsResponse,                  // One or more annotated tag objects
    UAGithubAnnotatedTagResponse,                   // Exactly one annotated tag object
    UAGithubRawCommitResponse,                      // Exactly one raw commit
    UAGithubGistsResponse,                          // One or more gists
    UAGithubGistResponse,                           // Exactly one gist
    UAGithubGistCommentsResponse,                   // One or more gist comments
    UAGithubGistCommentResponse,                    // Exactly one gist comment
    UAGithubIssueEventsResponse,                    // One or more issue events
    UAGithubIssueEventResponse,                     // Exactly one issue event
    UAGithubPullRequestsResponse,                   // One or more pull requests
    UAGithubPullRequestResponse,                    // Exactly one pull request
    UAGithubPullRequestMergeSuccessStatusResponse,  // Success or failure of merge attempt
    UAGithubPullRequestCommitsResponse,             // One or more pull request commits
    UAGithubPullRequestFilesResponse,               // One or more pull request files
    UAGithubPullRequestCommentsResponse,            // One or more pull request comments
    UAGithubPullRequestCommentResponse,             // Exactly one pull request comment
    UAGithubTagsResponse,							// Tags in name-SHA pairs
    UAGithubEventsResponse,                         // One or more events of unspecified type
    UAGithubOrganizationsResponse,                  // One or more organizations
    UAGithubOrganizationResponse,                   // Exactly one organization
    UAGithubTeamsResponse,                          // One or more organization teams
    UAGithubTeamResponse,                           // Exactly one team
    UAGithubNotificationResponse,                   // For notifications
} UAGithubResponseType;
