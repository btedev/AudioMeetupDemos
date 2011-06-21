//
//  SystemSoundViewController.m
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/14/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//
//  Demonstration of basic sounds, alerts, and vibrations using 
//  System Sound Services. Note: you should use this for short sound effects 
//  only (max 30 seconds). Compared to other API's its fast, lightweight,
//  and easy to configure.
//  
//  Droid sounds via http://www.moviewavs.com/Movies/Star_Wars/r2d2.html
//  Cat pic via http://getoutoftherecat.tumblr.com/post/3681137491/get-out-of-there-cat-you-do-not-belong-in-r2d2-he

#import "SystemSoundViewController.h"

@implementation SystemSoundViewController

@synthesize urlRefOne, urlRefTwo, soundOne, soundTwo;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"System Sounds";
           
    //Get NSURLs to the sound files. They must be .caf, .aiff, or .wav.
    //.caf/.aiff are functionally equivalent and are preferred.
    //Convert most formats to .caf on OS X via:
    //  afconvert -f caff -d LEI16 {input} {output.caf}
    // Droid sounds via http://www.moviewavs.com/Movies/Star_Wars/r2d2.html
    NSURL *urlOne =  [[NSBundle mainBundle] URLForResource:@"r2d2wst1" 
                                               withExtension:@"caf"];
    
    NSURL *urlTwo =  [[NSBundle mainBundle] URLForResource:@"r2d2wst4" 
                                                  withExtension:@"caf"];
    
    //Retain references to these NSURL's as CFURL's (remember we're in C Land).
    //They will be released in dealloc.
    self.urlRefOne = (CFURLRef) [urlOne retain];
    self.urlRefTwo = (CFURLRef) [urlTwo retain];
    
    //Create a sound ID object, and assign to instance var for each sound
    AudioServicesCreateSystemSoundID(urlRefOne, &soundOne);
    AudioServicesCreateSystemSoundID(urlRefTwo, &soundTwo);
}

//Play sound.
- (IBAction)soundButtonWasPressed {
    AudioServicesPlaySystemSound(soundOne);   
}

//Play sound and vibrate (or vibrate only if mute switch on).
- (IBAction)alertButtonWasPressed {
    AudioServicesPlayAlertSound(soundTwo); 
}

//Just vibrate. Does nothing in the simulator.
- (IBAction)vibrateButtonWasPressed {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)dealloc {    
    AudioServicesDisposeSystemSoundID (soundOne);
    AudioServicesDisposeSystemSoundID (soundTwo);
    CFRelease (urlRefOne);
    CFRelease (urlRefTwo);
    [super dealloc];
}


@end
