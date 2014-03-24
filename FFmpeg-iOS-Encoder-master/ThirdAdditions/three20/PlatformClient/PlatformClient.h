//
// Copyright (c) 2001-2011 Aspose Pty Ltd. All rights Reserved
//

//
//  PlatformClient.h
//  weipai
//
//  Created by wangyong on 10-11-16.
// 
//

#import <Foundation/Foundation.h>

#define PLATFORM_RESULT_UNDEFINED 0
#define PLATFORM_RESULT_SUCCESS 1
#define PLATFORM_RESULT_FAIL 2
#define PLATFORM_RESULT_NETWORK_FAILURE 3
#define PLATFORM_RESULT_USEALREADY 5


//@protocol AuthenticateProtocol
//- (void)didAuthenticatedWithResult:(int)resultCode;
//@end


@interface PlatformClient : NSObject 
{
    NSString *strUserId;
    int submibType;
}

@property (assign, nonatomic) id delegate;


+ (PlatformClient *)sharedInstance;


- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password 
                        nickname:(NSString *)nickname 
                        authType:(NSString *)authType 
                        portrait:(NSString *)ortraiturl 
                        delegate:(id)delegateParam
                        submibType:(int)submib;

//wanghonglin 增加网络注销
- (void)clientlogOutWithAccount:(NSString*)account token:(NSString*)token submibType:(int)submib;


- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password 
                diminutive:(NSString*)diminutive
                portritUrl:(NSString*)portritUrl
                  delegate:(id)delegate
                submibType:(int)submib;

- (void)sendLinktoEmail:(NSString *)emailAddr delegate:(id)delegate;
- (void)getUserBaseInfo:(NSString *)username delegate:(id)delegate;
@end
