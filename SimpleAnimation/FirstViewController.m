//
//  FirstViewController.m
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


#import "FirstViewController.h"

#import "SALetterLabel.h"


@interface FirstViewController ()

#pragma mark - Properties

@property (strong, nonatomic) IBOutlet SALetterLabel *startingA;

@property (strong, nonatomic) IBOutletCollection(SALetterLabel) NSArray *letters;

@property (strong, nonatomic) NSMutableArray *containerViews;
@property (strong, nonatomic) NSMutableArray *cardBacks;

@end


@implementation FirstViewController


#pragma mark - Initializer

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
    
    // Store the view, frame, and center information for all of our letter views.
    
    for (SALetterLabel *label in self.letters)
    {
        label.homeCenter = label.center;
        label.homeRect = label.frame;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (SALetterLabel *letter in self.letters)
    {
        letter.layer.borderColor = [[UIColor blackColor] CGColor];
        letter.layer.borderWidth = 3.0;
        letter.layer.cornerRadius = 15.0;
        
        letter.backgroundColor = [UIColor whiteColor];
        letter.alpha = 1;
    }
    
    //  Now let's do some special setup for our first animation
    
    [self hideAllLettersBehindA];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Let's start with a simple animation that will move all of the letters to their home position.
    
    [UIView animateWithDuration:2.0
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
                    afterDelay:7];
         
         
         [self performSelector:@selector(demoViewTransitions)
                    withObject:nil
                    afterDelay:12];
     }];
}


#pragma mark - Unanimated view changes

//  The methods in this section have no animation included in them per se, but they can be animated if they are enclosed in an animation block when they are called.

//  The following routine "hides" all of the letter views behind the first "A" in animation.  This will be helpful for a couple of the animations we are going to do.  

-(void)hideAllLettersBehindA
{
    for (SALetterLabel *label in self.letters)
    {
        label.center = self.startingA.homeCenter;
    }
}

//  This routine sets the alpha of all of the views except for the first letter to zero.  There are three ways to make a view invisible:
//  1)  Set its alpha to zero.  This is alway animatable.
//  2)  Set its hidden property to true.  This is never animatable.
//  3)  Set its background color to [UIColor clearColor].  This may or may not be animatable depending on the type of view you're dealing with.  It usually will not hide your entire view - just the background.  

- (void)hideAllButA
{
    for (SALetterLabel *letter in self.letters)
    {
        letter.alpha = (letter == self.startingA);
    }
}

//  The following routine "moves" a single letter view to its normal "home" position.

//  Note that when we move a view around, the preferred way to move it is to change its center.  You should only change its frame if you a resizing the view.  

-(void)moveLetterViewToHomePosition:(SALetterLabel *)whichLetter
{
    whichLetter.center = whichLetter.homeCenter;
}


//  The following routine "moves" all of the letter views to their normal "home" positions.

-(void)moveLetterViewsToHomePositions
{
    for (SALetterLabel *thisLabel in self.letters)
    {
        thisLabel.center = thisLabel.homeCenter;
    }
}

#pragma mark - Simple View Animations

