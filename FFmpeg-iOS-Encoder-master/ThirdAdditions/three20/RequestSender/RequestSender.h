//
//  RequestSender.h
//  BanckleRemoteHD

//  Copyright 2010 weipaike Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RequestSender : NSObject 
{
    NSString *url;
    NSArray *keys;
    NSArray *values;
    id deletage;
    id selectorArgument;
    SEL completeSelector;
    SEL errorSelector;
    BOOL usePost;
    
    NSMutableData *_data;

}

@property (nonatomic) int responseState;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id selectorArgument;
@property (nonatomic) SEL completeSelector;
@property (nonatomic) SEL errorSelector;
@property (nonatomic) BOOL usePost;
@property (nonatomic)NSURLRequestCachePolicy cachePolicy;


+ (id)requestSenderWithURL:(NSString *)theUrl
                   usePost:(BOOL)isPost
                      keys:(NSArray *)theKeys 
                    values:(NSArray *)theValues 
                  cachePolicy:(NSURLRequestCachePolicy)cholicy
                  delegate:(id)theDelegate 
          completeSelector:(SEL)theCompleteSelector 
             errorSelector:(SEL)theErrorSelector
          selectorArgument:(id)theSelectorArgument;

- (void)send;

@end
