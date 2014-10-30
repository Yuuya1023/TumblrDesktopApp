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
#import "TumblrDesktopAppDelegate.h"
#import "TDPreLoadRequestManager.h"
#import "TDHistoryWindowController.h"



#define DEFAULT_IMAGE_CONTAINER_SIZE 5
#define DEFAULT_PRE_LOAD_IMAGE_COUNT 4

#define KEY_IMAGE_URL @"image_url"
#define KEY_POST_URL  @"post_url"

@interface TDPostModel (){
 
    /// 先読みする投稿を貯めておく用
    NSMutableArray *postDetailContainer_;
    /// ランダム表示で被りが出ないように貯めておく用
    NSMutableArray *restPostContainerForRandom_;
    
    NSString *currentBlogName_;
    NSUInteger receivePostsCount_;
    NSUInteger retryCount_;
    NSUInteger currentPostIndex_;
    BOOL isRandomIndicate_;
    BOOL isFinishedLoad_;
    
    BOOL shouldCancelPostsRequest_;
}
@end

@implementation TDPostModel
@synthesize posts = posts_;
//@synthesize shouldCancelPostsRequest = shouldCancelPostsRequest_;
@synthesize currentPostDetail = currentPostDetail_;


- (id)init
{
    self = [super init];
    if (self) {
        
        receivePostsCount_ = 0;
        retryCount_ = 0;
        shouldCancelPostsRequest_ = NO;
        currentPostIndex_ = 0;
        isRandomIndicate_ = [[USER_DEFAULT objectForKey:UD_IS_RANDOM_INDICATE] boolValue];
        isFinishedLoad_ = NO;
        
        posts_ = [NSMutableArray array];
        postDetailContainer_ = [NSMutableArray array];
//        requestContainer_ = [NSMutableArray array];
        restPostContainerForRandom_ = [NSMutableArray array];
        
        
        TumblrDesktopAppDelegate *app = (TumblrDesktopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        currentBlogName_ = [USER_DEFAULT objectForKey:UD_BLOG_NAME];
        if (currentBlogName_ && [currentBlogName_ length] != 0) {
            NSArray *cacheData = [USER_DEFAULT objectForKey:currentBlogName_];
            
            if (cacheData) {
                // キャッシュ
                [app setTitleWithBlogName:currentBlogName_ state:YES];
                posts_ = cacheData;
                
                // ランダム表示用
                if (isRandomIndicate_) {
                    restPostContainerForRandom_ = [NSMutableArray arrayWithArray:posts_];
                }
                isFinishedLoad_ = YES;
                
                [self createImageUrlContainer];
            }
            else{
                [app setTitleWithBlogName:currentBlogName_ state:NO];
                [self requestPosts];
            }
        }
        else{
            NSError *error = [[NSError alloc] initWithDomain:@"ブログ名が指定されていません"
                                                        code:-1
                                                    userInfo:nil];
            [self showError:error];
        }

    }
    return self;
}


#pragma mark -

- (void)requestPosts
{
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager requestWithBlogName:currentBlogName_
                          offset:@"0"
                        callback:^(id blogInfo, id postsList, NSError *error) {
                            if (!error) {
                                receivePostsCount_ = [postsList count];
                                NSArray *arr = [self processResponseData:postsList];
                                posts_ = [posts_ arrayByAddingObjectsFromArray:arr];
                                [self createImageUrlContainer];
                                
                                // 1リクエストで50件までしか取得できないので追加取得を裏側で行う
                                [self addRequestposts];
                            }
                            else{
//                                NSLog(@"error %@",error);
                                [self showError:error];
//                                [self requestPosts];
                            }
                        }];
}


- (void)addRequestposts
{
    if (shouldCancelPostsRequest_) {
        return;
    }
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager requestWithBlogName:currentBlogName_
                          offset:[NSString stringWithFormat:@"%lu",(unsigned long)receivePostsCount_]
                        callback:^(id blogInfo, id postsList, NSError *error) {
                            if (!error) {
                                retryCount_ = 0;
                                NSArray *arr = [self processResponseData:postsList];
                                NSUInteger postsCount = [arr count];
                                receivePostsCount_ += postsCount;
                                if (postsCount != 0) {
                                    posts_ = [posts_ arrayByAddingObjectsFromArray:arr];
                                    // 取得件数が0じゃない限り再帰呼び出し
                                    [self addRequestposts];
                                }
                                else{
                                    // 全て読み込み完了
                                    NSLog(@"%@",blogInfo);
                                    NSLog(@"%lu posts finished.",(unsigned long)receivePostsCount_);
                                    NSLog(@"%lu images finished.",(unsigned long)[posts_ count]);
                                    NSString *blogName = [blogInfo objectForKey:@"name"];
                                    // ブログ名をキーにポスト一覧を保存
                                    [USER_DEFAULT setObject:posts_ forKey:blogName];
                                    // キャッシュされたブログ名をリストに保存
                                    NSArray *temp = [USER_DEFAULT objectForKey:UD_CACHED_BLOG_NAME];
                                    if (!temp) {
                                        temp = [NSArray array];
                                    }
                                    NSMutableArray *cachedList = [temp mutableCopy];
                                    [cachedList addObject:blogName];
                                    [USER_DEFAULT setObject:cachedList forKey:UD_CACHED_BLOG_NAME];
                                    
                                    [USER_DEFAULT synchronize];
                                    
                                    // ランダム表示用
                                    if (isRandomIndicate_) {
                                        restPostContainerForRandom_ = [NSMutableArray arrayWithArray:posts_];
                                    }
                                    isFinishedLoad_ = YES;
                                    
                                    // 読み込み完了したのでタイトルを変える
                                    TumblrDesktopAppDelegate *app = (TumblrDesktopAppDelegate *)[[NSApplication sharedApplication] delegate];
                                    [app setTitleWithBlogName:currentBlogName_ state:YES];
                                }
                                
                            }
                            else{
                                NSLog(@"error");
                                if (retryCount_ > 4) {
                                    [self showError:error];
                                }
                                else{
                                    retryCount_++;
                                    [self addRequestposts];
                                }
                            }
                        }];
}

