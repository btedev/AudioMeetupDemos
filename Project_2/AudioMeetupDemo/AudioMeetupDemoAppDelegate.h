//
//  AudioMeetupDemoAppDelegate.h
//  AudioMeetupDemo
//
//  Created by Barry Ezell on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppleXylophoneViewController.h"

@interface AudioMeetupDemoAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet AppleXylophoneViewController *viewController;

@end
