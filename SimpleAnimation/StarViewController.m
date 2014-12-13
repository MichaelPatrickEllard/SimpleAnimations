//
//  SecondViewController.m
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

//  One interesting feature illustrated by this screen:  you can have multiple animations running at the same time, even if the start and stop times for those animations are not the same.  Thus, you can start a second animation while the first animation is still running, and both animations will run at the same time and each will finish according to the duration you set for that animation.  You can have a number of different animations running at once, each with a different start and stop time.


#import "StarViewController.h"


@interface StarViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *starImage;

@end


@implementation StarViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Star", @"Star");
        self.tabBarItem.image = [UIImage imageNamed:@"StarIcon"];
    }
    return self;
}

							
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //  Setting up the layer's shadow options.  This will help us twinkle when it's time.
    
    self.starImage.layer.shadowOffset = CGSizeMake(0,0);
    self.starImage.layer.shadowColor = [[UIColor orangeColor] CGColor];
    self.starImage.layer.shadowRadius = 30;
}


#pragma mark - Move Star

//  Like most of the routines here, this is broken up into two parts:  a routine that does the actual view manipulation, and a second routine that includes the changes to the view in an animation block.  In this case, moveStar does the work of moving the star, moveStarAnimated: calls moveStar from within an animation block.

-(void)moveStar
{
    CGPoint currentCenter = self.starImage.center;
    
    CGPoint destination;
    
    if (currentCenter.x == 150)
    {
        destination = CGPointMake(500, 500);
    }
    else 
    {
        destination = CGPointMake(150, 250);
    }
    
    self.starImage.center = destination;
}



-(IBAction)moveStarAnimated:(id)sender
{
    [UIView animateWithDuration:5.0 animations:^
     {
         [self moveStar];
     }];
}


#pragma mark - Zoom Star

//  zoomStar follows the same model as moveStar.  There's a non-animated method that does the actual work, then second method that encloses the first method in an animation block.

-(void)zoomStar
{
    CGRect starBounds = self.starImage.bounds;
    
    CGSize newSize;
    
    if (starBounds.size.width == 250)
    {
        newSize = CGSizeMake(1000, 1000);
    }
    else 
    {
        newSize = CGSizeMake(250, 250);
    }
    
    starBounds.size = newSize;
    
    self.starImage.bounds = starBounds;
}



-(IBAction)zoomStarAnimated:(id)sender
{
    [UIView animateWithDuration:3.5 animations:^
     {
         [self zoomStar];
     }];
}



#pragma mark - Twinkle Routines

// This routine involves some more complex code.  We're not just altering view properties here, we're actually manipulating the properties of its underlying layer.  

//  To understand this code, it is important to note that we set up some of the layer's shadow properties in the viewDidLoad method.

-(void)changeShadow
{
    CGFloat targetOpacity = !self.starImage.layer.shadowOpacity;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:self.starImage.layer.shadowOpacity];
    anim.toValue = [NSNumber numberWithFloat:targetOpacity];
    anim.duration = 1.0;
    [self.starImage.layer addAnimation:anim forKey:@"shadowOpacity"];
    
    self.starImage.layer.shadowOpacity = targetOpacity;
}


// We could do all of these calls in blocks, but we'll use peformSelector:withObject:afterDelay: to show a another way that iOS developers sometimes do delayed code execution.  

-(IBAction)changeShadowAnimated:(id)sender
{
    [self changeShadow];
    
    [self performSelector:@selector(changeShadow) withObject:nil afterDelay:1.1];
    
    [self performSelector:@selector(changeShadow) withObject:nil afterDelay:2.2];
    
    [self performSelector:@selector(changeShadow) withObject:nil afterDelay:3.3];
    
    [self performSelector:@selector(changeShadow) withObject:nil afterDelay:4.4];
    
    [self performSelector:@selector(changeShadow) withObject:nil afterDelay:5.5];
}


#pragma mark - Spin

// For reasons that will become clear in the Problem Animations code, we need to do our star rotation as a series of quarter rotations.  As before, we have two methods:  one to do the work, the other to enclose the first method in an animation block.

-(void)spinStar
{
    self.starImage.transform = CGAffineTransformRotate(self.starImage.transform, .5 * M_PI);
}


//  Note that this second method is a recursive method.  It calls itself until repeatedly until its animationCounter variable reaches 8.  At that point it resets the counter and stops calling itself.

-(IBAction)spinStarAnimated:(id)sender
{
    static NSInteger animationCounter = 0;
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^
    {
        [self spinStar];
    }
    completion:^(BOOL finished)
    {
        animationCounter ++;
        
        animationCounter == 8 ? animationCounter = 0 : [self spinStarAnimated:nil];
    }];
}


//  Fading things in and out is one of the most common animations that you'll use in any app.  

- (IBAction)fadeStarAnimated:(id)sender 
{
    [UIView animateWithDuration:3 animations:^
     {
         self.starImage.alpha = 0;
     }
     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:3 animations:^
          {
              self.starImage.alpha = 1;
          }];
     }];
}

@end
