//
//  FirstViewController.m
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#import "FirstViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>

#import "SALetterLabel.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize startingA;
@synthesize letters;

@synthesize firstLetter;
@synthesize allLetters;

@synthesize containerViews;
@synthesize cardBacks;


static float speedSetting = 1.0;  // Changes to this will speed up or slow down our animations

#pragma mark - Unanimated view changes

//  The methods in this section have no animation included in them per se, but they can be animated if they are enclosed in an animation block when they are called.

//  The following routine "hides" all of the letter views behind the first "A" in animation.  This will be helpful for a couple of the animations we are going to do.  

-(void)hideAllLettersBehindA
{
    for (SALetterLabel *thisLabel in self.allLetters) 
    {
        thisLabel.letter.backgroundColor = [UIColor whiteColor];
        thisLabel.letter.center = self.firstLetter.homeCenter;
        thisLabel.letter.alpha = 1;
    }
}

//  This routine sets the alpha of all of the views except for the first letter to zero.  There are three ways to make a view invisible:
//  1)  Set its alpha to zero.  This is alway animatable.
//  2)  Set its hidden property to true.  This is never animatable.
//  3)  Set its background color to [UIColor clearColor].  This may or may not be animatable depending on the type of view you're dealing with.  It usually will not hide your entire view - just the background.  

- (void)hideAllButA
{
    for (SALetterLabel *thisLetter in allLetters)
    {
        thisLetter.letter.alpha = (thisLetter.letter == firstLetter.letter);
    }
}

//  The following routine "moves" a single letter view to its normal "home" position.

//  Note that when we move a view around, the preferred way to move it is to change its center.  You should only change its frame if you a resizing the view.  

-(void)moveLetterViewToHomePosition:(SALetterLabel *)whichLetter
{
    whichLetter.letter.center = whichLetter.homeCenter;
}


//  The following routine "moves" all of the letter views to their normal "home" positions.

-(void)moveLetterViewsToHomePositions
{
    for (SALetterLabel *thisLabel in self.allLetters)
    {
        thisLabel.letter.center = thisLabel.homeCenter;   
    }
}

#pragma mark - Simple View Animations

-(void)colorLetter:(SALetterLabel *)whichLetter
{
    //  Uh oh!  We have a problem.  The background colors of UILabels are not animatable.  So we're going to create another view, put it behind our label view, and animate its colors!
    
    //  First let's make our letter view transparent, so we'll be able to see the new view behind it.
    
        whichLetter.letter.backgroundColor = [UIColor clearColor];
    
    //  Next let's create the backing view that we'll use for the color transitions.
    
    UIView *tempView = [[UIView alloc] initWithFrame:whichLetter.letter.frame];
    
    tempView.backgroundColor = [UIColor clearColor];
    tempView.layer.cornerRadius = whichLetter.letter.layer.cornerRadius;
    
    //  Note that we're not just using addSubview:.  insertSubview: belowSubview: allows us to put the view behind the view we want it to provide the background for.  If we just used addSubview:, the new view would be drawn in front of the existing view.
    
    [whichLetter.letter.superview insertSubview:tempView 
                                   belowSubview:whichLetter.letter];
    
    //  Now the fun - let's start changing colors!  We're going to user several nested animations with completion blocks.  In each completion block we'll start the animation to the next color.  
    
    //  The final animation block will take the backing view's alpha to 0.  In its completion block, we'll remove the backing view from its superview.   
    
    [UIView animateWithDuration:1.0*speedSetting animations:^
    {
         tempView.backgroundColor = [UIColor colorWithRed:0/255.0
                                                    green:100/255.0 
                                                     blue:155/255.0 
                                                    alpha:1.0];
    }
    completion:^(BOOL finished)
     {
         // This animation is enclosed in a completion block, so it will start when the previous animation finishes.
         
         [UIView animateWithDuration:1.0 animations:^
          {
              tempView.backgroundColor = [UIColor colorWithRed:255/255.0
                                                         green:111/255.0 
                                                          blue:207/255.0 
                                                         alpha:0.6];
          }
          completion:^(BOOL finished)
          {
              // Here we have the completion block for the second animation.  It's easy to nest blocks like this.
              
              [UIView animateWithDuration:1.0 animations:^
               {
                   tempView.alpha = 0;
               }
                               completion:^(BOOL finished)
               {
                   [tempView removeFromSuperview];
               }];
          }];
     }];
}

//  Here's one way of applying a method to each view.  We can use performSelector:withObject:afterDelay: to call a method at a particular time in the future. 

