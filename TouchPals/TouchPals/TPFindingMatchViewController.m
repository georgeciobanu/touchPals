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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (IBAction)logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate login];
}
@end
