/*
 *  PresentlyRequest.m
 *  presently-ios-sdk
 *
 *  Created by Sean Soper on 9/14/10.
 *  Copyright 2010 Intridea. All rights reserved.
 *
 */

#import "PresentlyRequest.h"
#import "JSONKit.h"


static NSString* kUserAgent = @"PresentlyConnect";
static NSString* kStringBoundary = @"20006iNtriDea4EvaiNtRideA4LiFe102016thDC";
static const int kGeneralErrorCode = 10000;

static const NSTimeInterval kTimeoutInterval = 180.0;

@implementation PresentlyRequest

@synthesize delegate     = _delegate,
            url          = _url,
            httpMethod   = _httpMethod,
            params       = _params,
            connection   = _connection,
            responseText = _responseText;

+ (PresentlyRequest *)getRequestWithParams:(NSMutableDictionary *) params
                                httpMethod:(NSString *) httpMethod
                                  delegate:(id<PresentlyRequestDelegate>) delegate
                                requestURL:(NSString *) url {

  PresentlyRequest* request = [[[PresentlyRequest alloc] init] autorelease];

  request.delegate      = delegate; 
  request.url           = [url retain];
  request.httpMethod    = [httpMethod retain];
  request.params        = [params retain];
  request.connection    = nil;
  request.responseText  = nil;

  return request;
}

#pragma mark -
#pragma mark Private

- (NSString*)generateGetURL {
  NSURL* parsedURL = [NSURL URLWithString: self.url];
  NSString* queryPrefix = parsedURL.query ? @"&" : @"?";

  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [_params keyEnumerator]) {
    if (([[_params valueForKey:key] isKindOfClass:[UIImage class]]) 
        ||([[_params valueForKey:key] isKindOfClass:[NSData class]])) {
      if ([_httpMethod isEqualToString:@"GET"]) {
        NSLog(@"[Presently] Can not use GET to upload a file");      
      }
      continue;
    } 

    NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                NULL, /* allocator */
                                (CFStringRef)[_params objectForKey:key],
                                NULL, /* charactersToLeaveUnescaped */
                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                kCFStringEncodingUTF8);

    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    [escaped_value release];
  }
  NSString* params = [pairs componentsJoinedByString:@"&"];
  
  return [NSString stringWithFormat:@"%@%@%@", self.url, queryPrefix, params];
}

- (void)utfAppendBody:(NSMutableData*)body data:(NSString*)data {
  [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)generatePostBody {
  NSMutableData *body = [NSMutableData data];
  NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
  NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];

  [self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];

  for (id key in [_params keyEnumerator]) {

    if (([[_params valueForKey:key] isKindOfClass:[UIImage class]]) 
      ||([[_params valueForKey:key] isKindOfClass:[NSData class]])) {

      [dataDictionary setObject:[_params valueForKey:key] forKey:key];
      continue;      
    }

    [self utfAppendBody:body
                  data:[NSString 
                        stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", 
                        key]];
    [self utfAppendBody:body data:[_params valueForKey:key]];

    [self utfAppendBody:body data:endLine];   
  }

  if ([dataDictionary count] > 0) {
    for (id key in dataDictionary) {
      NSObject *dataParam = [dataDictionary valueForKey:key];
      if ([dataParam isKindOfClass:[UIImage class]]) {
        NSData* imageData = UIImagePNGRepresentation((UIImage*)dataParam);
        [self utfAppendBody:body
                       data:[NSString stringWithFormat:
                             @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
        [self utfAppendBody:body
                       data:[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"]];
        [body appendData:imageData];
      } else {
        NSAssert([dataParam isKindOfClass:[NSData class]], 
                 @"dataParam must be a UIImage or NSData");
        [self utfAppendBody:body
                       data:[NSString stringWithFormat:
                             @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
        [self utfAppendBody:body
                       data:[NSString stringWithString:@"Content-Type: content/unknown\r\n\r\n"]];
        [body appendData:(NSData*)dataParam];
      }
      [self utfAppendBody:body data:endLine];          
    }
  }

  return body;
}

- (id) formError:(NSInteger)code userInfo:(NSDictionary *) errorData {
  return [NSError errorWithDomain:@"presentlyErrDomain" code:code userInfo:errorData];  
}

- (id)parseJsonResponse:(NSData*)data error:(NSError**)error { 
  JSONDecoder *decoder = [JSONDecoder decoder];
  id result = [decoder parseJSONData: data error: error];

  return result;
}

- (void)failWithError:(NSError*)error {
  if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
    [_delegate request:self didFailWithError:error];
  }
}

- (void)handleResponseData:(NSData*)data {
  if ([_delegate respondsToSelector:@selector(request:didLoadRawResponse:)]) {
    [_delegate request:self didLoadRawResponse:data];
  }
  
  if ([_delegate respondsToSelector:@selector(request:didLoad:)] ||
      [_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
    NSError* error = nil;
    id result = [self parseJsonResponse:data error:&error];
    if (error) {
      [self failWithError:error];
    } else if ([_delegate respondsToSelector:@selector(request:didLoad:)]) {
      [_delegate request:self didLoad:(result == nil ? data : result)];
    }
      
  }
  
}

#pragma mark -
#pragma mark Public

- (BOOL)loading {
  return !!_connection;
}

- (void)connect {
  
  if ([_delegate respondsToSelector:@selector(requestLoading:)]) {
    [_delegate requestLoading:self];
  }
  
  NSString* tmpUrl = [self generateGetURL];
  NSMutableURLRequest* request = 
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString: tmpUrl]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                        timeoutInterval:kTimeoutInterval];
  [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];

  [request setHTTPMethod:self.httpMethod];
  if ([self.httpMethod isEqualToString: @"POST"]) {  
    NSString* contentType = [NSString
                             stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [request setHTTPBody:[self generatePostBody]];
  }

  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
}

- (void)dealloc {
  [_connection cancel];
  [_connection release];
  [_responseText release];
  [self.url release];
  [_httpMethod release];
  [_params release];
  [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
  _responseText = [[NSMutableData alloc] init];

  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
  if ([_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {    
    [_delegate request:self didReceiveResponse:httpResponse];
  }
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseText appendData:data];
}

- (NSCachedURLResponse*)connection:(NSURLConnection*)connection
    willCacheResponse:(NSCachedURLResponse*)cachedResponse {
  return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
  [self handleResponseData:_responseText];
  
  [_responseText release];
  _responseText = nil;
  [_connection release];
  _connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {  
  [self failWithError:error];

  [_responseText release];
  _responseText = nil;
  [_connection release];
  _connection = nil;
}

@end
