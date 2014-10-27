//
//  TDPreferenceWindow.m
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/24.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import "TDPreferenceWindow.h"

#import "OTFileCacheManager.h"
#import "TumblrDesktopAppDelegate.h"



@interface TDPreferenceWindow ()<NSTextFieldDelegate, NSComboBoxDelegate> {

    NSTextField *blogNameField_;
    NSComboBox *displayIntervalBox_;
    NSButton *isAlwaysCheckBox_;
    
    NSString *blogName_;
    NSString *displayInterval_;
    BOOL isAlwaysTop_;
    
    NSAlert *alert_;
    BOOL isRemovedCache_;
}
@end

@implementation TDPreferenceWindow

- (id)init
{
    self = [super init];
    if (self) {
        //
//        self.contentView = [[NSView alloc] initWithFrame:NSMakeRect(100, 100, 300, 300)];
        self.title = @"Preferences";
        [self setFrame:NSMakeRect(0, 100, 220, 300) display:YES];
        isRemovedCache_ = NO;
        
        // ブログ名
        {
            NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f, self.frame.size.height - 52.0f, 100.0f, 20.0f)];
            text.stringValue = @"ブログ名：";
            [text setBezeled:NO];
            [text setDrawsBackground:NO];
            [text setEditable:NO];
            [text setSelectable:NO];
            [self.contentView addSubview:text];

            blogNameField_ = [[NSTextField alloc] initWithFrame:NSMakeRect(100.0f, self.frame.size.height - 50.0f, 100.0f, 20.0f)];
            blogNameField_.delegate = self;
            [self.contentView addSubview:blogNameField_];
        }
        
        // 表示切り替え間隔
        {
            NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f, self.frame.size.height - 82.0f, 130.0f, 20.0f)];
            text.stringValue = @"表示切り替え間隔(s)：";
            [text setBezeled:NO];
            [text setDrawsBackground:NO];
            [text setEditable:NO];
            [text setSelectable:NO];
            [self.contentView addSubview:text];

            displayIntervalBox_ = [[NSComboBox alloc] initWithFrame:NSMakeRect(153.0f, self.frame.size.height - 83.0f, 50.0f, 25.0f)];
            displayIntervalBox_.delegate = self;
//            displayIntervalBox_.completes = YES;
            [displayIntervalBox_ insertItemWithObjectValue:@"10" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ insertItemWithObjectValue:@"20" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ insertItemWithObjectValue:@"30" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ insertItemWithObjectValue:@"40" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ insertItemWithObjectValue:@"50" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ insertItemWithObjectValue:@"60" atIndex:[displayIntervalBox_ numberOfItems]];
            [displayIntervalBox_ selectItemAtIndex:2];
            [self.contentView addSubview:displayIntervalBox_];
        }
        
        // 優先表示設定
        {
            NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f, self.frame.size.height - 112.0f, 130.0f, 20.0f)];
            text.stringValue = @"常に最前面に配置：";
            [text setBezeled:NO];
            [text setDrawsBackground:NO];
            [text setEditable:NO];
            [text setSelectable:NO];
            [self.contentView addSubview:text];

            isAlwaysCheckBox_ = [[NSButton alloc] initWithFrame:NSMakeRect(183.0f, self.frame.size.height - 110.0f, 25.0f, 20.0f)];
            [isAlwaysCheckBox_ setButtonType:NSSwitchButton];
            isAlwaysCheckBox_.title = @"";
            isAlwaysCheckBox_.state = 0;
            [self.contentView addSubview:isAlwaysCheckBox_];
            
        }
        
        // キャッシュ削除
        {
            NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f, self.frame.size.height - 142.0f, 130.0f, 20.0f)];
            text.stringValue = @"キャッシュ削除：";
            [text setBezeled:NO];
            [text setDrawsBackground:NO];
            [text setEditable:NO];
            [text setSelectable:NO];
            [self.contentView addSubview:text];

            NSButton *deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(150.0f, self.frame.size.height - 145.0f, 55.0f, 25.0f)];
            deleteButton.bezelStyle = NSRoundedBezelStyle;
            deleteButton.title = @"削除";
            [deleteButton setTarget:self];
            [deleteButton setAction:NSSelectorFromString(@"confirmDeleteCache:")];
            [self.contentView addSubview:deleteButton];
        }
        
        // OK キャンセルボタン
        {
            NSButton *cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(60.0f, self.frame.size.height - 180.0f, 90.0f, 25.0f)];
            cancelButton.bezelStyle = NSRoundedBezelStyle;
            cancelButton.title = @"キャンセル";
            [cancelButton setTarget:self];
            [cancelButton setAction:NSSelectorFromString(@"cancel:")];
            [self.contentView addSubview:cancelButton];
            
            NSButton *okButton = [[NSButton alloc] initWithFrame:NSMakeRect(150.0f, self.frame.size.height - 180.0f, 55.0f, 25.0f)];
            okButton.bezelStyle = NSRoundedBezelStyle;
            okButton.title = @"OK";
            [okButton setKeyEquivalent:@"\r"];
            [okButton setTarget:self];
            [okButton setAction:NSSelectorFromString(@"ok:")];
            [self.contentView addSubview:okButton];
        }
        
