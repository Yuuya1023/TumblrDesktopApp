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



@interface TDSlideshowView () < NSImageViewWebCacheDelegate >{
 
    TDPostModel *postModel_;
    
    float interval_;
    NSTimer *changeImageTimer_;
    
//    NSView *parentView_;
    NSImageView *activeImageView_;
    
//    NSButton *prevButton_;
//    NSButton *nextButton_;
}
@end

@implementation TDSlideshowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//        parentView_ = [[NSView alloc] initWithFrame:frame];
//        [self addSubview:parentView_];
        [self setWantsLayer:YES];
        
        postModel_ = [[TDPostModel alloc] init];
        [self createAnimate];
        
        interval_ = [[USER_DEFAULT objectForKey:UD_DISPLAY_INTERVAL] floatValue];
        
        
        activeImageView_ = [[NSImageView alloc] initWithFrame:frame];
        activeImageView_.webCacheDelegate = self;
        [activeImageView_ setImageScaling:NSImageScaleProportionallyUpOrDown];
//        [parentView_ addSubview:activeImageView_];
        [self addSubview:activeImageView_];
        
        {
//            float buttonSize = 30.0f;
//            nextButton_ = [[NSButton alloc] initWithFrame:CGRectMake(frame.size.width - 40, 10, buttonSize, buttonSize)];
//            [nextButton_ setButtonType:NSRadioButton];
//            {
//                NSImage *image = [NSImage imageNamed:@"arrow.png"];
//                [image setSize:CGSizeMake(buttonSize, buttonSize)];
//                [nextButton_ setImage:image];
//            }
//            {
//                NSImage *image = [NSImage imageNamed:@"arrow.png"];
//                [image setSize:CGSizeMake(buttonSize, buttonSize)];
//                [nextButton_ setAlternateImage:image];
//            }
//            [nextButton_ setImagePosition:NSImageOnly];
//            [nextButton_ setBordered:NO];
//            
//            [self addSubview:nextButton_];
        }
        
        [self startSlideshow];
    }
    return self;
}


#pragma mark -

- (void)startSlideshow
{
    NSString *urlString = [postModel_ getNextImageUrl];
    if (urlString && [urlString length] != 0) {
        [activeImageView_ setImageURL:[NSURL URLWithString:urlString]];
    }
    else{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startSlideshow];
        });
    }
}

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
//    NSLog(@"\n\n\n\n url -> %@ \n\n\n\n\n",url);
    // gifの場合はアニメーションを有効に
    if ([url rangeOfString:@".gif"].location != NSNotFound) {
        [self setWantsLayer:NO];
    }
    else {
        [self setWantsLayer:YES];
    }
    
    if (url && [url length] != 0) {
        [self replaseImageView:url];
    }
}


- (void)setWantsLayer:(BOOL)flag
{
    [super setWantsLayer:flag];
//    [parentView_ setWantsLayer:flag];
}


#pragma mark - Animate

- (void)replaseImageView:(NSString *)newUrlString
{
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:[self bounds]];
    [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    
//    [[parentView_ animator] replaceSubview:activeImageView_ with:imageView];
    [[self animator] replaceSubview:activeImageView_ with:imageView];
    
    activeImageView_ = imageView;
    [activeImageView_ setImageURL:[NSURL URLWithString:newUrlString]];
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

- (void)imageView:(NSImageView *)imageView downloadImageSuccessed:(NSImage *)image data:(NSData *)data
{
    if (!changeImageTimer_) {
        [self initTimer];
    }
}

- (void)imageViewDownloadImageFailed:(NSImageView *)imageView
{
    if (!changeImageTimer_) {
        [self initTimer];
    }
}

#pragma mark -

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
//    [parentView_ setFrame:frameRect];
    [activeImageView_ setFrame:frameRect];
    
//    [nextButton_ setFrame:CGRectMake(frameRect.size.width - 40, 10, nextButton_.frame.size.width, nextButton_.frame.size.height)];
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
    activeImageView_.webCacheDelegate = nil;
    [activeImageView_ cancelWebImageLoad];
    [postModel_ cancelRequest];
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
