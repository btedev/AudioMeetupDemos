//
//  AppleXylophone.m
//  AudioMeetupDemo
//
//  Created by Barry Ezell on 6/13/11.
//  Copyright 2011 DOCKMARKET LLC. All rights reserved.
//

#import "AppleXylophoneViewController.h"


@implementation AppleXylophoneViewController

@synthesize mixerHost;

- (void)dealloc {
    [super dealloc];
    [mixerHost release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //define the "key" xylophone note rectangles
    keyRects[0] = CGRectMake(55, 347, 199, 42);
    keyRects[1] = CGRectMake(55, 304, 199, 42);
    keyRects[2] = CGRectMake(55, 258, 199, 44);
    keyRects[3] = CGRectMake(55, 213, 199, 44);
    keyRects[4] = CGRectMake(55, 166, 199, 44);
    keyRects[5] = CGRectMake(55, 43, 199, 121);
        
    //create the mixer
    self.mixerHost = [[MixerHostAudio alloc] init];
    
    //start the audio graph
    [mixerHost startAUGraph];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Handle a change in the mixer output gain slider.
- (IBAction) mixerOutputGainChanged: (UISlider *) sender {
    [mixerHost setMixerOutputGain: (AudioUnitParameterValue) sender.value];
}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    int idx = [self keyIndexForTouch:aTouch];
    
    if (idx >= 0) {
        if ([mixerHost playNote:idx] == YES) {
            lastKeyIndex = idx;
        }
    }    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    lastKeyIndex = -1;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    int idx = [self keyIndexForTouch:aTouch];
    
    if (idx >= 0 && idx != lastKeyIndex) {
        if ([mixerHost playNote:idx] == YES) {
            lastKeyIndex = idx;
        }
    } 
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    lastKeyIndex = -1;
}

- (int)keyIndexForTouch:(UITouch *)touch {
    int keyIndex = -1;
    CGPoint pt = [touch locationInView:self.view];
    
    for (int i=0; i<KEY_COUNT; i++) {
        CGRect rect = keyRects[i];
        if (CGRectContainsPoint(rect, pt)) {
            keyIndex = i;
            break;
        }
    }
    
    return keyIndex;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
