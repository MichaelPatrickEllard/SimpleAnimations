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

@property (strong, nonatomic) IBOutlet SALetterLabel *firstLetter;      // The leftmost letter on the screen.  Important because it is sometimes treated differently from the other letters.

@property (strong, nonatomic) IBOutletCollection(SALetterLabel) NSArray *letters;   // All of the letter views on the screen, including the firstLetter.

@property (strong, nonatomic) UIColor *blueColor;                       // Used for color change animation
@property (strong, nonatomic) UIColor *pinkColor;                       // Used for color change animation

@property (strong, nonatomic) NSMutableArray *containerViews;           // Container views which serve as a context for the view transition demos
@property (strong, nonatomic) NSMutableArray *flipsides;                // Views which are exchanged with letter views for the view transition demos

@property (weak, nonatomic) IBOutlet UIButton *replayButton;            // Allows the user to restart the animation demo once it has completed

@property (strong, nonatomic) NSMutableArray *taskQueue;                // Holds a list of selectors to be executed in sequence. Selectors are stored as strings

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

//  viewDidLoad is used for code that should be executed once when the letter views are loaded from the nib file, but not again after that.
//  This method stores the "home" center information for all of our letter views.  This indicates where the views should be placed when they're in their default state.
//  It also sets some layer properties so our views will look like playing cards


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

//  viewWillAppear: is used for operations that should be done every time that the view is about to appear onscreen.
//  An animation from a previous appearance of the screen might have left the views in an altered state, so this setup should be done every time the view is about to appear.
//  At the end of this method, hideLettersBehindFirstLetter is called to to prepare for the first animation demo.

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

//  viewDidAppear: is used for operations that should be done as soon as the view appears onscreen. This will be called the first time that a user goes to a screen.  However, it will not be called if the app goes into the background and then is made active again.

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showAllAnimations:nil];
}


#pragma mark - Simple View Animations

//  The following routine "moves" a single letter view to its normal "home" position.
//  Note that when we move a view around, the preferred way to move it is to change its center.  You should only change its frame if you a resizing the view.

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

//  This routine sets the alpha of all of the views except for the first letter to zero.  There are three ways to make a view invisible:
//  1)  Set its alpha to zero.  This is always animatable.
//  2)  Set its hidden property to true.  This is never animatable.
//  3)  Set its background color to [UIColor clearColor].  This may or may not be animatable depending on the type of view you're dealing with.  It usually will not hide your entire view - just the background.

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


//  Here's the master routine for changing the colors one by one.
//  The background colors of UILabels are not animatable.  So we're going to create another view, put it behind our label view, and animate its colors.
//  First make the letter view's background transparent, so you can see the new view behind it.
//  Next let's create the backing view that we'll use for the color transitions.
//  insertSubview: belowSubview: allows you to put the view behind the view we want it to provide the background for.  If you just used addSubview:, the new view would be drawn in front of the existing view and you wouldn't be able to see the label or its border.
//  Now the fun - let's start changing colors!  We're going to user several nested animations with completion blocks.  In each completion block we'll start the animation to the next color.
//  The final animation block will take the backing view's alpha to 0.  In its completion block, we'll remove the backing view from its superview.
//  Here we have the completion block for the second animation.  It's easy to nest blocks like this.


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
         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:1.0 animations:^
              {
                  tempView.backgroundColor = [self pinkColor];
              }
              completion:^(BOOL finished)
              {
                  [UIView animateWithDuration:1.0 animations:^
                   {
                       tempView.alpha = 0;
                       
                   }
                   completion:^(BOOL finished)
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

//  Up until now, all of our animations have used [UIView animate...] calls.  Here's a different way of doing animations... using the [UIView transitionWithView...] method.

//  The following view illustrates four different view transitions, using nested completion blocks to start each animation after the previous one has finished.  

//  Note that we're using container views.  The transition is performed on the superview of the views that we're changing.  If we don't have a container view, then for things like screen flips, the whole screen will flip.  We don't want that, so in another routine, we created a container view which is the size of the views we're transitioning and added the letter views to it as a subview.  Now when we do our transitions, they'll be done in the context of the container view, meaning that for flip transitions, only an area the size of our letter views will flip.

-(void)demoViewTransition:(UIViewAnimationOptions)options
{
    for (int i = 0; i < [self.letters count]; i++)
    {
        UIView *containerView = self.containerViews[i];
        UIView *letterView = self.letters[i];
        
        UIView *fromView;
        UIView *toView;
        
        if (letterView.superview)
        {
            fromView = letterView;
            toView = self.flipsides[i];
        }
        else
        {
            fromView = self.flipsides[i];
            toView = letterView;
        }
        
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
// Set the letter view's background color to white
// Create container view to supply the context in which the transition will occur
// Create an "flipside views" which animations will transition from and to

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

// Dispose of flipside views

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

#pragma mark - Animation Coordination Routines

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
