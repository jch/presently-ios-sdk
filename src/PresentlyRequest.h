/*
 *  PresentlyRequest.h
 *  presently-ios-sdk
 *
 *  Created by Sean Soper on 9/14/10.
 *  Copyright 2010 Intridea. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PresentlyRequestDelegate;

@interface PresentlyRequest : NSObject {
  id<PresentlyRequestDelegate> _delegate;
  NSString*             _url;
  NSString*             _httpMethod;
  NSMutableDictionary*  _params;
  NSMutableDictionary*  _headers;
  NSURLConnection*      _connection;
  NSMutableData*        _responseText;
}

@property(nonatomic,assign) id<PresentlyRequestDelegate> delegate;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *httpMethod;
@property(nonatomic,assign) NSMutableDictionary *params;
@property(nonatomic,assign) NSMutableDictionary *headers;
@property(nonatomic,assign) NSURLConnection *connection;
@property(nonatomic,assign) NSMutableData *responseText;
                        
+ (PresentlyRequest*)getRequestWithParams:(NSMutableDictionary *) params
                        httpMethod:(NSString *) httpMethod
                          delegate:(id<PresentlyRequestDelegate>)delegate
                        requestURL:(NSString *) url
                           headers:(NSMutableDictionary *) headers;
- (BOOL) loading;
- (void) connect;
- (id) formError:(NSInteger)code userInfo:(NSDictionary *) errorData;
- (void)failWithError:(NSError*)error;

@end

@protocol PresentlyRequestDelegate <NSObject>

@optional

- (void)requestLoading:(PresentlyRequest*)request;
- (void)request:(PresentlyRequest*)request didReceiveResponse:(NSURLResponse*)response;
- (void)request:(PresentlyRequest*)request didFailWithError:(NSError*)error;
- (void)request:(PresentlyRequest*)request didLoad:(id)result;
- (void)request:(PresentlyRequest*)request didLoadRawResponse:(NSData*)data;

@end
