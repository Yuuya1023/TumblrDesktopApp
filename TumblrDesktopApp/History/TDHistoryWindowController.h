//
//  TDHistoryWindowController.h
//  TumblrDesktopApp
//
//  Created by 南部 祐耶 on 2014/10/30.
//  Copyright (c) 2014年 南部 祐耶. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface TDHistoryWindowController : NSWindowController

+ (TDHistoryWindowController *)sharedTDHistoryWindowControllerController;

- (void)pushHistory:(NSDictionary *)postDetail;


@end
