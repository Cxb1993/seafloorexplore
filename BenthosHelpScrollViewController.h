//
//  BenthosScrollViewController.h
//  Benthos
//
//  Created by Matthew Johnson-Roberson on 5/22/12.
//  Copyright (c) 2012 Sunset Lake Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BenthosHelpScrollViewController : UIViewController <UIScrollViewDelegate>{
    UIScrollView* scrollView;
    NSMutableArray *molecules;

}
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property(readwrite,retain) NSMutableArray *molecules;

- (IBAction)displayMoleculeDownloadView;
- (IBAction)switchBackToGLView;
@end