//  In this example, we're executing a method on each letter after a little bit of a delay.  

-(void)applyActionToEachLetterInTurn:(SEL)selector 
                 delayBetweenLetters:(NSTimeInterval)delayBetweenLetters 
{
    uint letterCounter = 0;
    
    for (SALetterLabel *thisLabel in self.allLetters) 
    {
        [self performSelector:selector
                   withObject:thisLabel 
                   afterDelay:delayBetweenLetters * letterCounter];
        
        letterCounter++;
    }
}

//  Here's the master routine for changing the colors one by one.  Note that we use the applyActionToEachLetterInTurn:delayBetweenLetters: method that we just defined.  


-(void)changeColorsOneByOne
{
    [self applyActionToEachLetterInTurn:@selector(colorLetter:)     
                    delayBetweenLetters:0.4*speedSetting];
}


//  This method illustrates another way of doing an animation to each view in turn.  In this case, since we just have one simple animation to do, we can call the animations using animationWithDuration:delay:options:animations:completion:

-(void)dealLettersOneByOne
{
    [UIView animateWithDuration:1.0*speedSetting 
                     animations:^
     {
         [self hideAllButA];
     }
                     completion:^(BOOL finished)
     {
         [self hideAllLettersBehindA];
         
         uint letterCounter = 0;
         
         for (SALetterLabel *thisLabel in [self.allLetters reverseObjectEnumerator]) 
         {
            [UIView animateWithDuration:0.5*speedSetting 
                                   delay:letterCounter * 1 * speedSetting 
                                 options:UIViewAnimationOptionCurveLinear
                              animations:^
            {
                [self moveLetterViewToHomePosition:thisLabel];
            }
            completion:NULL]; 
             
            letterCounter++;
         }
     }];
}

#pragma mark - View Transition demo routines

//  Up until now, all of our animations have used [UIView animate...] calls.  Here's a different way of doing animations... using the [UIView transitionWithView...] method.

//  The following view illustrates four different view transitions, using nested completion blocks to start each animation after the previous one has finished.  

//  Note that we're using container views.  The transition is performed on the superview of the views that we're changing.  If we don't have a container view, then for things like screen flips, the whole screen will flip.  We don't want that, so in another routine, we created a container view which is the size of the views we're transitioning and added the letter views to it as a subview.  Now when we do our transitions, they'll be done in the context of the container view, meaning that for flip transitions, only an area the size of our letter views will flip.   

-(void)transitionWithContainer:(UIView *)containerView
                           labelView:(UILabel *)fromView
                            cardBack:(UIImageView *)cardBack
{
        
    [UIView transitionWithView:containerView 
                      duration:2.5*speedSetting
                       options:UIViewAnimationOptionTransitionFlipFromLeft 
                    animations:^
     {
         [fromView removeFromSuperview];
         [containerView addSubview:cardBack];
     }
                    completion:^(BOOL finished)
     {
         [UIView transitionWithView:containerView 
                           duration:2.5*speedSetting
                            options:UIViewAnimationOptionTransitionCurlUp 
                         animations:^
          {
              [cardBack removeFromSuperview];
              [containerView addSubview:fromView];
          }
                         completion:^(BOOL finished)
          {
              [UIView transitionWithView:containerView 
                                duration:2.5*speedSetting
                                 options:UIViewAnimationOptionTransitionFlipFromBottom 
                              animations:^
               {
                   [fromView removeFromSuperview];
                   [containerView addSubview:cardBack];
               }
                              completion:^(BOOL finished)
               {
                   [UIView transitionWithView:containerView 
                                     duration:5*speedSetting
                                      options:UIViewAnimationOptionTransitionCrossDissolve 
                                   animations:^
                    {
                        [cardBack removeFromSuperview];
                        [containerView addSubview:fromView];
                    }
                    completion:^(BOOL finished)
                    {
                        fromView.frame = containerView.frame;
                        [self.view addSubview:fromView];
                        [containerView removeFromSuperview];
                    }];
               }];
          }];
     }];
}

// The following method calls the transitionWithContainer... method for each of our letters.

-(void)executeTransitions
{
    UIView *containerView;
    UILabel *fromView;
    UIImageView *cardBack;
    
    for (int i = 0; i < [[self allLetters] count]; i++)
    {
    
        containerView = [containerViews objectAtIndex:i];
        fromView = [[self.allLetters objectAtIndex:i] letter];
        cardBack = [cardBacks objectAtIndex:i];
        
        [self transitionWithContainer:containerView 
                                  labelView:fromView 
                                   cardBack:cardBack];
    
    }
}

