//
//  TumblrDesktopAppDelegate.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/22.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "TumblrDesktopAppDelegate.h"

#import "TDSlideshowView.h"
#import "TDTumblrManager.h"
#import "TDPreferencesWindowController.h"
#import "TDHistoryWindowController.h"



@interface TumblrDesktopAppDelegate(){
    
    TDSlideshowView *slideshowView_;
}
@end


@implementation TumblrDesktopAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [USER_DEFAULT registerDefaults:@{UD_DISPLAY_INTERVAL: @"10",
                                     UD_IS_ALWAYS_TOP: @"1",
                                     UD_IS_RANDOM_INDICATE: @"1"}];
    
    
    self.panelWindow.delegate = self;
    self.panelWindow.title = @"Tumblr";
    [[self.panelWindow standardWindowButton:NSWindowCloseButton] setEnabled:NO];
//    [self.panelWindow setStyleMask:NSResizableWindowMask];
    [self.panelWindow setBackgroundColor:[NSColor whiteColor]];
//    [self.panelWindow setOpaque:NO];
    
//    [self.panelWindow setMovableByWindowBackground:YES];
//    [self.panelWindow setIgnoresMouseEvents:NO];
    
    [NOTIF_CENTER addObserver:self
                     selector:NSSelectorFromString(@"initImageView")
                         name:NOTIF_UPDATE_PREFERENCES
                       object:nil];
    
    [self.showHistoryItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [self.showHistoryItem setKeyEquivalent:@"."];

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
    slideshowView_.frame = [self.panelWindow.contentView frame];
}



#pragma mark -

- (void)initImageView
{
    if ([USER_DEFAULT integerForKey:UD_IS_ALWAYS_TOP] == 1) {
        // 常に最前面に置く NSFloatingWindowLevel
        [self.panelWindow setLevel:NSFloatingWindowLevel];
    }
    else{
        // 普通 NSNormalWindowLevel
        [self.panelWindow setLevel:NSNormalWindowLevel];
    }
    
    if (slideshowView_) {
        [slideshowView_ removeFromSuperview];
    }
        
    TDTumblrManager *manager = [TDTumblrManager sharedInstance];
    [manager authenticate:^(bool succeeded) {
        if (succeeded) {
            // 成功
            NSRect rect = [self.panelWindow.contentView frame];
            //            rect.origin.x = rect.origin.y = 0.0f;
            NSLog(@"rect %@",NSStringFromRect(rect));
            NSLog(@"rect %@",NSStringFromRect(self.panelWindow.frame));
            slideshowView_ = [[TDSlideshowView alloc] initWithFrame:rect];
            [slideshowView_ setWantsLayer:YES];
            
            [self.panelWindow.contentView addSubview:slideshowView_];
            
        }
        else{
            // 失敗
            NSAlert *alert = [NSAlert alertWithMessageText:@"認証に失敗しました"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"既にログインしている可能性があるためブラウザからTumbrを開いて一度ログアウトしてからお試しください。"];
            
            [alert beginSheetModalForWindow:self.panelWindow
                               modalDelegate:self
                              didEndSelector:NSSelectorFromString(@"alertDidEnd:returnCode:contextInfo:")
                                 contextInfo:nil];
        }
    }];
}


- (void)setTitleWithBlogName:(NSString *)name state:(BOOL)isLoadingFinished
{
    if (isLoadingFinished) {
        self.panelWindow.title = [NSString stringWithFormat:@"✓ %@",name];
    }
    else{
        self.panelWindow.title = [NSString stringWithFormat:@"... %@",name];
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


- (void)showHistory:(id)sender
{
    
    TDHistoryWindowController *controller = [TDHistoryWindowController sharedTDHistoryWindowControllerController];
    if ([controller.window isVisible]) {
        [controller close];
    }
    else{
        [controller showWindow:sender];
    }
}


@end
