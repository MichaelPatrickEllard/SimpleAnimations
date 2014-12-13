//
//  FirstViewController.m
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


/*  This screen demonstrates eight animations in sequence.  The first four animations are animations of UIView properties.  The next four animations are view transition animations, which animate the act of replacing an existing subview with a new one.  The animations shown are:

      1)  Hiding letters by setting their alpha to zero
      2)  Moving letters in an animated way, with all animations beginning and ending at the same time
      3)  Moving letters in an animated way, with each animation beginning and ending at a different time
      4)  Animating changes in the background color of a view
      5)  Doing a "flip from left" view transition from one view to another
      6)  Doing a "curl up" view transition from one view to another
      7)  Doing a "flip from bottom" view transition from one view to another
      8)  Doing a "cross disolve" view transition from one view to another
 
    Each animation is done using a separate method. In a few cases, sub-methods are used in order to keep the code clear and concise.
 
    The animation methods are managed using a very simple task queue created as part of this class.  */



#import "DemoViewController.h"

#import "SALetterLabel.h"


@interface DemoViewController ()

#pragma mark - Properties

@property (strong, nonatomic) IBOutlet SALetterLabel *firstLetter;      // The leftmost letter on the screen.  Important because it is sometimes treated differently from the other letters.

@property (strong, nonatomic) IBOutletCollection(SALetterLabel) NSArray *letters;   // All of the letter views on the screen, including the firstLetter.

@property (strong, nonatomic) UIColor *blueColor;                       // Used for color change animation
@property (strong, nonatomic) UIColor *pinkColor;                       // Used for color change animation

@property (strong, nonatomic) NSMutableArray *containerViews;           // Container views which serve as a context for the view transition demos
@property (strong, nonatomic) NSMutableArray *flipsides;                // Views which are exchanged with letter views for the view transition demos

@property (weak, nonatomic) IBOutlet UIButton *replayButton;            // Allows the user to restart the animation demo once it has completed

@property (strong, nonatomic) NSMutableArray *taskQueue;                // Holds a list of selectors to be executed in sequence. Selectors are stored as strings

@end


@implementation DemoViewController


#pragma mark - Initializer

//  The only custom behavior in our initializer is setting the title and icon for this screens tab in the tab bar controller.  Everything else is inherited from superclasses.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Demo", @"Demo");
        self.tabBarItem.image = [UIImage imageNamed:@"DemoIcon"];
    }
    return self;
}


#pragma mark - View Lifecycle Routines

//  viewDidLoad is used for code that should be executed once when the letter views are loaded from the nib file, but not again after that.
//  This method stores the "home" center information for all of our letter views.  This indicates where the views should be placed when they're in their default state.
//  It also sets some layer properties so our views will look like playing cards.


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (SALetterLabel *letter in self.letters)
    {
        letter.homeCenter = letter.center;
    
        letter.layer.borderColor = [[UIColor blackColor] CGColor];
        letter.layer.borderWidth = 3.0;
        letter.layer.cornerRadius = 15.0;
    }
}

//  viewWillAppear: is used for operations that should be done every time that the view controller's main view is about to appear onscreen.
//  An animation from a previous appearance of the screen might have left the views in an altered state, so this setup should be done every time the main view is about to appear.

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (SALetterLabel *letter in self.letters)
    {
        letter.backgroundColor = [UIColor whiteColor];
        letter.alpha = 1;
    }
    
    self.replayButton.alpha = 0;
}

//  viewDidAppear: is used for operations that should be done as soon as the view appears onscreen. This will be called the first time that a user goes to a screen.  However, it will not be called if the app goes into the background and then is made active again. This screen uses viewDidAppear: to run the showAllAnimations: method as soon as the view appears on screen.

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showAllAnimations:nil];
}


#pragma mark - Simple View Animations

//  The following routine moves all views to their "home" positions, which were set in viewDidLoad.
//  To move a view around, change its center.  You should only change a view's frame if you are resizing the view.
//  Note the completion block, which can be used for housekeeping or to set up another animation.  This method, like all of the other animation methods for this class, calls queueTaskEnded: when it is done.

