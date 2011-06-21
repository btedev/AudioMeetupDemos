//
//  AVAudioPlayerViewController.m
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/14/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import "AVAudioPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define UPDATE_TIME_INTERVAL 1.0

@implementation AVAudioPlayerViewController 

@synthesize player, timer; 
@synthesize playPauseButton, timeLabel, timeSlider, playImage, pauseImage;

- (void)dealloc {
    [player release];
    [timer release];
    [playPauseButton release];
    [timeLabel release];
    [timeSlider release];
    [playImage release];
    [pauseImage release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"AVAudioPlayer";
            
    //setup play/pause images used for the center button
    self.playImage  = [UIImage imageNamed:@"Play 1.png"];
    self.pauseImage = [UIImage imageNamed:@"Pause.png"];
    
    //Use the MP-supplied volume view instead of a slider connected to the AVPlayer.
    //It automatically handles route changes and sets the volume according to the output device.
    //(e.g., like the iPod it will set the last-used volume when a headphone is plugged in, etc.).	
	MPVolumeView *volView = [[MPVolumeView alloc] initWithFrame:CGRectMake(50, 374, 252, 23)];	
	[self.view addSubview:volView];
    [volView release];
    
    //Prepare AVAudioPlayer for playback
    [self setupAudio];
    
    //Register self for remote notifications of play/pause toggle
    //(i.e. when user backgrounds app, double-taps home,
    //then swipes right to reveal multimedia control buttons).    
    //See MyWindow.h for more info.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(togglePlayback) 
                                                 name:@"TogglePlayPause" 
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //Close the audio session
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark -
#pragma mark AVAudioPlayer methods

- (void)setupAudio {
    
    //Configure the audio session for playback (as opposed to ambient, solo ambient, etc.)
    NSError *setCategoryErr = nil;
    NSError *activationErr = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback 
                                           error:&setCategoryErr];
    
    if (setCategoryErr != nil) {
        NSLog(@"Set category error: %@",[setCategoryErr localizedDescription]);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:&activationErr];
    
    if (activationErr != nil) {
        NSLog(@"Make active error: %@",[activationErr localizedDescription]);
    }    
    
    //Get the URL of a bundled public domain MP3 (source = http://www.archive.org/details/SousaLibertyBellhunsberger )
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sousa_LibertyBell" 
                                                         ofType:@"mp3"];
    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];
    
    //Create an instance of AVPlayer with this URL as the sound source
    NSError *playerInitErr = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl 
                                                         error:&playerInitErr];
    
    if (playerInitErr != nil) {
        NSLog(@"Error creating AVAudioPlayer instance: %@",[playerInitErr localizedDescription]);
    }
    
    [player release];
    [fileUrl release];
    
    //Set self as delegate
    player.delegate = self;
    
    //Several method need the max time (duration) of this file
    duration = player.duration;
    
    //Prepare for playback. If this isn't called explicitly, it will occur automatically when
    //[player play] is called. However, there the delay before playback begins will be longer
    //so it's recommended to always call prepare.
    [player prepareToPlay];
}

- (void)togglePlayback {    
    (player.isPlaying ? [player pause] : [player play]);    
    [self updatePlaybackStateUI];
    
    //start a timer to update time elapsed labels and time slider
    if (player.isPlaying && timer == nil) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME_INTERVAL
										 target:self 
									   selector:@selector(updateCurrentTimeUI) 
									   userInfo:nil 
										repeats:YES];		
	}
}

- (void)updatePlaybackStateUI {
    if (player.isPlaying) {         
        [playPauseButton setImage:pauseImage 
                         forState:UIControlStateNormal];
    } else {                
        [playPauseButton setImage:playImage 
                         forState:UIControlStateNormal];
    }
}

- (void)updateCurrentTimeUI {
    //Update center time label with elapsed and remaining times
    NSString *elapsed = [self formatTimeString:player.currentTime 
                                    asNegative:NO];
    NSString *remaining = [self formatTimeString:(duration - player.currentTime) 
                                      asNegative:YES];
    timeLabel.text = [NSString stringWithFormat:@"%@ | %@",elapsed, remaining];
        
    //Update timer slider unless user is currently changing.
    //Animations help keep the increments less noticible to the user.
    if (!userChangingTimeSlider) { 
        [UIView beginAnimations:@"update slider" 
                        context:nil];
        [UIView setAnimationDuration:UPDATE_TIME_INTERVAL * 0.95f];
        timeSlider.value = player.currentTime / duration;
        [UIView commitAnimations];       
    }   
}

#pragma mark -
#pragma mark UI events

- (IBAction)playPauseButtonWasPressed {
    [self togglePlayback];
}

//User began changing time slider value. Set a flag that will prevent the slider
//from being updated programmatically until touchUp. It's possible to change player time
//in a "valueChanged" method but AVAudioPlayer may not be able to process the changes
//quickly enough (depending on file size and hardware) and the user may notice gaps and stutters.
- (IBAction)timeSliderTouchDown {    
    userChangingTimeSlider = YES;    
}

//User has requested a time jump.
- (IBAction)timeSliderTouchUp {        
    player.currentTime = (timeSlider.value * duration);    
    userChangingTimeSlider = NO;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag {       
    [timer invalidate];
    [timer release];
    timer = nil;
    [self updateCurrentTimeUI];    
    [self updatePlaybackStateUI];    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    //In real app, may persist this to NSUserDefaults to act on after interruption ends
    //or app resumes.
    NSLog(@"Interruption began");
}

//Note: this form is only for iOS >= 4.0. See docs for pre-4.0.
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags {
    NSLog(@"Interruption ended");
    //restart playback if flag indicates we should resume
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        [self togglePlayback];
    }
}


#pragma mark -
#pragma mark Utility events

- (NSString *)formatTimeString:(NSTimeInterval)s asNegative:(BOOL)negative {	
	
	int seconds = (int) s;
	int hours = seconds / 3600;
	seconds -= (hours * 3600);
	int mins = seconds / 60;
	seconds -= (mins * 60);	

	NSString *sign = (negative ? @"-" : @"");
	if (hours > 0) {
		return [NSString stringWithFormat:@"%@%i:%02d:%02d", sign, hours, mins, seconds];
	} else {
		return [NSString stringWithFormat:@"%@%02d:%02d", sign, mins, seconds];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
}

@end
