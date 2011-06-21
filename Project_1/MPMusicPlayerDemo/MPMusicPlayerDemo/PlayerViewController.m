//
//  PlayerViewController.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/16/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import "PlayerViewController.h"

@implementation PlayerViewController

@synthesize timeLabel, playPauseButton, albumArtImageView, musicController;
@synthesize playImage, pauseImage, collection;

- (void)dealloc {
    [musicController release];
    [timeLabel release];
    [playPauseButton release];
    [albumArtImageView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //need play and pause images
    self.playImage = [UIImage imageNamed:@"Play 1.png"];
    self.pauseImage = [UIImage imageNamed:@"Pause.png"];
    
    //setup audio session as playback
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

    //Use the Media Player's volume view. Do not use your own because you will not get
    //AirPlay, dock handling, last-in device volume level recall, etc.
    MPVolumeView *volView = [[MPVolumeView alloc] initWithFrame:CGRectMake(18, 374, 284, 23)];
    [self.view addSubview:volView];
    [volView release];
        
    //Setup MPMusicPlayerController as an "iPod" player which means it will
    //share state with the iPod app after exiting this app (e.g. the same track
    //will appear in the iPod). 
    self.musicController = [MPMusicPlayerController iPodMusicPlayer]; 
    
    //Receive notifications when the track changes or play/pause is toggled
    [self registerForPlayerNotifications];
    
    //Register self for remote notifications of play/pause toggle
    //(i.e. when user backgrounds app, double-taps home,
    //then swipes right to reveal multimedia control buttons).    
    //See MyWindow.h for more info.
    [self registerForRemoteControlNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Load the player with the item collection and begin playback
    [musicController setQueueWithItemCollection:collection];
    [musicController play];
}

- (void)registerForPlayerNotifications {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (nowPlayingItemChanged:)
	 name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	 object:      nil];
	
	[notificationCenter
	 addObserver: self
	 selector:    @selector (playbackStateChanged:)
	 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:      nil];
    
	[self.musicController beginGeneratingPlaybackNotifications];
}

- (void)registerForRemoteControlNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(togglePlayback) 
                                                 name:@"TogglePlaybackState" 
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self.musicController endGeneratingPlaybackNotifications];
}

#pragma mark -
#pragma mark IBAction events

- (IBAction)playPauseButtonWasPressed {
    [self togglePlaybackState];
}

- (IBAction)ffButtonWasPressed {
    if ([[collection items] indexOfObject:musicController.nowPlayingItem] < [[collection items] count] - 1) {
        [musicController skipToNextItem];
    }
}

- (IBAction)rewButtonWasPressed {
    [musicController skipToPreviousItem];
}

#pragma mark -
#pragma mark Audio and notification methods

- (void)togglePlaybackState {
    if (musicController.playbackState == MPMoviePlaybackStatePlaying) {
        [musicController pause];
    } else {
        [musicController play];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification {
	[self updatePlayButtonUI];
}

- (void)nowPlayingItemChanged:(NSNotification *)notification {
    MPMediaItem *currentItem = [musicController nowPlayingItem];
    
    //retrieve the album art and set on album art view
    MPMediaItemArtwork *coverArt = [currentItem valueForProperty:MPMediaItemPropertyArtwork]; 
    if (coverArt) {
        UIImage *artwork = [coverArt imageWithSize:albumArtImageView.frame.size];
        albumArtImageView.image = artwork;
    } else {
        albumArtImageView.image = [UIImage imageNamed:@"herp_derp_hoss.png"];
    }
    
    NSString *trackTitle = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    timeLabel.text = trackTitle;
}

#pragma mark -
#pragma mark UI update methods

- (void)updatePlayButtonUI {
    if (musicController.playbackState == MPMusicPlaybackStatePlaying) {
        [self.playPauseButton setImage:self.pauseImage 
                              forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setImage:self.playImage 
                              forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Memory events

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


@end