-(void)moveLetterViewsToHomePositionsAnimated
{
    [UIView animateWithDuration:2.0 animations:^
     {
         for (SALetterLabel *letter in self.letters)
         {
             letter.center = letter.homeCenter;
         }
     }
     completion:^(BOOL finished)
     {
         [self queuedTaskEnded:finished];
     }];
}

//  This routine sets the alpha of all of the views except for the first letter to zero.
//  There are three ways to make a view invisible:
//      1)  Set its alpha to zero.  This is always animatable.
//      2)  Set its hidden property to true.  This is never animatable.
//      3)  Set its background color to [UIColor clearColor].  This may or may not be animatable depending on the type of view you're dealing with.  It usually will not hide your entire view - just the background.
//  Note the completion block.  After animating the transition from an alpha of 1.0 to an alpha of 0.0, the views are moved behind the first letter and their alpha is restored to 1.0.  Since the firstLetter view is the last-added subview, it is drawn last and effectively hides all of the views that are behind it.

-(void)hideLettersAnimated
{
    [UIView animateWithDuration:1.0
                     animations:^
     {
         for (SALetterLabel *letter in self.letters)
         {
             if (letter == self.firstLetter)
             {
                 letter.alpha = 1.0;
             }
             else
             {
                 letter.alpha = 0.0;
             }
         }
     }
     completion:^(BOOL finished)
     {
         for (SALetterLabel *label in self.letters)
         {
             label.center = self.firstLetter.homeCenter;
             label.alpha = 1.0;
         }
         
         [self queuedTaskEnded:finished];
     }];
}

//  This method is very similar to moveLetterViewsToHomePositionsAnimated, except that instead of moving the letters all at once, it moves them one-by-one.
//  Previous methods have used UIView's animationWithDuration:animation:completion:.  This method uses UIView's animationWithDuration:delay:options:animation:completion:, which allows us to specify a delay before the animation should be run.  By specifying a different delay for each letter, we can move them one-by-one.


-(void)moveLettersOneByOneAnimated
{
    NSInteger letterCounter = 0;
    __block NSInteger completionCount = 0;
    
    for (SALetterLabel *letter in [self.letters reverseObjectEnumerator])
    {
        letter.alpha = 1;
        
        [UIView animateWithDuration:0.5
                              delay:letterCounter * 0.5
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             letter.center = letter.homeCenter;
         }
                         completion:^(BOOL finished)
         {
             completionCount++;
             
             if (completionCount == [self.letters count])
             {
                 [self queuedTaskEnded:finished];
             }
         }];
        
        letterCounter++;
    }
}


//  The following method rotates the background colors of our letters from white to blue to pink and then back to white again.
//  The background colors of UILabels are not animatable.  So this routine changes the letter views' backgrounds to ClearColor, creates a backing view for each letter, puts the backing view behind each letter view, and animates the colors on the backing view.
//  Note that this method nests calls to UIView animateWithDuration: in the completion block for previous animations.

-(void)changeLetterColorsAnimated
{
    NSInteger letterCounter = 0;
    
    for (SALetterLabel *letter in self.letters)
    {
        letter.backgroundColor = [UIColor clearColor];
        
        UIView *tempView = [[UIView alloc] initWithFrame:letter.frame];
        
        tempView.backgroundColor = [UIColor clearColor];
        tempView.layer.cornerRadius = letter.layer.cornerRadius;
        
        
        
        [letter.superview insertSubview:tempView
                                belowSubview:letter];
        
        [UIView animateWithDuration:1.0
                              delay:0.4 * letterCounter
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             tempView.backgroundColor = [self blueColor];
         }
         completion:^(BOOL finished)                            //  Completion block
         {
             [UIView animateWithDuration:1.0 animations:^
              {
                  tempView.backgroundColor = [self pinkColor];
              }
              completion:^(BOOL finished)                       //  Start of first nested completion block
              {
                  [UIView animateWithDuration:1.0 animations:^
                   {
                       tempView.alpha = 0;
                       
                   }
                   completion:^(BOOL finished)                  //  Start of second nested completion block
                   {
                       [tempView removeFromSuperview];
                       
                       if (letter == [self.letters lastObject])
                       {
                           [self queuedTaskEnded:finished];
                       }
                   }];
              }];
         }];

        letterCounter++;
    }
}

#pragma mark - View Transition Animations

