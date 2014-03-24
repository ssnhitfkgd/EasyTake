//
// Copyright (c) 2001-2011 weipaike Ltd. All rights Reserved
//
//
//  PlatformClient.m
//  
//
//  Created by wangyong on 10-11-16.
//  Copyright 2010 ... Ltd. All rights reserved.
//

#import "PlatformClient.h"
#import "RequestSender.h"
#import "ConfigManager.h"
#import "OAuthWeibo.h"
#import "User.h"
#import "FileClient.h"
#import "NSString+SBJSON.h"
#import "LoginViewController.h"

#import <CommonCrypto/CommonDigest.h> 

static PlatformClient *_sharedInstance = nil;
@interface PlatformClient() 

@end
@implementation PlatformClient
@synthesize delegate;


#pragma mark -
#pragma mark Singleton Restriction

+ (PlatformClient *)sharedInstance
{
    @synchronized(self)
    {
        if (_sharedInstance == nil)
            _sharedInstance = [[PlatformClient alloc] init];
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
    {
        if (_sharedInstance == nil) 
        {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;  // assignment and return on first allocation
        }
    }
    
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount 
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (id)autorelease 
{
    return self;
}

#pragma mark -
#pragma mark Common Methods

- (NSString*)getMD5StringFromData:(NSData*)inputData
{
    if(inputData == nil)
        return nil;
    
    CC_MD5_CTX md5;  
    CC_MD5_Init(&md5);  
    
    
    CC_MD5_Update(&md5, [inputData bytes], [inputData length]);  
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(digest, &md5);  
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",  
                   digest[0], digest[1],   
                   digest[2], digest[3],  
                   digest[4], digest[5],  
                   digest[6], digest[7],  
                   digest[8], digest[9],  
                   digest[10], digest[11],  
                   digest[12], digest[13],  
                   digest[14], digest[15]];  
    
    return s;  
}

- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password 
                        nickname:(NSString *)nickname 
                        authType:(NSString *)authType 
                        portrait:(NSString *)ortraiturl 
                        delegate:(id)delegateParam
                        submibType:(int)submib
{
    submibType = submib;
    self.delegate = delegateParam;
   
    NSArray *array = [NSArray arrayWithObjects:username,[self getMD5StringFromData:[password dataUsingEncoding:NSUTF8StringEncoding] ],nickname,ortraiturl,authType, nil];
    FileClient *client = [[[FileClient alloc] init] autorelease];
    [client loginIn:array cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData  delegate:self selector:@selector(requestDidFinishLoad:) selectorError:@selector(loginError)];
}

//wanghonglin 增加网络注销
- (void)logOutError
{
    
}
- (void)logOutFinish
{
    
}
- (void)clientlogOutWithAccount:(NSString*)account token:(NSString*)token submibType:(int)submib
{
    submibType = submib;
   
    if(account == nil || token == nil)
        return;
    
    NSArray *array = [NSArray arrayWithObjects:[User currentUser].userAccount,[User currentUser].token, nil];
    
    FileClient *client = [[FileClient alloc] init];
    [client logOut:array cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData delegate:self selector:@selector(logOutFinish) selectorError:@selector(logoutError)];
    
    [client release]; 
}

- (void)sendLinktoEmail:(NSString *)emailAddr  delegate:(id)delegate
{
    FileClient *client = [[[FileClient alloc] init] autorelease];
    [client sendLinktoEmail:emailAddr cachePolicy:NSURLRequestReloadIgnoringCacheData  delegate:nil selector:nil];
}

- (void)signUpWithUsername:(NSString *)username
                        password:(NSString *)password 
                        diminutive:(NSString*)diminutive
                        portritUrl:(NSString*)portritUrl
                        delegate:(id)_delegate
                        submibType:(int)submib
{
    
    NSString *encodedValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)portritUrl, 
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8);
   
    submibType = submib;
    self.delegate = _delegate;
    FileClient *client = [[[FileClient alloc] init] autorelease];
    [client registerInfo:encodedValue username:username password:[self getMD5StringFromData:[password dataUsingEncoding:NSUTF8StringEncoding]]  Nickname:diminutive cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData  delegate:self selector:@selector(requestDidFinishLoad:) selectorError:@selector(requestError)];
}

- (void)getUserBaseInfo:(NSString *)username
                  delegate:(id)_delegate
{
    self.delegate = _delegate;
    FileClient *client = [[[FileClient alloc] init] autorelease];
    [client getUserBaseInfo:@"0.6" UserName:username cachePolicy:NSURLRequestReloadIgnoringCacheData delegate:self selector:@selector(requestDidFinishLoad:) ];
}


- (void)requestDidFinishLoad:(NSData*)data
{
 
    if(data == nil)
    {
        if(self.delegate)
        [self.delegate didAuthenticatedWithResult:PLATFORM_RESULT_NETWORK_FAILURE];
        return;
    }
    
    NSString *theData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] synchronize];

    id obj = [theData JSONValue];
    NSString *error = [obj objectForKey:@"errno"];
    if(error)
    {
        if([error intValue] != 0)
        {
            
            if(-1 == [error intValue]||-36 == [error intValue])
            {
                if(self.delegate)
                [self.delegate didAuthenticatedWithResult:PLATFORM_RESULT_USEALREADY];
            }
            else {
                if(self.delegate)
                [self.delegate didAuthenticatedWithResult:submibType == 1?PLATFORM_RESULT_NETWORK_FAILURE:PLATFORM_RESULT_FAIL];
            }
            return;
        }
    }
    
    
    NSString *token = [obj objectForKey:@"Token"];
    if(!token)
    {
        if(self.delegate)
        [self.delegate didAuthenticatedWithResult:submibType == 1?PLATFORM_RESULT_NETWORK_FAILURE:PLATFORM_RESULT_FAIL];
        return;
    }
    
    
   
    NSArray *responseObject =  [obj objectForKey:@"result"];
    
    if(responseObject)
    {
        if([responseObject count] <= 0)
        {
            [self requestError];
            return;
        }

       
        User *user = [User userWithDictionary:[responseObject objectAtIndex:0]];
        [[responseObject objectAtIndex:0] setObject:token forKey:@"Token"];

        [User setCurrentUser:user];
        
        if ([[User currentUser].authType intValue] == 0) // 0 - sina weibo user
            [User currentUser].userAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"SinaWeiboAccount"];
        
        if([token length] > 0)
        {
            [User currentUser].token = token;
        }
         
        if(self.delegate)
        [self.delegate didAuthenticatedWithResult:PLATFORM_RESULT_SUCCESS];

    }

}
//
//- (void)release 
//{
//    _sharedInstance = nil;
//}


- (void)loginError
{
    if(self.delegate)
    [self.delegate didAuthenticatedWithResult:PLATFORM_RESULT_FAIL];
}

- (void)requestError{
    [self.delegate didAuthenticatedWithResult:PLATFORM_RESULT_NETWORK_FAILURE];
}
@end
