//
//  TDPostModel.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/23.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDPostModel.h"

#import "TDTumblrManager.h"
#import "NSImageView+WebCache.h"
#import "OTWebImageDownloadRequest.h"


#define DEFAULT_IMAGE_CONTAINER_SIZE 5
#define DEFAULT_PRE_LOAD_IMAGE_COUNT 4

@interface TDPostModel () <OTWebImageDownloadRequestDelegate>{
 
    NSMutableArray *imageUrlContainer_;
    
    NSMutableArray *requestContainer_;
}
@end

@implementation TDPostModel
@synthesize posts = posts_;


- (id)init
{
    self = [super init];
    if (self) {
        
        posts_ = [NSMutableArray array];
        imageUrlContainer_ = [NSMutableArray array];
        requestContainer_ = [NSMutableArray array];
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
                              [self createImageUrlContainer];
                              
                              // 1リクエストで50件までしか取得できないので追加取得を裏側で行う
                              [self addRequestposts];
                          }
                      }];
}


- (void)addRequestposts
{
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager requestWithOffset:[NSString stringWithFormat:@"%lu",(unsigned long)[posts_ count]]
                      callback:^(id response, bool succeeded) {
                          if (succeeded) {
                              NSArray *arr = response;
                              if ([arr count] != 0) {
                                  posts_ = [posts_ arrayByAddingObjectsFromArray:arr];
                                  // 取得件数が0じゃない限り再帰呼び出し
                                  [self addRequestposts];
                              }
                              else{
                                  NSLog(@"finished.");
                              }
                          }
                          else{
                              NSLog(@"error");
                          }
                      }];
}

- (void)preLoadImage:(NSString *)urlString
{
    OTWebImageDownloadRequest *req = [OTWebImageDownloadRequest requestWithURL:[NSURL URLWithString:urlString]];
    req.delegate = self;
    [requestContainer_ addObject:req];
    [req start];
}



#pragma mark -

- (void)createImageUrlContainer
{
    for (int i = 0; i < DEFAULT_IMAGE_CONTAINER_SIZE; i++) {
        NSString *url = [self getRandomImageUrl];
        if (i < DEFAULT_PRE_LOAD_IMAGE_COUNT) {
            // 先読み込み
            [self preLoadImage:url];
        }
        [imageUrlContainer_ addObject:url];
    }
    
}

- (NSString *)getNextImageUrl
{
    NSString *url = @"";
    if ([imageUrlContainer_ count] != 0) {
        url = [imageUrlContainer_ objectAtIndex:0];
        [imageUrlContainer_ removeObjectAtIndex:0];
        [imageUrlContainer_ addObject:[self getRandomImageUrl]];
        
        {
            // 先読み込み
            NSString *preLoadUrl = [imageUrlContainer_ objectAtIndex:DEFAULT_PRE_LOAD_IMAGE_COUNT];
            [self preLoadImage:preLoadUrl];
        }
    }
    
    return url;
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


#pragma mark - OTWebImageDownloadRequest Delegate

- (void)otWebImageDownloadRequest:(OTWebImageDownloadRequest *)request
        downloadSuccessedWithData:(NSData *)imageData
                      isFromCache:(BOOL)isFromCache
{
    [requestContainer_ removeObject:request];
}


- (void)otWebImageDownloadRequest:(OTWebImageDownloadRequest *)request
                  failedWithError:(NSError *)error
{
    [requestContainer_ removeObject:request];
}

@end
