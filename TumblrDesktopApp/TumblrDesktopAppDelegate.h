//
//  TumblrDesktopAppDelegate.h
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TumblrDesktopAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

- (void)initImageView;
- (IBAction)showPreferences:(id)sender;
- (IBAction)showHistory:(id)sender;
- (void)setTitleWithBlogName:(NSString *)name state:(BOOL)isLoadingFinished;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenuItem *showHistoryItem;

@end
