//
//  TPFeedbackViewController.h
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPFeedbackViewController : UIViewController <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
    
    IBOutlet UITextView *textView;
}
- (IBAction)backgroundTapped:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;
@end
