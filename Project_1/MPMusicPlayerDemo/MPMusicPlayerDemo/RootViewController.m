//
//  RootViewController.m
//  MPMusicPlayerDemo
//
//  Created by Barry Ezell on 6/16/11.
//  Copyright 2011 Barry Ezell. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize viewControllers;

- (void)dealloc {
    [viewControllers release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Demos";
    
    self.viewControllers = [[NSArray alloc] initWithObjects:@"PickerViewController",
                                                            @"PlaylistTableViewController", 
                                                            nil];    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [viewControllers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [viewControllers objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = [viewControllers objectAtIndex:indexPath.row];
    Class aClass = NSClassFromString(className);
    UIViewController *viewController = (UIViewController *) [[aClass alloc] initWithNibName:className 
                                                                                     bundle:nil];
    [self.navigationController pushViewController:viewController 
                                         animated:YES];
    [viewController release];    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


@end
