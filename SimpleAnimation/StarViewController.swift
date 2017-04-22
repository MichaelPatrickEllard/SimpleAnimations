//
//  StarViewController.swift
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

//  Most of the animations on this screen are done by manipulating UIView properties.
//
//  The animation methods here are usually broken up into two parts:
//
//      -   a method that does the actual view manipulation
//      -   a second method that wraps the first method in an animation block that is passed to the UIView class to execute.
//
//  For example, moveStar does the work of moving the star, moveStarAnimated: calls moveStar from within an animation block.
//
//  This division is useful, since sometimes you want to manipulate views while your view is offscreen and preparing to go on screen. In this case, you don't want to animate something that the user can't see.
//  Also helpful to note: when you wrap a method call in a UIView animation block, view property changes in sub-methods are included as well.
//
//  This screen also demonstrates that you can have multiple animations running on different properties of the same view at the same time, even if the start and stop times for the animations are not the same.  Thus, you can start a second animation while the first animation is still running. Both animations will run at the same time and each will finish according to the duration you set for that animation.  You can have a number of different animations running at once, each with a different start and stop time.
//
//  However, you cannot have two animations running on the same property of the same view at the same time.  Thus, you can have a move animation running on a view at the same time that you have a fade animation running. However, if you start a second move animation while a move animation is running, the first move animation will terminate and the second will start.
//
//  Some of these animations are more expensive than others.  In particular, the twinkle animation is very expensive.  If you start a twinkle animation at the same time that other animations are running, performance can become noticeably bad.

//  To keep the code simple and easy-to-read, I have used named methods instead of closures with capture lists.  This does mean that there can be strong reference cycles created while animations are running, but this should not cause any long-term problems.

//  The code lacks protections that would prevent a user from restarting an animation method that is already running. This is acceptable for a demonstration project like this where it can be helpful to see what happens when a second animation is started while an existing animation is running.


import UIKit


class StarViewController : UIViewController, CAAnimationDelegate
{
    /// Thie UIImageView manipulated in all of this screen's animation demos
    @IBOutlet var starImage: UIImageView!
    
    /// Used by the `spinStarAnimated` method, keeps track of how many quarter turns the star has spun
    var spinCounter: Int = 0
    
    /// Used by the twinkle methods, keeps track of how many times the star's CALayer shadow has been updated
    var twinkleCounter: Int = 0


    //MARK: - Move Star

    ///  This method does the work of moving the star from one location to another.
    ///
    ///  To move a view around, change its center.  You should only change a view's frame if you are resizing the view.

    func moveStar()
    {
        let currentCenter = self.starImage.center
        
        var destination: CGPoint
        
        if currentCenter.x == 150
        {
            destination = CGPoint(x: 500, y: 500)
        }
        else
        {
            destination = CGPoint(x: 150, y: 250)
        }
        
        self.starImage.center = destination;
    }

    /// This method wraps moveStar in a simple animation block.
    ///
    /// This method uses an explicit argument to specify the animations closure. Compare this with `zoomStarAnimated` which uses a trailing closure for the same method call.

    @IBAction func moveStarAnimated()
    {
        UIView.animate(withDuration: 5.0,
        animations:
        {
            self.moveStar()
        })
    }


    //MARK: - Zoom Star

    /// `zoomStar` follows the same model as `moveStar`.  There's a non-animated method that does the actual work, then a second method that encloses the first method in an animation block.

    func zoomStar()
    {
        var starBounds = self.starImage.bounds
        
        var newSize: CGSize
        
        if starBounds.size.width == 250
        {
            newSize = CGSize(width: 1000, height: 1000)
        }
        else
        {
            newSize = CGSize(width: 250, height: 250)
        }
        
        starBounds.size = newSize
        
        self.starImage.bounds = starBounds
    }

    /// Note the use of a trailing closure here.  The `UIView.animate...` method is the same class method that is used in `moveStarAnimated`, but the trailing closure syntax means that it is not necessary to explicitly identify the `animated` parameter.
    ///
    /// The use of a trailing closure is what is sometimes called "syntactic sugar". The resulting compiled code is exactly the same as if the `animated` argument label had been explicitly used. "Syntac sugar" is a an alternate way of writing code which makes the code easier to read or write, but which does not change the result when the code is compiled.

