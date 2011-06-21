//
//  PlayerViewController.h
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/16/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController : UIViewController {
    
}

@property (nonatomic, retain) MPMusicPlayerController   *musicController;
@property (nonatomic, retain) MPMediaItemCollection     *collection;
@property (nonatomic, retain) IBOutlet UILabel          *timeLabel;
@property (nonatomic, retain) IBOutlet UIButton         *playPauseButton;
@property (nonatomic, retain) IBOutlet UIImageView      *albumArtImageView;
@property (nonatomic, retain) UIImage                   *playImage;
@property (nonatomic, retain) UIImage                   *pauseImage;

- (IBAction)playPauseButtonWasPressed;
- (IBAction)ffButtonWasPressed;
- (IBAction)rewButtonWasPressed;

- (void)registerForPlayerNotifications;
- (void)registerForRemoteControlNotifications;
- (void)playbackStateChanged:(NSNotification *)notification;
- (void)nowPlayingItemChanged:(NSNotification *)notification ;
- (void)togglePlaybackState;
- (void)updatePlayButtonUI;

@end
