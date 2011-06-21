//
//  AVRecorderViewController.m
//  SystemAVDemo
//
//  Created by Barry Ezell on 6/19/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//
//  Simple audio recorder. Plays back immediately after recording.

#import "AVAudioRecorderViewController.h"

@implementation AVAudioRecorderViewController

@synthesize button, soundFileURL, soundRecorder, soundPlayer;

- (void)dealloc {
    [button release];
    [soundFileURL release];
    [soundRecorder release];
    [soundPlayer release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil { 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath =
    [tempDir stringByAppendingString: @"sound.caf"];
    
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;
    [newURL release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //Close the audio session
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - Recording methods

- (IBAction)buttonPressed {
    if (recording) {
        [self stopRecording];
        [button setTitle:@"Start" 
                forState:UIControlStateNormal];
    } else {
        [self startRecording];
        [button setTitle:@"Stop" 
                forState:UIControlStateNormal];
    }
}

- (void)startRecording {    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord 
                                           error:nil];      
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDictionary *recordSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
     nil];
    
    AVAudioRecorder *newRecorder =
    [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                settings: recordSettings
                                   error: nil];
    [recordSettings release];
    self.soundRecorder = newRecorder;
    [newRecorder release];
    
    [soundRecorder prepareToRecord];
    [soundRecorder record];    
    
    recording = YES;
    NSLog(@"Recording started");
}

- (void)stopRecording {
    [soundRecorder stop];
    recording = NO;
    self.soundRecorder = nil;
    NSLog(@"Recording ended");
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    [self playbackRecording];
}

- (void)playbackRecording {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback 
                                           error:nil];      
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL 
                                           error:nil];
    newPlayer.delegate = self;
    self.soundPlayer = newPlayer;
    [newPlayer release];
    [newPlayer play];  
    
    NSLog(@"Playback started");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    NSLog(@"Playback ended");
}

@end
