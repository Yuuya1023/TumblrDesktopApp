//
//  TDSlideshowView.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/29.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDSlideshowView.h"

#import "TDPostModel.h"
#import "NSImageView+WebCache.h"



@interface TDSlideshowView (){
 
    TDPostModel *postModel_;
    
    float interval_;
    NSTimer *changeImageTimer_;
    
    NSImageView *activeImageView_;
//    NSImageView *tempImageView_;
}
@end

@implementation TDSlideshowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        postModel_ = [[TDPostModel alloc] init];
        
        interval_ = [[USER_DEFAULT objectForKey:UD_DISPLAY_INTERVAL] floatValue];
        
        activeImageView_ = [[NSImageView alloc] initWithFrame:frame];
        [self addSubview:activeImageView_];
        {
            NSString *url = [postModel_ getNextImageUrl];
            if (url && [url length] != 0) {
                [self initTimer];
                [activeImageView_ setImageScaling:NSImageScaleProportionallyUpOrDown];
                [activeImageView_ setImageURL:[NSURL URLWithString:url]];
            }
        }
    }
    return self;
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
    if (url && [url length] != 0) {
        [activeImageView_ setImageURL:[NSURL URLWithString:url]];
    }
}



#pragma mark -

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [activeImageView_ setFrame:frameRect];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"click!");
    NSLog(@"%@",[postModel_ currentPostDetail]);
    NSString *url = [[postModel_ currentPostDetail] objectForKey:@"post_url"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    
}


- (void)removeFromSuperview{
    [super removeFromSuperview];
    [changeImageTimer_ fire];
    [changeImageTimer_ invalidate];
    [postModel_ setShouldCancelPostsRequest:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
