//
//  PickerViewController.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/16/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//
//  Demo of MPMediaPickerController.

#import "PickerViewController.h"
#import "PlayerViewController.h"


@implementation PickerViewController

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Picker";
    
    [self chooseMusic];
}

- (void)viewDidUnload {
    [super viewDidUnload];    
}

- (void)chooseMusic {
    //Create and display the iPod media picker. See delegate methods
    //below for events following display.
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];                   
    
    [picker setDelegate: self];                                         
    [picker setAllowsPickingMultipleItems: YES];                        
    picker.prompt = NSLocalizedString (@"Add songs to play",
                                       "Prompt in media item picker");
    
    [self presentModalViewController: picker animated: YES];    
    [picker release];
}

#pragma mark - Media picker delegate methods

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    //Create an instance of the PlayerVC, set the selected collection on it,
    //dismiss the modal, then push the player onto the nav stack
    PlayerViewController *playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" 
                                                                            bundle:nil];
    playerVC.collection = collection;    
    [self dismissModalViewControllerAnimated: YES];
    [self.navigationController pushViewController:playerVC 
                                         animated:NO];
    [playerVC release];    
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {    
    [self dismissModalViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

@end
