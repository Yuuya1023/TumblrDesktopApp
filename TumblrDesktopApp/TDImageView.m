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
        
        {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSString *url = [postModel_ getNextImageUrl];
                NSLog(@"%@ -> ",url);
                if (url) {
                    [self initTimer];
                    [self setImageURL:[NSURL URLWithString:url]];
                }
            });
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



#pragma mark -

- (void)initTimer
{
    changeImageTimer_ = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                         target:self
                                                       selector:NSSelectorFromString(@"changeImage")
                                                       userInfo:nil
                                                        repeats:YES];
}


- (void)changeImage
{
    NSString *url = [postModel_ getNextImageUrl];
    NSLog(@"url -> %@",url);
    if (url) {
        [self setImageURL:[NSURL URLWithString:url]];
    }
}

@end
