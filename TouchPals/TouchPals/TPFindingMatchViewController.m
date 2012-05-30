//
//  TPFindingMatchViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-26.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPFindingMatchViewController.h"
#import "TPAppDelegate.h"

@implementation TPFindingMatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate login];
}
@end
