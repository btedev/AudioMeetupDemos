//
//  AVRecorderViewController.h
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/19/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface AVAudioRecorderViewController : UIViewController <AVAudioSessionDelegate, AVAudioPlayerDelegate> {
    bool recording;
}

@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) NSURL             *soundFileURL;
@property (nonatomic, retain) AVAudioRecorder   *soundRecorder;
@property (nonatomic, retain) AVAudioPlayer     *soundPlayer;

- (IBAction)buttonPressed;
- (void)startRecording;
- (void)stopRecording;
- (void)playbackRecording;

@end
