//
//  MyWindow.m
//
//  Created by Barry Ezell on 6/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyWindow.h"


@implementation MyWindow

- (void)makeKeyAndVisible {
	[super makeKeyAndVisible];
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
	UIDevice* device = [UIDevice currentDevice];	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
		[self becomeFirstResponder];
	}
#endif
}

///////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    
	if (theEvent.type == UIEventTypeRemoteControl)	{
		switch(theEvent.subtype)		{
			case UIEventSubtypeRemoteControlPlay:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlStop:
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NextTrack" object:nil];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PreviousTrack" object:nil];
				break;
			default:
				return;
		}
	}
}

#endif

/*
BTE note: do NOT include this line below b/c the app will be rejected for calling a private API 
 via @selector(firstResponder)
- (UIView *)findFirstResponder
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIView   *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
	return firstResponder;
}
 */

@end
