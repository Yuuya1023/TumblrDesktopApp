//
//  TDPostModel.h
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/23.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPostModel : NSObject

- (void)requestPosts;
- (NSString *)getRandomImageUrl;


@property (nonatomic, readonly) NSArray *posts;

@end