//  All of the previous animations methods have used variations on UIView's animateWithDuration: methods.  The next four animations use a different approach - they use UIView transitionWithView... methods.  The transitionWithView:... methods involve three views:
//
//      A)  A container view.  This view isn't animated per se, but it provides the context in which the animation should occur.  See the flip animations on the ProblemAnimations screen for an example of what can happen if the container view isn't set up appropriately.
//      B)  A "from view" this is a current subview of the container view which is going to be removed as a subview of the container view.
//      C)  A "to view" this is a view which is going to be added as subview of the container view in place of the "from view."
//
//  While the view transition animations appear very different to the user, the code used to produce them is almost exactly the same.  For this reason, a single demoViewTransition: submethod is used to perform all four different view transition animations.  The only difference between the four is the UIViewAnimationOptions passed to each view.

-(void)demoViewTransition:(UIViewAnimationOptions)options
{
    for (NSInteger i = 0; i < [self.letters count]; i++)
    {
        UIView *containerView = self.containerViews[i];
        
        UIView *fromView = [self transitionDemoFromViewForIndex:i];
        UIView *toView = [self transitionDemoToViewForIndex:i];
        
        [UIView transitionWithView:containerView
                          duration:2.5
                           options:options
                        animations:^
         {
             [fromView removeFromSuperview];
             [containerView addSubview:toView];
         }
         completion:^(BOOL finished)
         {
             if (containerView == self.containerViews.lastObject) {
                 
                if (!finished)
                {
                    [self tearDownAfterViewTransitionDemo];
                }
                 
                [self queuedTaskEnded:finished];
             }
         }];
    }
}

-(UIView *)transitionDemoFromViewForIndex:(NSInteger)index
{
    UIView *letterView = self.letters[index];
    
    return [letterView superview] ? letterView : self.flipsides[index];
}


-(UIView *)transitionDemoToViewForIndex:(NSInteger)index
{
    UIView *letterView = self.letters[index];
    
    return [letterView superview] ? self.flipsides[index] : letterView;
}


-(void)demoViewTransitionFlipFromLeft
{
    [self demoViewTransition:UIViewAnimationOptionTransitionFlipFromLeft];
}


-(void)demoViewTransitionCurlUp
{
    [self demoViewTransition:UIViewAnimationOptionTransitionCurlUp];
}


-(void)demoViewTransitionFlipFromBottom
{
    [self demoViewTransition:UIViewAnimationOptionTransitionFlipFromBottom];
}


-(void)demoViewTransitionCrossDissolve
{
    [self demoViewTransition:UIViewAnimationOptionTransitionCrossDissolve];
}


// The following method sets up the appropriate container views and "flipside views" in order to do our view transitions.

-(void)setupForViewTransitionDemo
{
    self.containerViews = [NSMutableArray array];
    
    self.flipsides = [NSMutableArray new];
    
    for (SALetterLabel *letter in self.letters)
    {
        letter.backgroundColor = [UIColor whiteColor];
        
        UIView *containerView = [[UIView alloc] initWithFrame:letter.frame];
        
        containerView.backgroundColor = [UIColor whiteColor];
        
        [self.containerViews addObject:containerView];
        
        [self.view addSubview:containerView];
        
        CGRect tempRect = letter.frame;
        tempRect.origin = CGPointZero;
        
        letter.frame = tempRect;
        
        [containerView addSubview:letter];
        
        UIView *flipside = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoldStar.png"]];
        
        flipside.contentMode = UIViewContentModeScaleAspectFit;
        
        flipside.frame = letter.frame;
        
        flipside.backgroundColor = [UIColor whiteColor];
        flipside.layer.cornerRadius = letter.layer.cornerRadius;
        flipside.layer.borderWidth = letter.layer.borderWidth;
        flipside.layer.borderColor = letter.layer.borderColor;
        
        [self.flipsides addObject:flipside];
    }
    
    [self queuedTaskEnded:YES];
}

// This method removes any leftover container views and flipside views from the view transition demos.

-(void)tearDownAfterViewTransitionDemo
{
    for (UIView *eachView in self.flipsides)
    {
        if (eachView.superview)
        {
            [eachView removeFromSuperview];
        }
    }
    
    self.flipsides = nil;
    
    if (self.containerViews)
    {
        for (NSInteger i = [self.containerViews count] - 1; i >= 0 ; --i)
        {
            UIView *letter = self.letters[i];
            UIView *containerView = self.containerViews[i];
            
            letter.frame = containerView.frame;
            
            [self.view addSubview:letter];
            [containerView removeFromSuperview];
        }
        
        self.containerViews = nil;
    }
    
    [self queuedTaskEnded:YES];
}

