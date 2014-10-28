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
#import "TDPreferencesWindowController.h"


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
    self.window.title = @"Tumblr";
    [[self.window standardWindowButton:NSWindowCloseButton] setEnabled:NO];
//    [self.window setStyleMask:NSResizableWindowMask];
    [self.window setBackgroundColor:[NSColor whiteColor]];
//    [self.window setOpaque:NO];
    
//    [self.window setMovableByWindowBackground:YES];
//    [self.window setIgnoresMouseEvents:NO];
    
    [NOTIF_CENTER addObserver:self
                     selector:NSSelectorFromString(@"initImageView")
                         name:NOTIF_UPDATE_PREFERENCES
                       object:nil];

    [self initImageView];
    
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass
                            andEventID:kAEGetURL];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
//    TDPreferencesWindowController *preferenceController = [TDPreferencesWindowController sharedTDPreferencesWindowController];
//    [preferenceController close];
}


- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *calledURL = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [[TDTumblrManager sharedInstance] handleEvent:calledURL];
}


#pragma mark -

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
//    NSRect rect = [sender.contentView frame];
//    tdImageView_.frame = rect;
    
    return frameSize;
}


- (void)windowDidResize:(NSNotification *)notification
{
    tdImageView_.frame = [self.window.contentView frame];
}



#pragma mark -

- (void)initImageView
{
    if ([USER_DEFAULT integerForKey:UD_IS_ALWAYS_TOP] == 1) {
        // 常に最前面に置く NSFloatingWindowLevel
        [self.window setLevel:NSFloatingWindowLevel];
    }
    else{
        // 普通 NSNormalWindowLevel
        [self.window setLevel:NSNormalWindowLevel];
    }
    
    if (tdImageView_) {
        [tdImageView_ removeFromSuperview];
    }
        
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager authenticate:^(bool succeeded) {
        if (succeeded) {
            // 成功
            NSRect rect = [self.window.contentView frame];
            //            rect.origin.x = rect.origin.y = 0.0f;
            NSLog(@"rect %@",NSStringFromRect(rect));
            NSLog(@"rect %@",NSStringFromRect(self.window.frame));
            tdImageView_ = [[TDImageView alloc] initWithFrame:rect];
            [tdImageView_ setWantsLayer:YES];
            
            [self.window.contentView addSubview:tdImageView_];
        }
        else{
            // 失敗
            NSAlert *alert = [NSAlert alertWithMessageText:@"認証に失敗しました"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"既にログインしている可能性があるためブラウザからTumbrを開いて一度ログアウトしてからお試しください。"];
            
            [alert beginSheetModalForWindow:self.window
                               modalDelegate:self
                              didEndSelector:NSSelectorFromString(@"alertDidEnd:returnCode:contextInfo:")
                                 contextInfo:nil];
        }
    }];
}


- (void)setTitleWithBlogName:(NSString *)name state:(BOOL)isLoadingFinished
{
    if (isLoadingFinished) {
        self.window.title = [NSString stringWithFormat:@"✓ %@",name];
    }
    else{
        self.window.title = [NSString stringWithFormat:@"... %@",name];
    }
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"%d",returnCode);
    if (returnCode == 1) {
        [self initImageView];
    }
}

#pragma mark -

- (IBAction)showPreferences:(id)sender {
    NSLog(@"showPreferences");
    
    TDPreferencesWindowController *preferenceController = [TDPreferencesWindowController sharedTDPreferencesWindowController];
    [preferenceController showWindow:sender];
}
@end
