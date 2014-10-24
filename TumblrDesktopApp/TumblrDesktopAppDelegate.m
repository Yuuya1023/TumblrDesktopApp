//
//  TumblrDesktopAppDelegate.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "TumblrDesktopAppDelegate.h"
#import "TDImageView.h"
#import "TDTumblrManager.h"


@interface TumblrDesktopAppDelegate(){
    
    NSView *testView_;
    
    TDImageView *tdImageView_;
}
@end


@implementation TumblrDesktopAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.window.delegate = self;
    
    NSRect rect = [self.window.contentView frame];
//    rect.origin.x = 0.0f;
//    rect.origin.y = 0.0f;
    
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager authenticate:^(bool succeeded) {
        if (succeeded) {
            // 成功
            tdImageView_ = [[TDImageView alloc] initWithFrame:rect];
            [tdImageView_ setImageScaling:NSImageScaleProportionallyUpOrDown];
            [tdImageView_ setWantsLayer:YES];
            
//            tdImageView_.layer.backgroundColor = [[NSColor yellowColor] CGColor];
            [self.window.contentView addSubview:tdImageView_];
        }
        else{
            // 失敗
            
        }
    }];
    
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass
                            andEventID:kAEGetURL];
    
    
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *calledURL = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [[TDTumblrManager sharedInstance] handleEvent:calledURL];
}


#pragma mark -

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    NSRect rect = [sender.contentView frame];
//    rect.size = frameSize;
//    rect.origin.x = rect.origin.y = 0.0f;
    
    tdImageView_.frame = rect;
    
    
    return frameSize;
}

@end
