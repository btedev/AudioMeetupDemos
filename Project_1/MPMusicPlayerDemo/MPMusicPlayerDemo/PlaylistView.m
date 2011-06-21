//
//  PlaylistView.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/19/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import "PlaylistView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define SIZE_FACTOR         0.8
#define LABEL_HEIGHT        14.0
#define MARGIN              4.0

@implementation PlaylistView

@synthesize playlist, albumImageView, titleLabel;

- (void)dealloc {
    [playlist release];
    [albumImageView release];
    [titleLabel release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Create image and label which will be populated 
        // when playlist is set
        int side = self.frame.size.height * SIZE_FACTOR;
        CGRect albumFrame = CGRectMake((self.frame.size.width / 2.0) - (side / 2.0), 
                                       MARGIN, 
                                       side, 
                                       side);
        self.albumImageView = [[UIImageView alloc] initWithFrame:albumFrame];
        albumImageView.backgroundColor = [UIColor grayColor];        
        [self addSubview:albumImageView];
        [albumImageView release];
        
        int width = self.frame.size.width * SIZE_FACTOR;
        CGRect titleFrame = CGRectMake((self.frame.size.width / 2.0) - (width / 2.0), 
                                       albumImageView.frame.origin.y + albumImageView.frame.size.height + MARGIN, 
                                       width, 
                                       LABEL_HEIGHT);
        self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"Futura-Medium" 
                                          size:10.0];
        [self addSubview:titleLabel];
        [titleLabel release];        
    }
    return self;
}

- (void)setPlaylist:(MPMediaPlaylist *)newPlaylist {
    if (newPlaylist != playlist) {
        [newPlaylist retain];
        [playlist release];
        playlist = newPlaylist;
    }    
    
    //Obtain album art image and name in background. This can be a 
    //time-consuming step which causes scrolling stutter if not handled
    //in a block or separate thread. Note: the playlist name is an attribute of the collection
    //while the artwork must come from an item from that collection.
    
    if (playlist != nil) {
        [self performSelectorInBackground:@selector(populateAlbumArt) 
                               withObject:nil];
        [self performSelectorInBackground:@selector(populatePlaylistName) 
                                withObject:nil];        
    } else {
        albumImageView.image = nil;
        albumImageView.backgroundColor = [UIColor whiteColor];
        titleLabel.text = @"";
    }
}

- (void)populateAlbumArt {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MPMediaItem *item = [playlist representativeItem];
    MPMediaItemArtwork *art = [item valueForProperty:MPMediaItemPropertyArtwork];
    if (art!=nil){
        UIImage *image = [art imageWithSize:self.albumImageView.frame.size];                                         
        [albumImageView performSelectorOnMainThread:@selector(setImage:) 
                                         withObject:image 
                                      waitUntilDone:NO];
    } else {
        [albumImageView performSelectorOnMainThread:@selector(setImage:) 
                                         withObject:[UIImage imageNamed:@"herp_derp_hoss.png"]
                                      waitUntilDone:NO];
    }
    [pool release];
}

- (void)populatePlaylistName {    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *name = [playlist valueForProperty:MPMediaPlaylistPropertyName];
    [titleLabel performSelectorOnMainThread:@selector(setText:) 
                                 withObject:name 
                              waitUntilDone:NO];
    [pool release];
}

@end