#pragma mark - Task Queue

//  The methods in this section implement a simple task queue which is used to execute the desired animations in sequence, along with some other necessary maintenance tasks.  

-(IBAction)showAllAnimations:(id)sender
{
    [self addSelectorToTaskQueue:@selector(hideReplayButton)];
    
    [self addSelectorToTaskQueue:@selector(hideLettersAnimated)];
    
    [self addSelectorToTaskQueue:@selector(moveLetterViewsToHomePositionsAnimated)];
    
    [self addSelectorToTaskQueue:@selector(hideLettersAnimated)];
    
    [self addSelectorToTaskQueue:@selector(moveLettersOneByOneAnimated)];
    
    [self addSelectorToTaskQueue:@selector(changeLetterColorsAnimated)];
    
    [self addSelectorToTaskQueue:@selector(setupForViewTransitionDemo)];
    
    [self addSelectorToTaskQueue:@selector(demoViewTransitionFlipFromLeft)];
    
    [self addSelectorToTaskQueue:@selector(demoViewTransitionCurlUp)];
    
    [self addSelectorToTaskQueue:@selector(demoViewTransitionFlipFromBottom)];
    
    [self addSelectorToTaskQueue:@selector(demoViewTransitionCrossDissolve)];
    
    [self addSelectorToTaskQueue:@selector(tearDownAfterViewTransitionDemo)];
    
    [self addSelectorToTaskQueue:@selector(showReplayButton)];
    
    [self runNextQueuedTask];
}


-(void)runNextQueuedTask
{
    if (!self.taskQueue)
    {
        NSLog(@"All done. No tasks to run.");
    }
    else if ([self.taskQueue count] == 0)
    {
        NSLog(@"All done. The task queue exists but is empty");
        self.taskQueue = nil;
    }
    else
    {
        NSString *selectorString = self.taskQueue[0];
        SEL selector = NSSelectorFromString(selectorString);
        
        [self.taskQueue removeObjectAtIndex:0];
        
        if ([self.taskQueue count] == 0)
        {
            self.taskQueue = nil;
        }
        
        NSLog(@"Starting task: %@", selectorString);
        
        [self performSelector:selector
                   withObject:nil
                   afterDelay:0];
    }
}

-(void)addSelectorToTaskQueue:(SEL)selector
{
    if (!self.taskQueue)
    {
        self.taskQueue = [NSMutableArray new];
    }
    
    [self.taskQueue addObject:NSStringFromSelector(selector)];
}

//  If a task didn't complete, empty the task queue so that we can start from scratch next time.  Animations might not complete if the app went into the background or if another screen became active.
//  If the task did complete, start the next task (if any).

-(void)queuedTaskEnded:(BOOL)completed
{

    if (!completed)
    {
        self.taskQueue = nil;
        
        NSLog(@"Animation did not complete.");
        
        [self showReplayButton];
    }
    else
    {
        [self runNextQueuedTask];
    }
}

#pragma mark - Replay Button

-(void)showReplayButton
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.replayButton.alpha = 1.0;
    }
    completion:^(BOOL finished)
    {
        
        [self queuedTaskEnded:finished];
                         
    }];
}

-(void)hideReplayButton
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.replayButton.alpha = 0.0;
    }
    completion:^(BOOL finished)
    {
                         
        [self queuedTaskEnded:finished];
                         
    }];
}


#pragma mark - Custom Getters

-(UIColor *)blueColor
{
    if (!_blueColor)
    {
        _blueColor = [UIColor colorWithRed:0/255.0
                                     green:100/255.0
                                      blue:155/255.0
                                     alpha:1.0];
    }
    
    return _blueColor;
}

-(UIColor *)pinkColor
{
    if (!_pinkColor)
    {
        _pinkColor = [UIColor colorWithRed:255/255.0
                                     green:111/255.0
                                      blue:207/255.0
                                     alpha:0.6];
    }
    
    return _pinkColor;
}

@end