//  The following method sets up the appropriate container views and "card backs" in order to do our view transitions.  

-(void)demoViewTransitions
{

    // Create an array of container views
    
    UIView *tempView;
    
    self.containerViews = [NSMutableArray array];
    
    for (SALetterLabel *eachLetter in self.allLetters)
    {
        eachLetter.letter.backgroundColor = [UIColor whiteColor];
        
        tempView = [[UIView alloc] initWithFrame:eachLetter.letter.frame];
        
        tempView.backgroundColor = [UIColor whiteColor];
        
        [containerViews addObject:tempView];
        
        [self.view addSubview:tempView];
        
        CGRect tempRect = eachLetter.letter.frame;
        tempRect.origin = CGPointMake(0,0);
        
        eachLetter.letter.frame = tempRect;
        
        [tempView addSubview:eachLetter.letter];
        
    }
    
    
    // Create an array of "card backs"
    
    self.cardBacks = [NSMutableArray array];
    
    for (SALetterLabel *eachLetter in self.allLetters)
    {
        eachLetter.letter.backgroundColor = [UIColor whiteColor];
        
        tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoldStar.png"]];
        
        tempView.contentMode = UIViewContentModeScaleAspectFit;
        
        tempView.frame = eachLetter.letter.frame;
        
        tempView.backgroundColor = [UIColor whiteColor];
        tempView.layer.cornerRadius = eachLetter.letter.layer.cornerRadius;
        tempView.layer.borderWidth = eachLetter.letter.layer.borderWidth;
        tempView.layer.borderColor = eachLetter.letter.layer.borderColor;
        
        [cardBacks addObject:tempView];
    }
    
    [self performSelector:@selector(executeTransitions) withObject:nil afterDelay:1.0*speedSetting];
     
}


#pragma mark - Standard View Controller Routines

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

#pragma mark - View Lifecycle Routines
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Let's do some setup of our Letter views.
    
    // The first view sometimes gets special treatment, so we're going to store it in its own special object.  We're going to also store its default center and frame so that we can restore them later if we need to.  
    
    self.firstLetter = [SALetterLabel new];
    self.firstLetter.letter = self.startingA;
    self.firstLetter.homeRect = self.firstLetter.letter.frame;
    self.firstLetter.homeCenter = self.firstLetter.letter.center;
    
    // Now let's store the view, frame, and center information for all of our letter views.  By putting it in an array, we'll be able to use fast enumeration later.  
    
    NSMutableArray *letterArray = [NSMutableArray array];
    
    for (UILabel *thisLabel in self.letters) 
    {
        SALetterLabel *newLabel = [SALetterLabel new];
        
        newLabel.letter = thisLabel;
        newLabel.homeCenter = thisLabel.center;
        newLabel.homeRect = thisLabel.frame;
        
        [letterArray addObject:newLabel];
    }
    
    self.allLetters = letterArray;
}

- (void)viewDidUnload
{
    // Let's let go of all of the objects that we got when the nib loaded.
    
    [self setStartingA:nil];
    [self setLetters:nil];
    
    // Okay, now let's let go of all of the objects we created in viewDidLoad
    
    [self setFirstLetter:nil];
    [self setAllLetters:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //  Let's do some standard setup that will always be true.
    
    for (SALetterLabel *thisLabel in self.allLetters) 
    {
        thisLabel.letter.layer.borderColor = [[UIColor blackColor] CGColor];
        thisLabel.letter.layer.borderWidth = 3.0;
        thisLabel.letter.layer.cornerRadius = 15.0;
    }
    
    //  Now let's do some special setup for our first animation
    
    [self hideAllLettersBehindA];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Let's start with a simple animation that will move all of the letters to their home position.
    
    [UIView animateWithDuration:2.0*speedSetting 
                     animations:^
     {
         [self moveLetterViewsToHomePositions];
     }
     completion:^(BOOL finished)
     {
         // Now, in the completion block, we'll "deal" them out one by one, like cards.  
         
         [self dealLettersOneByOne];
         
         // Finally, after that's done, we'll change their colors, one-by-one
         
         [self performSelector:@selector(changeColorsOneByOne) 
                    withObject:nil 
                    afterDelay:7*speedSetting];
         
         
         [self performSelector:@selector(demoViewTransitions)
                    withObject:nil
                    afterDelay:12*speedSetting];
     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


@end
