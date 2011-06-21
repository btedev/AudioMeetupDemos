//
//  RootViewController.m
//  AVDemo
//
//  Created by Barry Ezell on 6/14/11.
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
    
    self.viewControllers = [NSArray arrayWithObjects:@"SystemSoundViewController", 
                                                        @"AVAudioPlayerViewController",
                                                        @"AVAudioRecorderViewController",
                            nil];                            
}

// Customize the number of sections in the table view.
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

    NSString *vcName = [viewControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = vcName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *vcName = [viewControllers objectAtIndex:indexPath.row];
    Class vcClass = NSClassFromString(vcName);
    UIViewController *vc = (UIViewController *) [[vcClass alloc] initWithNibName:vcName 
                                                                          bundle:nil];
    [self.navigationController pushViewController:vc 
                                         animated:YES];
    [vc release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end