    @IBAction func zoomStarAnimated()
    {
        UIView.animate(withDuration: 3.5)
        {
            self.zoomStar()
        }
    }

    //MARK: - Fade Star

    /// Fading things in and out is one of the most common animations that you'll use in any app.
    ///
    /// This animation introduces the use of a completion block.  You can use the completion block to schedule actions to occur when the animation finishes. Completion blocks are sometimes used to do housekeeping, such as removing a view that has been faded to transparent. In this method, the completion block is used to schedule a second animation.

    @IBAction func fadeStarAnimated(sender: Any)
    {
        UIView.animate(withDuration: 3,
                       animations:
                        {
                            self.starImage.alpha = 0
                        },
                       completion:
                        { (finished: Bool) in
                            
                            UIView.animate(withDuration: 3)
                            {
                                self.starImage.alpha = 1
                            }
                        })
    }



    //MARK: - Spin Star

    ///  For reasons that will become clear in the Problem Animationsscreen, the star rotation is done as a series of quarter rotations.
    ///  As before, there are two methods:  one to do the work, the other to enclose the first method in an animation block.

    func spinStar()
    {
        self.starImage.transform = self.starImage.transform.rotated(by: 0.5 * CGFloat.pi)
    }


    /// Note that this second method is a recursive method.  It calls itself until repeatedly until the screen's spinCounter property reaches 8.  At that point it resets the counter and stops calling itself.
    ///
    /// This method also checks the `finished` parameter passed to the completion block. If the animation finishes,

    @IBAction func spinStarAnimated()
    {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: .curveLinear,
                       animations:
                        {
                            self.spinStar()
                        },
                       completion:
                        {(finished: Bool) in
                            
                            if !finished
                            {
                                print("Spin Star animation did not complete. Cleaning up.")
                                
                                self.spinCounter = 0
                                self.starImage.transform = CGAffineTransform.identity
                            }
                            else if self.spinCounter == 8
                            {
                                self.spinCounter = 0
                            }
                            else
                            {
                                self.spinStarAnimated()
                            }
                        })
    }


    //MARK: - Twinkle Star

    /// This routine involves a different kind of animation: a Core Animation Basic Animation (CABasicAnimation).  This animation does not alter view properties; it manipulates the properties of the view's Core Animation Layer (CALayer).
    ///
    /// This animation is very expensive in terms of processing power.
    ///
    /// Unlike the UIView animations which have an optional completion block, the CAAnimation and its subclasses use a delegate to take actions when the animation is completed. The `animationDidStop` method which follows this one is called when animation is completed.
    /// 
    /// This animation is done via repeated calls to `changeShadowAnimated`. After the animation started in `changeShadowAnimated` completes, the `animationDidStop` method is used to call `changeShadowAnimated` again.  These calls end when either A) the appropriate number of calls to `changeShadowAnimated` have been made, or B) an animation fails to complete.

    
    @IBAction func changeShadowAnimated()
    {
        self.starImage.layer.shadowOffset = CGSize(width: 0, height:0)
        self.starImage.layer.shadowColor = UIColor.orange.cgColor
        self.starImage.layer.shadowRadius = 30
        
        let targetOpacity: Float = self.starImage.layer.shadowOpacity == 1 ? 0 : 1
        
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.duration = 1.0
        animation.delegate = self
        self.starImage.layer.add(animation, forKey: "shadowOpacity")
        
        self.starImage.layer.shadowOpacity = targetOpacity
    }
    
    /// The `animationDidStop` method is called when the animation started in `changeShadowAnimated` completes. This method is specified in the CAAnimationDelegate protocol. This method is used to call `changeShadowAnimated` to start a new animation.  The calls to `changeShadowAnimated` end when either A) the appropriate number of calls to `changeShadowAnimated` have been made, or B) an animation fails to complete.
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        if flag
        {
            self.twinkleCounter += 1
            
            if self.twinkleCounter == 6
            {
                self.twinkleCounter = 0
            }
            else
            {
                self.changeShadowAnimated()
            }
        }
        else
        {
            print("Twinkle animation did not finish. Cleaning up.")
            
            twinkleCounter = 0
            self.starImage.layer.shadowOpacity = 0
        }
    }

}
