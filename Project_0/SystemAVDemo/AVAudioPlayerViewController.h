//
//  AVAudioPlayerViewController.h
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/14/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayerViewController : UIViewController <AVAudioPlayerDelegate> {
    BOOL            userChangingTimeSlider;
    NSTimeInterval  duration;
}

@property (nonatomic, retain) AVAudioPlayer     *player;
@property (nonatomic, retain) NSTimer           *timer;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UISlider *timeSlider;
@property (nonatomic, retain) IBOutlet UILabel  *timeLabel;
@property (nonatomic, retain) UIImage           *playImage;
@property (nonatomic, retain) UIImage           *pauseImage;

- (void)setupAudio;
- (void)updatePlaybackStateUI;
- (void)updateCurrentTimeUI;
- (void)togglePlayback;
- (IBAction)playPauseButtonWasPressed;
- (NSString *)formatTimeString:(NSTimeInterval)s asNegative:(BOOL)negative;



@end
