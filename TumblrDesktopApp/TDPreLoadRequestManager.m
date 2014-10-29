//
//  TDPreLoadRequestManager.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/29.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDPreLoadRequestManager.h"

#import "OTWebImageDownloadRequest.h"



@interface TDPreLoadRequestManager () < OTWebImageDownloadRequestDelegate >{
 
    NSMutableArray *requestContainer_;
}
@end

@implementation TDPreLoadRequestManager

static TDPreLoadRequestManager* sharedTDPreLoadRequestManager = nil;



#pragma mark - Singleton

+ (TDPreLoadRequestManager *)sharedInstance
{
	@synchronized(self) {
		if (sharedTDPreLoadRequestManager == nil) {
			sharedTDPreLoadRequestManager = [[self alloc] init];
		}
	}
	return sharedTDPreLoadRequestManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedTDPreLoadRequestManager == nil) {
			sharedTDPreLoadRequestManager = [super allocWithZone:zone];
			return sharedTDPreLoadRequestManager;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}



#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        requestContainer_ = [NSMutableArray array];
        
        
    }
    return self;
}


#pragma mark -

- (void)addRequest:(NSString *)url
{
    if (!url || [url length] == 0) return;
    
    OTWebImageDownloadRequest *req = [OTWebImageDownloadRequest requestWithURL:[NSURL URLWithString:url]];
    req.delegate = self;
    [requestContainer_ addObject:req];
    
    [req start];
}


- (void)cancelExistRequest
{
    for (NSUInteger i = 0; i < [requestContainer_ count]; i++) {
        OTWebImageDownloadRequest *req = [requestContainer_ objectAtIndex:i];
        if (req) {
            req.delegate = nil;
            [requestContainer_ removeObject:req];
            [req cancel];
        }
    }
}


#pragma mark - OTWebImageDownloadRequest Delegate

- (void)otWebImageDownloadRequest:(OTWebImageDownloadRequest *)request
        downloadSuccessedWithData:(NSData *)imageData
                      isFromCache:(BOOL)isFromCache
{
    [requestContainer_ removeObject:request];
//    NSLog(@"%@", requestContainer_);
}


- (void)otWebImageDownloadRequest:(OTWebImageDownloadRequest *)request
                  failedWithError:(NSError *)error
{
    [requestContainer_ removeObject:request];
//    NSLog(@"%@", requestContainer_);
}

@end
