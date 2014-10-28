//
//  TDTumblrManager.h
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTumblrManager : NSObject

+ (TDTumblrManager *)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;

- (void)handleEvent:(NSString *)url;


- (void)authenticate:(void (^)(bool succeeded))callback;
- (void)requestWithBlogName:(NSString *)name
                     offset:(NSString *)offset
                   callback:(void (^)(id blogInfo, id postsList, NSError *error))callback;

@end
