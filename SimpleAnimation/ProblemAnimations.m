//
//  ProblemAnimations.m
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 7/20/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#import "ProblemAnimations.h"

@interface ProblemAnimations ()

@end

@implementation ProblemAnimations
@synthesize jerkyStar;
@synthesize correctStar;
@synthesize immobileStar;
@synthesize wrongWayStar;

@synthesize flipTooMuchView;
@synthesize flipTooLittleView;
@synthesize flipTooLittleBacking;
@synthesize flipCorrectlyView;
@synthesize flipCorrectlyBacking;
@synthesize rotateColorProblemView;
@synthesize rotateColorWorkingView;
@synthesize nonFadingStar;
@synthesize blinkStar;
@synthesize fadeStar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Problems", @"Problems");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
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
    [self setBlinkStar:nil];
    [self setFadeStar:nil];
    [self setRotateColorProblemView:nil];
    [self setRotateColorWorkingView:nil];
    [self setFlipTooMuchView:nil];
    [self setFlipTooLittleView:nil];
    [self setFlipTooLittleBacking:nil];
    [self setFlipCorrectlyView:nil];
    [self setFlipCorrectlyBacking:nil];
    [self setImmobileStar:nil];
    [self setWrongWayStar:nil];
    [self setJerkyStar:nil];
    [self setCorrectStar:nil];
    [self setNonFadingStar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// The following animation doesn't work.  The star doesn't fade out or even become hidden. 'hidden' is not an animatable property, so it's not unusual that it doesn't fade out, but it is surprising that it doesn't disappear at all.  It appears that UIView is overoptimizing this animation, and given that it is first becoming hidden and then becoming unhidden, the end state is the same as the beginning, and nothing happens.  This appears to be a bug in UIKit, which is present in the iOS Simulator and on device with iOS 5.1, but will hopefully be fixed in a future release.  

- (IBAction)doNotFadeTapped:(id)sender 
{   
    [UIView animateWithDuration:1.0 animations:^
     {
         self.nonFadingStar.hidden = true;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.0 animations:^
          {
              self.nonFadingStar.hidden = false;
          }];
     }];
}

//It just blinks out.  The reason is that UIView's hidden property is not an animatable property, so setting hidden to true causes the view to simply vanish, not fade out in an animated way.  

//  The UIView documentation usually lists which properties are animatable and which are not.  

//  Note: this code a little more complicated than one might expect it to be, since if you set hidden to true in an animation block and then set it to false in a completion block or even an independent block that executes after a delay, UIView will detect that the end state is the same as the beginning state, and it won't bother to hide the star. 


- (IBAction)blinkTapped:(id)sender 
{
    [UIView animateWithDuration:1.0 animations:^
    {
        self.blinkStar.hidden = true;
    }];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0 animations:^
         {
             self.blinkStar.hidden = false;
         }];
    });
}

// This animation works.  The code is essentially the same as blinkTapped:, but in this case we're using the alpha property, so everything animates nicely.  Views with an alpha of 0 are just like views whose hidden value is true - they're not visible and they don't respond to touch events.  

- (IBAction)fadeTapped:(id)sender 
{   
    [UIView animateWithDuration:1.0 animations:^
     {
         self.fadeStar.alpha = 0;
     }
     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.0 animations:^
          {
              self.fadeStar.alpha = 1;
          }];
     }];
}

// The following animation won't work.  Since the same animatable property is being changed multiple times, all of the changes except the last change are ignored.  

- (IBAction)dontRotateColors:(id)sender 
{
    [UIView animateWithDuration:3.0 animations:^
     {
         self.rotateColorProblemView.backgroundColor = [UIColor whiteColor];
         self.rotateColorProblemView.backgroundColor = [UIColor greenColor];
         self.rotateColorProblemView.backgroundColor = [UIColor blueColor];
         self.rotateColorProblemView.backgroundColor = [UIColor redColor];
         self.rotateColorProblemView.backgroundColor = [UIColor whiteColor];
     }];
}

//  Here's a better way to rotate colors: Go through the desired colors one by one in separate animation blocks.  

- (IBAction)rotateColors:(id)sender 
{
    self.rotateColorWorkingView.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:1.0 animations:^
     {
         self.rotateColorWorkingView.backgroundColor = [UIColor blueColor];
     }
     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:1.0 animations:^
          {
              self.rotateColorWorkingView.backgroundColor = [UIColor redColor];
          }
          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:1.0 animations:^
               {
                   self.rotateColorWorkingView.backgroundColor = [UIColor whiteColor];
               }];
          }];
     }];

}