//        NSAlert
//        NSButton
        
        [self initSettingFromUserDefault];
        
    }
    return self;
}


- (void)initSettingFromUserDefault
{
    NSString *blogName = [USER_DEFAULT objectForKey:UD_BLOG_NAME];
    if (blogName) {
        blogNameField_.stringValue = blogName;
    }
    else{
        blogNameField_.stringValue = @"";
    }
    
    NSString *interval = [USER_DEFAULT objectForKey:UD_DISPLAY_INTERVAL];
    if (interval) {
        displayIntervalBox_.stringValue = interval;
    }
    else{
        displayIntervalBox_.stringValue = DEFAULT_DISPLAY_INTERVAL;
    }
    
    NSUInteger isAlwaysTop = [USER_DEFAULT integerForKey:UD_IS_ALWAYS_TOP];
    if (isAlwaysTop) {
        [isAlwaysCheckBox_ setState:isAlwaysTop];
    }
    else{
        [isAlwaysCheckBox_ setState:NO];
    }
    
}


#pragma mark - NSButton Action

- (void)confirmDeleteCache:(NSButton *)b
{
    alert_ = [NSAlert alertWithMessageText:@"キャッシュを削除します"
                             defaultButton:@"OK"
                           alternateButton:nil
                               otherButton:@"キャンセル"
                 informativeTextWithFormat:@"削除後に再度取得を行います。"];
//    [alert_ runModal];
    [alert_ beginSheetModalForWindow:self
                       modalDelegate:self
                      didEndSelector:NSSelectorFromString(@"alertDidEnd:returnCode:contextInfo:")
                         contextInfo:nil];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"%d",returnCode);
    if (returnCode == 1) {
        // キャッシュ消す
        NSArray *cachedBlogList = [USER_DEFAULT objectForKey:UD_CACHED_BLOG_NAME];
        for (NSUInteger i = 0; i < [cachedBlogList count]; i++) {
            NSString *blogName = [cachedBlogList objectAtIndex:i];
            [USER_DEFAULT removeObjectForKey:blogName];
        }
        [USER_DEFAULT removeObjectForKey:UD_CACHED_BLOG_NAME];
        [USER_DEFAULT synchronize];
        
        [[[OTFileCacheManager alloc] init] clearAllCache];
        isRemovedCache_ = YES;
        
    }
    
}


- (void)cancel:(NSButton *)b
{
    [self close];
    [self initSettingFromUserDefault];
    if (isRemovedCache_) {
        NSNotification *notif = [NSNotification notificationWithName:NOTIF_UPDATE_PREFERENCES object:self];
        [NOTIF_CENTER postNotification:notif];
    }
}


- (void)ok:(NSButton *)b
{
    [self close];
    [USER_DEFAULT setObject:blogNameField_.stringValue forKey:UD_BLOG_NAME];
    {
        NSString *interval = displayIntervalBox_.stringValue;
        if ([interval integerValue] < 10) {
            // 10秒以下の場合は強制的に10
            interval = @"10";
            displayIntervalBox_.stringValue = interval;
        }
        [USER_DEFAULT setObject:interval forKey:UD_DISPLAY_INTERVAL];
    }
    [USER_DEFAULT setInteger:isAlwaysCheckBox_.state forKey:UD_IS_ALWAYS_TOP];
    [USER_DEFAULT synchronize];
    
    NSNotification *notif = [NSNotification notificationWithName:NOTIF_UPDATE_PREFERENCES object:self];
    [NOTIF_CENTER postNotification:notif];
}



#pragma mark -

//- (void)controlTextDidChange:(NSNotification *)obj
//{
//    NSTextField *tf = [obj object];
//    NSLog(@"%@",tf.stringValue);
//    
//}
//
//
//- (void)controlTextDidBeginEditing:(NSNotification *)obj
//{
//    NSLog(@"obj2");
//    
//}



#pragma mark - NSComboBox Delegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
//    NSComboBox *comboBox = [notification object];
    
    
}

#pragma mark -

- (void)cancelOperation:(id)sender
{
    [self close];
}

@end
