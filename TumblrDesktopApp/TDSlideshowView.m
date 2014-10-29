//
//  TDSlideshowView.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/29.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDSlideshowView.h"

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#import "TDPostModel.h"
#import "NSImageView+WebCache.h"



@interface TDSlideshowView (){
 
    TDPostModel *postModel_;
    
    float interval_;
    NSTimer *changeImageTimer_;
    
    NSImageView *activeImageView_;
}
@end

@implementation TDSlideshowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        postModel_ = [[TDPostModel alloc] init];
        [self createAnimate];
        
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
//        [activeImageView_ setImageURL:[NSURL URLWithString:url]];
        [self replaseImageView:url];
    }
}


#pragma mark - Animate

- (void)replaseImageView:(NSString *)newUrlString
{
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:[self bounds]];
    [imageView setImageURL:[NSURL URLWithString:newUrlString]];
    [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    
    [[self animator] replaceSubview:activeImageView_ with:imageView];
    
    activeImageView_ = imageView;
}


- (void)createAnimate
{
    NSString *transition = @"fade";
    CIFilter	*transitionFilter = nil;
    transitionFilter = [CIFilter filterWithName:transition];
    [transitionFilter setDefaults];
    
    CATransition *newTransition = [CATransition animation];
    if (transitionFilter)
	{
        // we want to build a CIFilter-based CATransition.
		// When an CATransition's "filter" property is set, the CATransition's "type" and "subtype" properties are ignored,
		// so we don't need to bother setting them.
        [newTransition setFilter:transitionFilter];
    }
	else
	{
        // we want to specify one of Core Animation's built-in transitions.
        [newTransition setType:transition];
        [newTransition setSubtype:kCATransitionFromLeft];
    }
    
    [newTransition setDuration:0.5f];
    
	[self setAnimations:[NSDictionary dictionaryWithObject:newTransition forKey:@"subviews"]];
    
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
