//
//  PlaylistTableViewController.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/17/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "PlaylistTableViewCell.h"
#import "PlayerViewController.h"


@implementation PlaylistTableViewController

@synthesize collections;

- (void)dealloc {
    [collections release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Playlists";
    
    //Obtain an array of all playlists
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    self.collections = [query collections];   
    NSLog(@"Playlist count: %i",[collections count]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Each cell will contain two playlists, except for the last cell in the case of odd-numbered playlist count.
    return ceil((float) [collections count] / 2.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaylistTableViewCell";
    
    PlaylistTableViewCell *cell = (PlaylistTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } 
    
    //Because there are two objects per row, index is 2 * row index
    int curIdx = indexPath.row * 2;
    
    //Set collection(s) on cell
    NSArray *itemCollections;
    if (curIdx + 1 < [collections count] - 1) {
        itemCollections = [NSArray arrayWithObjects:(MPMediaItemCollection *) [collections objectAtIndex:curIdx], 
                           (MPMediaItemCollection *) [collections objectAtIndex:curIdx + 1],
                           nil];
    } else {
        itemCollections = [NSArray arrayWithObjects:(MPMediaItemCollection *) [collections objectAtIndex:curIdx], 
                           nil];
    }
    
    [cell setItemCollections:itemCollections];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistTableViewCell *cell = (PlaylistTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    if (cell.lastTouchedPlaylist != nil) {
        PlayerViewController *playerVC = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" 
                                                                                bundle:nil];
        playerVC.collection = cell.lastTouchedPlaylist; //MPMediaPlaylist is a subclass of MPMediaItemCollection
        [self.navigationController pushViewController:playerVC 
                                             animated:YES];
        [playerVC release];
    } 
}

@end
