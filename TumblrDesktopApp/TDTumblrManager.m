//
//  TDTumblrManager.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDTumblrManager.h"
#import "TMAPIClient.h"

#define CONSUMER_KEY @"MSXZzhmzeHu4x5rdGf4arkgoE0MzER4tkNmFJnIDM0JahFm7II"
#define CONSUMER_SECRET @"N9u35rSR6lztss5JcgOmQVq50JomAaf5QqgS86WTJ0wXVtaNo1"
#define URL_SCHEME @"TumblrDesktopApp"

#define UD_OAUTH_TOKEN @"OAUTH_TOKEN"
#define UD_OAUTH_TOKEN_SECRET @"OAUTH_TOKEN_SECRET"
@interface TDTumblrManager (){

    TMAPIClient *client_;
}
@end

@implementation TDTumblrManager

static TDTumblrManager* sharedTDTumblrManager = nil;

#pragma mark - Singleton

+ (TDTumblrManager *)sharedInstance
{
	@synchronized(self) {
		if (sharedTDTumblrManager == nil) {
			sharedTDTumblrManager = [[self alloc] init];
		}
	}
	return sharedTDTumblrManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedTDTumblrManager == nil) {
			sharedTDTumblrManager = [super allocWithZone:zone];
			return sharedTDTumblrManager;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}



#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        //
        client_ = [TMAPIClient sharedInstance];
        client_.OAuthConsumerKey = CONSUMER_KEY;
        client_.OAuthConsumerSecret = CONSUMER_SECRET;

    }
    return self;
}

#pragma mark -

- (void)handleEvent:(NSString *)url
{
    [[TMAPIClient sharedInstance] handleOpenURL:[NSURL URLWithString:url]];
}


#pragma mark -

- (void)authenticate:(void (^)(bool succeeded))callback
{
    NSString *token = [USER_DEFAULT objectForKey:UD_OAUTH_TOKEN];
    NSString *tokenSecret = [USER_DEFAULT objectForKey:UD_OAUTH_TOKEN_SECRET];
    if (token && tokenSecret) {
        [TMAPIClient sharedInstance].OAuthToken = token;
        [TMAPIClient sharedInstance].OAuthTokenSecret = tokenSecret;
        callback(YES);
        return;
    }
    
    [client_ authenticate:URL_SCHEME
                 callback:^(NSError *error) {
                     if (!error) {
                         NSLog(@"authenticated");
                         [USER_DEFAULT setObject:client_.OAuthToken forKey:UD_OAUTH_TOKEN];
                         [USER_DEFAULT setObject:client_.OAuthTokenSecret forKey:UD_OAUTH_TOKEN_SECRET];
                         [USER_DEFAULT synchronize];
                         callback(YES);
                     }
                     else{
                         NSLog(@"%@",error);
                         callback(NO);
                     }
                 }];
}


- (void)requestWithBlogName:(NSString *)name
                     offset:(NSString *)offset
                   callback:(void (^)(id blogInfo, id postsList, bool succeeded))callback
{
    [client_ posts:name
              type:@"photo"
        parameters:@{@"offset": offset,
                     @"limit": @"50",}
          callback:^(id results, NSError *error) {
              if (!error) {
                  NSLog(@"results: %@", [results description]);
                  
                  NSArray *blog = results[@"blog"];
                  NSArray *posts = results[@"posts"];
                  NSLog(@"count -> %lu",(unsigned long)[posts count]);
                  NSLog(@"posts -> %@",posts);
                  
                  callback(blog, posts, YES);
              }
              else{
                  NSLog(@"%@",error);
                  callback(nil, nil, NO);
              }
          }];
}

- (void)requestWithOffset:(NSString *)offset
                 callback:(void (^)(id blogInfo, id postsList, bool succeeded))callback
{
    [client_ posts:[USER_DEFAULT objectForKey:UD_BLOG_NAME]
              type:@"photo"
        parameters:@{@"offset": offset,
                     @"limit": @"50",}
          callback:^(id results, NSError *error) {
              if (!error) {
                  NSLog(@"results: %@", [results description]);
                  
                  NSArray *blog = results[@"blog"];
                  NSArray *posts = results[@"posts"];
                  NSLog(@"count -> %lu",(unsigned long)[posts count]);
                  NSLog(@"posts -> %@",posts);
                  
                  callback(blog, posts, YES);
              }
              else{
                  NSLog(@"%@",error);
                  callback(nil, nil, NO);
              }
          }];
    
}

@end
