//
//  PlaylistTableViewCell.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/17/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//
//  Demo of MPMediaQuery and MPMediaItem.

#import "PlaylistTableViewCell.h"
#import "PlaylistView.h"

#define SUBVIEW_COUNT 2
#define CELL_HEIGHT 120.0

@implementation PlaylistTableViewCell

@synthesize lastTouchedPlaylist;

- (void)dealloc {
    [lastTouchedPlaylist release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //Each cell will display multiple playlists in PlaylistViews.
        //Create the views...
        CGRect subviewFrame = CGRectMake(0, 0, 
                                         self.contentView.frame.size.width / SUBVIEW_COUNT, 
                                         CELL_HEIGHT);

        for (int i=0; i<SUBVIEW_COUNT; i++) {        
            PlaylistView *playlistView = [[PlaylistView alloc] initWithFrame:subviewFrame];
            [self.contentView addSubview:playlistView];
            [playlistView release];
            subviewFrame = CGRectOffset(subviewFrame, self.contentView.frame.size.width / SUBVIEW_COUNT, 0);
        }
    }
    
    return self;
}

//Set MPMediaPlaylist collections from the passed
//array of MPMediaItemCollection objects.
- (void)setItemCollections:(NSArray *)collections {
    
    for (int i=0; i<SUBVIEW_COUNT; i++) {                
        PlaylistView *playlistView = (PlaylistView *) [self.contentView.subviews objectAtIndex:i];
        if (i < [collections count]) {
            MPMediaPlaylist *playlist = [collections objectAtIndex:i];            
            playlistView.playlist = playlist;
        } else {
            playlistView.playlist = nil;
        }
    }
}


#pragma mark -
#pragma mark Touch events

//Record which subview was last touched. If the table view's didSelectRowAtIndexPath
//fires for this cell, we need to know which playlist was selected.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint pt = [aTouch locationInView:self.contentView];
    for (int i=0; i<SUBVIEW_COUNT; i++) {                
        PlaylistView *playlistView = (PlaylistView *) [self.contentView.subviews objectAtIndex:i];
        if (CGRectContainsPoint(playlistView.frame, pt)) {
            lastTouchedPlaylist = playlistView.playlist;
            break;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}


@end
