//
//  PlaylistTableViewCell.h
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/17/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlaylistTableViewCell : UITableViewCell {
    
}

@property (nonatomic, retain) MPMediaPlaylist *lastTouchedPlaylist;

- (void)setItemCollections:(NSArray *)collections;

@end
