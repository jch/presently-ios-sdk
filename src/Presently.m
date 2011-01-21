/*
 *  Presently.m
 *  presently-ios-sdk
 *
 *  Created by Sean Soper on 9/14/10.
 *  Copyright 2010 Intridea. All rights reserved.
 *
 */

#import "Presently.h"
//#import "PresentlyRequest.h"

static NSString *kProtocol   = @"https";
static NSString *kBaseUrl    = @"presently.com";
static NSString *kBasePath   = @"api/twitter";
static NSString *kSDKVersion = @"ios";
static NSString *kFormat     = @"json";

@interface Presently ()
@property (nonatomic, assign) int loginState;
@property (nonatomic, retain) NSString *username, *password, *organization;
@property (nonatomic, assign) id<PresentlySessionDelegate> sessionDelegate;
@end

@implementation Presently

@synthesize loginState, username, password, organization, sessionDelegate;

- (id) init {
  if (self = [super init]) {
    self.loginState = StateLoggedOut;
  }

  return self;
}

#pragma mark -
#pragma mark Private

- (void) openUrl:(NSString *)url 
          params:(NSMutableDictionary *)params 
      httpMethod:(NSString *)httpMethod 
        delegate:(id<PresentlyRequestDelegate>)delegate { 

  
  NSString *authorizationString;
  authorizationString = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
  authorizationString = [[authorizationString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];

  NSMutableDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:authorizationString, @"Authorization", nil];
  [params setValue:kSDKVersion forKey:@"sdk"];

//  [request release];

  NSLog(@"[Presently] URL: %@", url);
  NSLog(@"[Presently] Parameters: %@", params);
  NSLog(@"[Presently] Headers: %@", headers);

  request = [PresentlyRequest getRequestWithParams:params
                                   httpMethod:httpMethod
                                     delegate:delegate
                                   requestURL:url
                                      headers:headers];
  
  [request connect];
}

- (NSString *) constructUrl {
  return [NSString stringWithFormat: @"%@://%@.%@/%@",
          kProtocol,
          self.organization,
          kBaseUrl,
          kBasePath];
}

- (BOOL) validParams:(NSMutableDictionary *) params
                 key:(NSString *) key
               error:(NSError **) error {
  if (!CFDictionaryContainsKey((CFDictionaryRef)params, key)) {
    *error = [request formError: PresentlyErrorInvalidParams userInfo: nil];
    return NO;
  }

  return YES;
}

#pragma mark -
#pragma mark Public

- (void) login:(NSString*) _username
      password:(NSString*) _password
  organization:(NSString*) _organization
      delegate:(id<PresentlySessionDelegate>) delegate {

  if (self.loginState != StateLoggedOut) {
    if (delegate && [delegate respondsToSelector:@selector(presentlyDidNotLogin:)]) {
      [delegate presentlyDidNotLogin: NO];
    }
  }

  self.username = _username;
  self.password = _password;
  self.organization = _organization;
  self.sessionDelegate = delegate;
  self.loginState = StateLoggingIn;

  if ([_username length] < 4 ||
      [_password length] < 4 ||
      [_organization length] < 4) {

    if (delegate && [delegate respondsToSelector:@selector(presentlyDidNotLogin:)]) {
      [delegate presentlyDidNotLogin: NO];
    }

    return;
  }

  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: _username, @"id", nil];
  [self requestWithMethod: PresentlyProfile params: params delegate: self];
}

