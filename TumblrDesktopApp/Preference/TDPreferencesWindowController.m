//
//  TDPreferencesWindowController.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/24.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDPreferencesWindowController.h"

#import "TDPreferenceWindow.h"



@interface TDPreferencesWindowController (){
 
}
@end

@implementation TDPreferencesWindowController

#define Singleton

+ (TDPreferencesWindowController *)sharedTDPreferencesWindowController
{
    static TDPreferencesWindowController *sharedController = nil;
    if(sharedController == nil) {
        sharedController = [[TDPreferencesWindowController alloc] init];
    }
    return sharedController;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.window = [[TDPreferenceWindow alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
