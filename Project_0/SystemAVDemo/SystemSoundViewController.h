//
//  SystemSoundViewController.h
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/14/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SystemSoundViewController : UIViewController

@property (readwrite) CFURLRef urlRefOne;
@property (readwrite) CFURLRef urlRefTwo;
@property (readonly) SystemSoundID soundOne;
@property (readonly) SystemSoundID soundTwo;

- (IBAction)soundButtonWasPressed;
- (IBAction)alertButtonWasPressed;
- (IBAction)vibrateButtonWasPressed;

@end