- (BOOL) requestWithMethod:(int) methodId
                    params:(NSMutableDictionary *) params
                  delegate:(id<PresentlyRequestDelegate>) delegate {

  NSString *httpMethod = @"GET";
  NSError *error = nil;
  NSString *url;

  if (params == nil) {
    params = [NSMutableDictionary dictionary];
  }
  
  switch (methodId) {
    case PresentlyPostUpdate:
      httpMethod = @"POST";
      url = [NSString stringWithFormat: @"%@/statuses/update.%@", [self constructUrl], kFormat];
      break;

    case PresentlyUserFeed:
      url = [NSString stringWithFormat: @"%@/statuses/friends_timeline.%@", [self constructUrl], kFormat];      
      break;

    case PresentlyReplies:
      if (![self validParams: params key: @"for_user" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/replies.%@", [self constructUrl], kFormat];
      break;

    case PresentlySearch:
      if (![self validParams: params key: @"query" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/search.%@", [self constructUrl], kFormat];
      break;

    case PresentlyProfile:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/entities/show/%@.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    case PresentlyUserUpdates:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/user_timeline.%@", [self constructUrl], kFormat];
      break;

    case PresentlyDirectMessages:
      url = [NSString stringWithFormat: @"%@/direct_messages.%@", [self constructUrl], kFormat];      
      break;

    case PresentlyGroupUpdates:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/group_timeline.%@", [self constructUrl], kFormat];
      break;

    case PresentlyFollowing:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/friends.%@", [self constructUrl], kFormat];
      break;

    case PresentlyFollowers:
      if (![self validParams: params key: @"for_user" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/statuses/followers.%@", [self constructUrl], kFormat];
      break;

    case PresentlyGroupMembers:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/groups/show/%@/members.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    case PresentlyUserGroups:
      if (![self validParams: params key: @"for_user" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/groups.%@", [self constructUrl], kFormat];
      break;

    case PresentlyJoinGroup:
      if (![self validParams: params key: @"id" error: &error])
        break;
      
      url = [NSString stringWithFormat: @"%@/groups/join/%@.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    case PresentlyLeaveGroup:
      if (![self validParams: params key: @"id" error: &error])
        break;
      
      url = [NSString stringWithFormat: @"%@/groups/leave/%@.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    case PresentlyTags:
      url = [NSString stringWithFormat: @"%@/tags.%@", [self constructUrl], kFormat];      
      break;

    case PresentlyTagUpdates:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/tags/show/%@.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    case PresentlyStreams:
      url = [NSString stringWithFormat: @"%@/custom_streams.%@", [self constructUrl], kFormat];      
      break;

    case PresentlyStreamUpdates:
      if (![self validParams: params key: @"id" error: &error])
        break;

      url = [NSString stringWithFormat: @"%@/custom_streams/show/%@/statuses.%@", [self constructUrl], [params objectForKey: @"id"], kFormat];
      [params removeObjectForKey: @"id"];
      break;

    default:
      break;
  }  

  if (self.loginState == StateLoggedOut)
    error = [request formError: PresentlyErrorNotLoggedIn userInfo: nil];

  if (error == nil)
    [self openUrl: url params: params httpMethod: httpMethod delegate: delegate];
  else
    [request failWithError: error];

  return (error == nil);
}     

- (void)logout:(id<PresentlySessionDelegate>)delegate {

  self.sessionDelegate = delegate;
  self.loginState = StateLoggedOut;

  NSString *url = [NSString stringWithFormat: @"%@://%@.%@", kProtocol, self.organization, kBaseUrl];

  NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSArray* presentlyCookies = [cookies cookiesForURL: [NSURL URLWithString: url]];

  for (NSHTTPCookie* cookie in presentlyCookies) {
    [cookies deleteCookie:cookie];
  }

  if ([self.sessionDelegate respondsToSelector:@selector(presentlyDidLogout)]) {
    [self.sessionDelegate presentlyDidLogout];
  }
}

- (BOOL) loggedIn {
  return (self.loginState == StateLoggedIn);
}

- (void)dealloc {
  [request release];
  [username release];
  [password release];
  [organization release];

  [super dealloc];
}

#pragma mark -
#pragma mark PresentlyRequestDelegate

- (void)request:(PresentlyRequest*)request didFailWithError:(NSError*)error{
  if (self.loginState == StateLoggingIn) {
    self.loginState = StateLoggedOut;

    // TODO: make 'cancelled' arg on delegate valid by hooking up to cancelled button

    if ([self.sessionDelegate respondsToSelector:@selector(presentlyDidNotLogin:)]) {
      [self.sessionDelegate presentlyDidNotLogin:true];
    }
  }
}

- (void)request:(PresentlyRequest*)request didLoad:(id)result {
  if (self.loginState == StateLoggingIn) {
    self.loginState = StateLoggedIn;

    if ([self.sessionDelegate respondsToSelector:@selector(presentlyDidLogin)]) {
      [self.sessionDelegate presentlyDidLogin];
    }
  }

}
                
@end