- (void)cancelRequest
{
    shouldCancelPostsRequest_ = YES;
    [[TDPreLoadRequestManager sharedInstance] cancelExistRequest];
}


- (void)showError:(NSError *)error
{
    NSLog(@"error - >%@",error);
    NSAlert *alert = [NSAlert alertWithMessageText:error.domain
                                     defaultButton:@"設定"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@",error.localizedDescription];
    
    TumblrDesktopAppDelegate *app = (TumblrDesktopAppDelegate *)[[NSApplication sharedApplication] delegate];
    [alert beginSheetModalForWindow:app.window
                      modalDelegate:self
                     didEndSelector:NSSelectorFromString(@"alertDidEnd:returnCode:contextInfo:")
                        contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    TumblrDesktopAppDelegate *app = (TumblrDesktopAppDelegate *)[[NSApplication sharedApplication] delegate];
    [app showPreferences:nil];
}


- (void)preLoadImage:(NSString *)urlString
{
    [[TDPreLoadRequestManager sharedInstance] addRequest:urlString];
}



#pragma mark -

- (NSArray *)processResponseData:(NSArray *)responseData
{
    NSMutableArray *ret = [NSMutableArray array];
    NSInteger count = [responseData count];
    for (NSInteger i = 0; i < count; i++) {
        NSDictionary *detail = [responseData objectAtIndex:i];
        NSString *post_url = [detail objectForKey:@"post_url"];
        NSArray *photos = [detail objectForKey:@"photos"];
        
        NSUInteger photosCount = [photos count];
        for (NSUInteger j = 0; j < photosCount; j++) {
            NSDictionary *photo = [photos objectAtIndex:j];
            NSDictionary *original_size = [photo objectForKey:@"original_size"];
            NSDictionary *image_url = [original_size objectForKey:@"url"];
            
            NSDictionary *dic = @{KEY_POST_URL: post_url,
                                  KEY_IMAGE_URL: image_url};
            [ret addObject:dic];
            
        }
    }
    return ret;
}

- (void)createImageUrlContainer
{
    for (int i = 0; i < DEFAULT_IMAGE_CONTAINER_SIZE; i++) {
//        NSString *url = [self getRandomImageUrl];
        NSDictionary *dic = [self getNextPost];
        if (i < DEFAULT_PRE_LOAD_IMAGE_COUNT) {
            // 先読み込み
            [self preLoadImage:[dic objectForKey:KEY_IMAGE_URL]];
        }
        [postDetailContainer_ addObject:dic];
    }
    
}

- (NSString *)getNextImageUrl
{
    NSString *url = @"";
    if ([postDetailContainer_ count] != 0) {
        NSDictionary *dic = [postDetailContainer_ objectAtIndex:0];
        url = [dic objectForKey:KEY_IMAGE_URL];
        [postDetailContainer_ removeObjectAtIndex:0];
        [postDetailContainer_ addObject:[self getNextPost]];
        
        {
            // 先読み込み
            NSDictionary *dic = [postDetailContainer_ objectAtIndex:DEFAULT_PRE_LOAD_IMAGE_COUNT];
            NSString *preLoadUrl = [dic objectForKey:KEY_IMAGE_URL];
            [self preLoadImage:preLoadUrl];
        }
        
        // 履歴に追加
        TDHistoryWindowController *controller = [TDHistoryWindowController sharedTDHistoryWindowControllerController];
        [controller pushHistory:currentPostDetail_];
        // 差し替え
        currentPostDetail_ = [NSDictionary dictionaryWithDictionary:dic];
    }
    return url;
}


- (NSDictionary *)getNextPost
{
    if ([[USER_DEFAULT objectForKey:UD_IS_RANDOM_INDICATE] integerValue]) {
        return [self getRandomPost];
    }
    else{
        NSDictionary *dic = [NSDictionary dictionary];
        if (currentPostIndex_ >= [posts_ count]) {
            currentPostIndex_ = 0;
        }
        dic = [posts_ objectAtIndex:currentPostIndex_];
        currentPostIndex_++;
        
        return dic;
    }
}


- (NSDictionary *)getRandomPost
{
    NSDictionary *dic = [NSDictionary dictionary];
    if ([posts_ count] != 0) {
        if (isFinishedLoad_) {
            // 一周するまで被らないようにする処理
            if ([restPostContainerForRandom_ count] == 0) {
                restPostContainerForRandom_ = [NSMutableArray arrayWithArray:posts_];
            }
            NSUInteger randomIndex = arc4random() % [restPostContainerForRandom_ count];
            dic = [restPostContainerForRandom_ objectAtIndex:randomIndex];
            [restPostContainerForRandom_ removeObjectAtIndex:randomIndex];
            
            NSLog(@"%lu",(unsigned long)[restPostContainerForRandom_ count]);
        }
        else{
            NSUInteger randomIndex = arc4random() % [posts_ count];
            dic = [posts_ objectAtIndex:randomIndex];
        }
    }
    return dic;
}


@end