// We have animation in this one, but way too much.  The problem is that the transition occurs in the context of the superview of the view being transitioned away from.  Since the superview of the view being transitioned away from is UIViewController's main view, the whole screen flips.  

- (IBAction)flipTooMuchPressed:(id)sender  
{
UIView *copiedView = [[UIView alloc] initWithFrame:self.flipTooMuchView.frame];
copiedView.backgroundColor = self.flipTooMuchView.backgroundColor;

[UIView transitionFromView:self.flipTooMuchView
                    toView:copiedView
                  duration:1.0 
                   options:UIViewAnimationOptionTransitionFlipFromLeft 
                completion:^(BOOL finished)
 {
     self.flipTooMuchView = copiedView;
 }];
}


// This method doesn't work.  Everything is correct, but there's one problem: there are a couple of Apple constants that have very similar names.  The correct option here is UIViewAnimationOptionTransitionFlipFromLeft.  We've used UIViewAnimationTransitionFlipFromLeft - note the lack of 'Option' in the middle - and that makes the animation fail.  

- (IBAction)flipTooLittlePressed:(id)sender 
{
    UIView *copiedView = [[UIView alloc] initWithFrame:self.flipTooLittleView.frame];
    copiedView.backgroundColor = self.flipTooLittleView.backgroundColor;
    
    [UIView transitionFromView:self.flipTooLittleView
                        toView:copiedView
                      duration:1.0 
                       options:UIViewAnimationTransitionFlipFromLeft 
                    completion:^(BOOL finished)
     {
         self.flipTooLittleView = copiedView;
     }];
}

// This method works correctly.  We create a new view, and flip to it!  Woo hoo, it works!

- (IBAction)flipCorrectlyPressed:(id)sender 
{
    UIView *copiedView = [[UIView alloc] initWithFrame:self.flipCorrectlyView.frame];
    copiedView.backgroundColor = self.flipCorrectlyView.backgroundColor;
    
    [UIView transitionFromView:self.flipCorrectlyView
                        toView:copiedView
                      duration:1.0 
                       options:UIViewAnimationOptionTransitionFlipFromLeft 
                    completion:^(BOOL finished)
     {
         self.flipCorrectlyView = copiedView;
     }];
}


-(void)spinStar:(UIImageView *)whichStar
  noOfRotations:(float)noOfRotations
{
    whichStar.transform = CGAffineTransformRotate(whichStar.transform, noOfRotations * 2 * M_PI);
}


// This animation doesn't work.  The problem is that UIView tries to optimize the animation as much as possible, so it compares the end state with the beginning state.  A full rotation will mean that the end state and beginning state are the same, so UIView optimizes this animation by simply not moving the star at all.  

- (IBAction)doNotRotatePressed:(id)sender 
{
    [UIView animateWithDuration:1.0
                     animations:^
     {
         [self spinStar:immobileStar noOfRotations:1];
     }];
}

// This animation kind of works, but not the way we might want.  In this case, we're doing series of rations that take the star exactly 180° - 1/2 way around the circle.  UIView looks at the beginning state and end state, and optimizes how to get from the beginning state to the end state.  Oddly enough, in doing the initial rotate, it goes counter-clockwise.  However, if you rotate it again, it will go clockwise the next time.   

- (IBAction)wrongWayRotatePressed:(id)sender 
{
    [UIView animateWithDuration:1.0
                     animations:^
     {
         [self spinStar:wrongWayStar noOfRotations:0.5];
     }];
}

// In this method, we're doing a series of 1/4 rotations.  This works, but the animation is jerky.  The reason that it's jerky is that the default for animations is "ease in / ease out", meaning that the animations will go slowly at the beginning and end of the animation, then more quickly in the middle.  In an animation that is really a series of animations chained together, this causes jerky updating.  

- (IBAction)jerkyRotatePressed:(id)sender 
{
    static int animationCounter = 0;

    [UIView animateWithDuration:1.0
                     animations:^
     {
         [self spinStar:jerkyStar noOfRotations:0.25];
     }
                     completion:^(BOOL finished)
     {
         animationCounter ++;
         
         animationCounter == 8 ? animationCounter = 0 : [self jerkyRotatePressed:nil];
     }];
}

//Finally, a working rotate!

- (IBAction)correctRotatePressed:(id)sender 
{
    static int animationCounter = 0;
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^
     {
         [self spinStar:correctStar noOfRotations:.25];
     }
                     completion:^(BOOL finished)
     {
         animationCounter ++;
         
         animationCounter == 8 ? animationCounter = 0 : [self correctRotatePressed:nil];
     }];
}






@end