-(void)colorLetter:(SALetterLabel *)whichLetter
{
    //  Uh oh!  We have a problem.  The background colors of UILabels are not animatable.  So we're going to create another view, put it behind our label view, and animate its colors!
    
    //  First let's make our letter view transparent, so we'll be able to see the new view behind it.
    
        whichLetter.backgroundColor = [UIColor clearColor];
    
    //  Next let's create the backing view that we'll use for the color transitions.
    
    UIView *tempView = [[UIView alloc] initWithFrame:whichLetter.frame];
    
    tempView.backgroundColor = [UIColor clearColor];
    tempView.layer.cornerRadius = whichLetter.layer.cornerRadius;
    
    //  Note that we're not just using addSubview:.  insertSubview: belowSubview: allows us to put the view behind the view we want it to provide the background for.  If we just used addSubview:, the new view would be drawn in front of the existing view.
    
    [whichLetter.superview insertSubview:tempView
                                   belowSubview:whichLetter];
    
    //  Now the fun - let's start changing colors!  We're going to user several nested animations with completion blocks.  In each completion block we'll start the animation to the next color.  
    
    //  The final animation block will take the backing view's alpha to 0.  In its completion block, we'll remove the backing view from its superview.   
    
    [UIView animateWithDuration:1.0 animations:^
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
    NSInteger letterCounter = 0;
    
    for (SALetterLabel *letter in self.letters)
    {
        [self performSelector:selector
                   withObject:letter
                   afterDelay:delayBetweenLetters * letterCounter];
        
        letterCounter++;
    }
}

//  Here's the master routine for changing the colors one by one.  Note that we use the applyActionToEachLetterInTurn:delayBetweenLetters: method that we just defined.  


-(void)changeColorsOneByOne
{
    [self applyActionToEachLetterInTurn:@selector(colorLetter:)     
                    delayBetweenLetters:0.4];
}


//  This method illustrates another way of doing an animation to each view in turn.  In this case, since we just have one simple animation to do, we can call the animations using animationWithDuration:delay:options:animations:completion:

-(void)dealLettersOneByOne
{
    [UIView animateWithDuration:1.0
                     animations:^
     {
         [self hideAllButA];
     }
                     completion:^(BOOL finished)
     {
         [self hideAllLettersBehindA];
         
         NSInteger letterCounter = 0;
         
         for (SALetterLabel *letter in [self.letters reverseObjectEnumerator])
         {
            letter.alpha = 1;
             
            [UIView animateWithDuration:0.5
                                   delay:letterCounter
                                 options:UIViewAnimationOptionCurveLinear
                              animations:^
            {
                [self moveLetterViewToHomePosition:letter];
            }
            completion:NULL];
             
            letterCounter++;
         }
     }];
}

#pragma mark - View Transition Animations

//  Up until now, all of our animations have used [UIView animate...] calls.  Here's a different way of doing animations... using the [UIView transitionWithView...] method.

//  The following view illustrates four different view transitions, using nested completion blocks to start each animation after the previous one has finished.  

//  Note that we're using container views.  The transition is performed on the superview of the views that we're changing.  If we don't have a container view, then for things like screen flips, the whole screen will flip.  We don't want that, so in another routine, we created a container view which is the size of the views we're transitioning and added the letter views to it as a subview.  Now when we do our transitions, they'll be done in the context of the container view, meaning that for flip transitions, only an area the size of our letter views will flip.   

-(void)transitionWithContainer:(UIView *)containerView
                           labelView:(UILabel *)fromView
                            cardBack:(UIImageView *)cardBack
{
        
    [UIView transitionWithView:containerView 
                      duration:2.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft 
                    animations:^
     {
         [fromView removeFromSuperview];
         [containerView addSubview:cardBack];
     }
    completion:^(BOOL finished)
     {
         [UIView transitionWithView:containerView 
                           duration:2.5
                            options:UIViewAnimationOptionTransitionCurlUp 
                         animations:^
          {
              [cardBack removeFromSuperview];
              [containerView addSubview:fromView];
          }
          completion:^(BOOL finished)
          {
              [UIView transitionWithView:containerView 
                                duration:2.5
                                 options:UIViewAnimationOptionTransitionFlipFromBottom 
                              animations:^
               {
                   [fromView removeFromSuperview];
                   [containerView addSubview:cardBack];
               }
               completion:^(BOOL finished)
               {
                   [UIView transitionWithView:containerView 
                                     duration:5
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
    
    for (int i = 0; i < [[self letters] count]; i++)
    {
    
        containerView = self.containerViews[i];
        fromView = self.letters[i];
        cardBack = self.cardBacks[i];
        
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
    
    for (SALetterLabel *eachLetter in self.letters)
    {
        eachLetter.backgroundColor = [UIColor whiteColor];
        
        tempView = [[UIView alloc] initWithFrame:eachLetter.frame];
        
        tempView.backgroundColor = [UIColor whiteColor];
        
        [self.containerViews addObject:tempView];
        
        [self.view addSubview:tempView];
        
        CGRect tempRect = eachLetter.frame;
        tempRect.origin = CGPointMake(0,0);
        
        eachLetter.frame = tempRect;
        
        [tempView addSubview:eachLetter];
    }
    
    
    // Create an array of "card backs"
    
    self.cardBacks = [NSMutableArray new];
    
    for (SALetterLabel *eachLetter in self.letters)
    {
        eachLetter.backgroundColor = [UIColor whiteColor];
        
        tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoldStar.png"]];
        
        tempView.contentMode = UIViewContentModeScaleAspectFit;
        
        tempView.frame = eachLetter.frame;
        
        tempView.backgroundColor = [UIColor whiteColor];
        tempView.layer.cornerRadius = eachLetter.layer.cornerRadius;
        tempView.layer.borderWidth = eachLetter.layer.borderWidth;
        tempView.layer.borderColor = eachLetter.layer.borderColor;
        
        [self.cardBacks addObject:tempView];
    }
    
    [self performSelector:@selector(executeTransitions) withObject:nil afterDelay:1.0];
     
}


@end
