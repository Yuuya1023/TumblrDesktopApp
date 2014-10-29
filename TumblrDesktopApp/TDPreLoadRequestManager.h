//
//  TDPreLoadRequestManager.h
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/29.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPreLoadRequestManager : NSObject

+ (TDPreLoadRequestManager *)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;

- (void)addRequest:(NSString *)url;
- (void)cancelExistRequest;

@end
