//
//  TDHistoryWindowController.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/30.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDHistoryWindowController.h"

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#import "NSImageView+WebCache.h"



@interface TDHistoryWindowController (){

    NSMutableArray *historyList_;
    NSMutableArray *imageViewContainer_;
    
    float displaySize_;
    NSUInteger displayCount_;
}
@end

@implementation TDHistoryWindowController

+ (TDHistoryWindowController *)sharedTDHistoryWindowControllerController
{
    static TDHistoryWindowController *sharedController = nil;
    if(sharedController == nil) {
        sharedController = [[TDHistoryWindowController alloc] init];
    }
    return sharedController;
}

- (id)init
{
    self = [super initWithWindowNibName:@"TDHistoryWindowController"];
    if (self) {
        // Initialization code here.
        self.window.title = @"History";
        displayCount_ = 3;
        displaySize_ = 150.0f;
        historyList_ = [NSMutableArray array];
        imageViewContainer_ = [NSMutableArray array];
        
//        [self setAnimate];
        
        
        [self.window setContentSize:NSMakeSize(displaySize_, displaySize_ * displayCount_)];
        
        for (NSUInteger i = 0; i < displayCount_; i++) {
            NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, displaySize_ * i, displaySize_, displaySize_)];
            [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
            
            [imageViewContainer_ addObject:imageView];
            [self.window.contentView addSubview:imageView];
        }
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    NSLog(@"show");
}


- (void)close
{
    [super close];
    NSLog(@"close");
}


#pragma mark -

- (void)pushHistory:(NSDictionary *)postDetail
{
    if (!postDetail)  return;
    
    [historyList_ addObject:postDetail];
    if ([historyList_ count] > displayCount_) {
        [historyList_ removeObjectAtIndex:0];
    }
    
//    if ([self.window isVisible]) {
//        // 表示更新
//        
//    }
    
    for (NSUInteger i = [historyList_ count]; i > 0; i--) {
        NSImageView *oldImageView = [imageViewContainer_ objectAtIndex:displayCount_ - i];
        NSDictionary *post_detail = [historyList_ objectAtIndex:[historyList_ count] - i];
        NSString *image_url = [post_detail objectForKey:@"image_url"];
        NSString *post_url = [post_detail objectForKey:@"post_url"];
        
//        NSImageView *newImageView = [[NSImageView alloc] initWithFrame:oldImageView.frame];
        
//        [[self.window.contentView animator] replaceSubview:oldImageView with:newImageView];
        [oldImageView setImageURL:[NSURL URLWithString:image_url]];
        [oldImageView setIdentifier:post_url];
        
//        [imageViewContainer_ replaceObjectAtIndex:i withObject:newImageView];
    }
}


//- (void)setAnimate
//{
//    NSString *transition = @"fade";
//    CIFilter	*transitionFilter = nil;
//    transitionFilter = [CIFilter filterWithName:transition];
//    [transitionFilter setDefaults];
//    
//    CATransition *newTransition = [CATransition animation];
//    if (transitionFilter)
//	{
//        // we want to build a CIFilter-based CATransition.
//		// When an CATransition's "filter" property is set, the CATransition's "type" and "subtype" properties are ignored,
//		// so we don't need to bother setting them.
//        [newTransition setFilter:transitionFilter];
//    }
//	else
//	{
//        // we want to specify one of Core Animation's built-in transitions.
//        [newTransition setType:transition];
//        [newTransition setSubtype:kCATransitionFromLeft];
//    }
//    
//    [newTransition setDuration:0.5f];
//    
//	[self.window.contentView setAnimations:[NSDictionary dictionaryWithObject:newTransition forKey:@"subviews"]];
//    
//}


- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"click! %@",NSStringFromPoint(theEvent.locationInWindow));
    NSUInteger index = theEvent.locationInWindow.y / displaySize_;
    NSLog(@"%lu", (unsigned long)index);
    
    NSImageView *imageView = [imageViewContainer_ objectAtIndex:index];
    NSString *post_url = imageView.identifier;
    if (post_url && [post_url length] != 0) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:post_url]];
    }
}

@end
