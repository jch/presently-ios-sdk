/*
 *  Presently.h
 *  presently-ios-sdk
 *
 *  Created by Sean Soper on 9/14/10.
 *  Copyright 2010 Intridea. All rights reserved.
 *
 */

#import "PresentlyRequest.h"

@protocol PresentlySessionDelegate;

typedef enum PresentlyApi {
  PresentlyPostUpdate,
  PresentlyUserFeed,
  PresentlyReplies,
  PresentlySearch,
  PresentlyProfile,
  PresentlyUserUpdates,
  PresentlyDirectMessages,
  PresentlyGroupUpdates,
  PresentlyFollowing,
  PresentlyFollowers,
  PresentlyGroupMembers,
  PresentlyUserGroups,
  PresentlyJoinGroup,
  PresentlyLeaveGroup,
  PresentlyTags,
  PresentlyTagUpdates,
  PresentlyStreams,
  PresentlyStreamUpdates
} PresentlyApi;

typedef enum PresentlyErrors {
  PresentlyErrorInvalidParams,
  PresentlyErrorNotLoggedIn
} PresentlyErrors;

typedef enum PresentlyLogin {
  StateLoggedOut,
  StateLoggingIn,
  StateLoggedIn
} PresentlyLogin;

@interface Presently: NSObject<PresentlyRequestDelegate>{
  int loginState;
  NSString *username, *password, *organization;
  id<PresentlySessionDelegate> sessionDelegate;
  PresentlyRequest* request;
}

@property (nonatomic, assign, readonly) int loginState;
@property (nonatomic, retain, readonly) NSString *username, *password, *organization;
@property (nonatomic, assign, readonly) id<PresentlySessionDelegate> sessionDelegate;

- (void) login:(NSString*) _username
      password:(NSString*) _password
  organization:(NSString*) _organization
      delegate:(id<PresentlySessionDelegate>) delegate;

- (BOOL) requestWithMethod:(int) methodId
                    params:(NSMutableDictionary *) params
                  delegate:(id<PresentlyRequestDelegate>) delegate;

- (void) logout:(id<PresentlySessionDelegate>) delegate;

- (BOOL) loggedIn;

@end

@protocol PresentlySessionDelegate <NSObject>

@optional

- (void)presentlyDidLogin;
- (void)presentlyDidNotLogin:(BOOL)cancelled;
- (void)presentlyDidLogout;

@end
