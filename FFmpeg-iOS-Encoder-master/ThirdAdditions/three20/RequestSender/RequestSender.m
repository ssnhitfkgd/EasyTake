//
//  RequestSender.m
//  BanckleRemoteHD
//
//  Created by Kyle on 10-9-7.
//  Copyright 2010 weipaike Ltd. All rights reserved.
//

#import "RequestSender.h"
#import "NSString+SBJSON.h"

static const float TIME_OUT_INTERVAL = 30.0f;

@implementation RequestSender

@synthesize url;
@synthesize usePost;
@synthesize keys;
@synthesize values;
@synthesize delegate;
@synthesize completeSelector;
@synthesize errorSelector;
@synthesize selectorArgument;
@synthesize responseState;
@synthesize cachePolicy;


+ (id)requestSenderWithURL:(NSString *)theUrl
                   usePost:(BOOL)isPost
                      keys:(NSArray *)theKeys 
                    values:(NSArray *)theValues 
                  cachePolicy:(NSURLRequestCachePolicy)cholicy
                  delegate:(id)theDelegate 
          completeSelector:(SEL)theCompleteSelector 
             errorSelector:(SEL)theErrorSelector
          selectorArgument:(id)theSelectorArgument
{
    RequestSender *requestSender = [[[RequestSender alloc] init] autorelease];
    requestSender.url = theUrl;
    requestSender.usePost = isPost;
    requestSender.keys = theKeys;
    requestSender.values = theValues;
    requestSender.delegate = theDelegate;
    requestSender.completeSelector = theCompleteSelector;
    requestSender.errorSelector = theErrorSelector;
    requestSender.selectorArgument = theSelectorArgument;
    requestSender.cachePolicy = cholicy;
    return requestSender;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.url = nil;
        self.usePost = NO;
        self.keys = nil;
        self.values = nil;
        self.delegate = nil;
        self.completeSelector = nil;
        self.errorSelector = nil;
        self.selectorArgument = nil;
        self.cachePolicy = 0;
        responseState = 0;
        _data = [[NSMutableData alloc] initWithLength:0];
    }
    
    return self;
}

- (void)dealloc
{
    [_data release];
    [delegate release];
    [values release];
    [keys release];
    [selectorArgument release];
    [url release];
    [super dealloc];
}

- (void)send
{

    NSMutableString *completeUrl = [[NSMutableString alloc] init];
    
   // BOOL firstValue = YES;
    int parameterNum = [keys count] < [values count] ? [keys count] : [values count];
    NSMutableString *queryStr = [[NSMutableString alloc] init];
    
    if (usePost)
    {
        NSArray * parts = [self.url componentsSeparatedByString:@"?op="];
        [queryStr appendFormat:@"&%@=%@", @"op", [parts objectAtIndex:1]];
        [completeUrl setString:[parts objectAtIndex:0]];
        
    }
    else
    {
        [completeUrl setString:self.url];
    }
    
    for (int i = 0; i < parameterNum; ++i)
    {
//        if (firstValue && !self.usePost)
//        {
//            [queryStr appendString:@"?"];
//            firstValue = NO;
//        }
//        else
//        {
//            [queryStr appendString:@"&"];
//        }
        
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [values objectAtIndex:i];
        
        if (self.selectorArgument == nil) {
            
        NSString *encodedValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)value, 
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                     kCFStringEncodingUTF8);
        [queryStr appendFormat:@"&%@=%@", key, encodedValue];
        
        [encodedValue release];
        }
        else {
            [queryStr appendFormat:@"&%@=%@", key, value];
        }
        
    }
    
    if (!usePost)
    {
        [completeUrl appendString:queryStr];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:completeUrl]
                                                           cachePolicy:self.cachePolicy//NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:TIME_OUT_INTERVAL];
    
    if (usePost)
    {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    //request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [queryStr release];
    [completeUrl release];
    [self retain];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection)
    {
        [self release];
        [self.delegate performSelector:self.errorSelector];
    }
}


- (void)uploadFile
{
    NSMutableString *completeUrl = [[NSMutableString alloc] initWithString:self.url];
    
    BOOL firstValue = YES;
    int parameterNum = [keys count] < [values count] ? [keys count] : [values count];
    NSMutableString *queryStr = [[NSMutableString alloc] init];
    for (int i = 0; i < parameterNum; ++i)
    {
        if (firstValue && !self.usePost)
        {
            [queryStr appendString:@"?"];
            firstValue = NO;
        }
        else
        {
            [queryStr appendString:@"&"];
        }
        
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [values objectAtIndex:i];
        NSString *encodedValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)value, 
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                     kCFStringEncodingUTF8);
        [queryStr appendFormat:@"%@=%@", key, encodedValue];
        
        
        //NSLog(@"key=%@\nvalue=%@",key,value);
        [encodedValue release];
        
    }
    
    if (!usePost)
    {
        [completeUrl appendString:queryStr];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:completeUrl]
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData/*NSURLRequestReloadRevalidatingCacheData*/
                                                       timeoutInterval:TIME_OUT_INTERVAL];

    if (usePost)
    {
        [request setHTTPMethod:@"POST"];
       
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    //NSLog(@"Request URL: %@", completeUrl);
    
    [queryStr release];
    [completeUrl release];
    [self retain];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection)
    {
        [self release];
        [self.delegate performSelector:self.errorSelector];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse)//&& [httpResponse respondsToSelector:@selector(allHeaderFields)]){
    {
        //NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        responseState = httpResponse.statusCode;
    }
    [_data setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [_data appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    [connection release];
    if (self.selectorArgument == nil)
    {
        [self.delegate performSelector:self.errorSelector];
    }
    else 
    {
        [self.delegate performSelector:self.errorSelector withObject:self.selectorArgument];
    }
    
    [_data setLength:0];
    
    [self release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [connection release];
    if (self.selectorArgument == nil)
    {
        NSString *json_string = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        
        if([json_string rangeOfString:@"java.lang.NullPointerException"].location != NSNotFound)
        {
            return;
        }
        
        if(json_string.length > 0)
        {
            id responseObject = [[json_string JSONValue] objectForKey:@"errno"] ;
            
            if(responseObject)
            {
                if([responseObject intValue] == -31)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"logOff" object:nil];
                    return;
                }
            }
        }
        [self.delegate performSelector:self.completeSelector withObject:_data];

    }
    else 
    {
        [self.delegate performSelector:self.completeSelector withObject:_data withObject:nil];
    }
    
    [_data setLength:0];
    
    [self release];
}


@end
