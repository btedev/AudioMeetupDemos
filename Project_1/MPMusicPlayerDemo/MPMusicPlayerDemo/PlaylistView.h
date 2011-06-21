//
//  PlaylistView.h
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/19/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlaylistView : UIView {
    
}

@property (nonatomic, retain) MPMediaPlaylist   *playlist; //MPMediaPlaylist is subclass of MPMediaItemCollection
@property (nonatomic, retain) UIImageView       *albumImageView;
@property (nonatomic, retain) UILabel           *titleLabel;

- (void)populateAlbumArt;
- (void)populatePlaylistName;

@end
