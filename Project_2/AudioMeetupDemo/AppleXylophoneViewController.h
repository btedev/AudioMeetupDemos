//
//  AppleXylophone.h
//  AudioMeetupDemo
//
//  Created by Barry Ezell on 6/13/11.
//  Copyright 2011 DOCKMARKET LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixerHostAudio.h"

#define KEY_COUNT 6

@interface AppleXylophoneViewController : UIViewController {
    int                 lastKeyIndex;
    CGRect              keyRects[KEY_COUNT]; 
    
}

@property (nonatomic, assign) MixerHostAudio *mixerHost;

- (int)keyIndexForTouch:(UITouch *)touch;
- (IBAction) mixerOutputGainChanged: (UISlider *) sender;

@end
