//
//  ProblemAnimations.h
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 7/20/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#import <UIKit/UIKit.h>

@interface ProblemAnimations : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *nonFadingStar;
@property (strong, nonatomic) IBOutlet UIImageView *blinkStar;
@property (strong, nonatomic) IBOutlet UIImageView *fadeStar;

- (IBAction)doNotFadeTapped:(id)sender;
- (IBAction)blinkTapped:(id)sender;
- (IBAction)fadeTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *rotateColorProblemView;
@property (strong, nonatomic) IBOutlet UIView *rotateColorWorkingView;

- (IBAction)dontRotateColors:(id)sender;
- (IBAction)rotateColors:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *flipTooMuchView;

@property (strong, nonatomic) IBOutlet UIView *flipTooLittleView;
@property (strong, nonatomic) IBOutlet UIView *flipTooLittleBacking;

@property (strong, nonatomic) IBOutlet UIView *flipCorrectlyView;
@property (strong, nonatomic) IBOutlet UIView *flipCorrectlyBacking;


- (IBAction)flipTooMuchPressed:(id)sender;
- (IBAction)flipTooLittlePressed:(id)sender;
- (IBAction)flipCorrectlyPressed:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView *immobileStar;
@property (strong, nonatomic) IBOutlet UIImageView *wrongWayStar;
@property (strong, nonatomic) IBOutlet UIImageView *jerkyStar;
@property (strong, nonatomic) IBOutlet UIImageView *correctStar;

- (IBAction)doNotRotatePressed:(id)sender;
- (IBAction)wrongWayRotatePressed:(id)sender;
- (IBAction)jerkyRotatePressed:(id)sender;
- (IBAction)correctRotatePressed:(id)sender;




@end
