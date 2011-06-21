//
//  PickerViewController.h
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/16/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface PickerViewController : UIViewController <MPMediaPickerControllerDelegate> {
    
}

- (IBAction)chooseMusic;

@end
