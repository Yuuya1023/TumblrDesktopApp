//
//  TDPostModel.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/23.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDPostModel.h"
#import "TDTumblrManager.h"


@implementation TDPostModel
@synthesize posts = posts_;


- (id)init
{
    self = [super init];
    if (self) {
        
        posts_ = [NSMutableArray array];
        [self requestPosts];

    }
    return self;
}


#pragma mark -

- (void)requestPosts
{
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager requestWithOffset:@"0"
                      callback:^(id response, bool succeeded) {
                          if (succeeded) {
                              NSArray *arr = response;
                              posts_ = [posts_ arrayByAddingObjectsFromArray:arr];
                          }
                      }];
    
}

- (NSString *)getRandomImageUrl
{
    NSString *url = @"";
    if ([posts_ count] != 0) {
        NSUInteger randomIndex = arc4random() % [posts_ count];
        NSDictionary *dic = [posts_ objectAtIndex:randomIndex];
        if (dic) {
            NSArray *photos = [dic objectForKey:@"photos"];
            NSDictionary *photo = [photos objectAtIndex:0];
            NSDictionary *original_size = [photo objectForKey:@"original_size"];
            url = [original_size objectForKey:@"url"];
        }
    }
    return url;
}

@end
