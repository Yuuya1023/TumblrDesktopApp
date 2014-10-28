//
//  TDImageView.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDImageView.h"

#import "TDPostModel.h"
#import "NSImageView+WebCache.h"



@interface TDImageView (){

    TDPostModel *postModel_;
    
    float interval_;
    NSTimer *changeImageTimer_;
}
@end

@implementation TDImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        postModel_ = [[TDPostModel alloc] init];
        
        interval_ = [[USER_DEFAULT objectForKey:UD_DISPLAY_INTERVAL] floatValue];
        
        {
            NSString *url = [postModel_ getNextImageUrl];
            if (url && [url length] != 0) {
                [self initTimer];
                [self setImageScaling:NSImageScaleProportionallyUpOrDown];
                [self setImageURL:[NSURL URLWithString:url]];
            }
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)removeFromSuperview{
    [super removeFromSuperview];
    [changeImageTimer_ fire];
    [changeImageTimer_ invalidate];
    [postModel_ setShouldCancelPostsRequest:YES];
}


#pragma mark -

- (void)initTimer
{
    changeImageTimer_ = [NSTimer scheduledTimerWithTimeInterval:interval_
                                                         target:self
                                                       selector:NSSelectorFromString(@"changeImage")
                                                       userInfo:nil
                                                        repeats:YES];
}


- (void)changeImage
{
    NSString *url = [postModel_ getNextImageUrl];
//    NSLog(@"url -> %@",url);
    if (url) {
        [self setImageURL:[NSURL URLWithString:url]];
    }
}



#pragma mark -

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"click!");
    NSLog(@"%@",[postModel_ currentPostDetail]);
    NSString *url = [[postModel_ currentPostDetail] objectForKey:@"post_url"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];

}

@end
