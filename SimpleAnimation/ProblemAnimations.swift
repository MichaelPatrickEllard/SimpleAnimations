//
//  ProblemAnimations.swift
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 7/20/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

//  The Problems screen illustrates some problems that I or my students have encountered while doing animations. In each case, there is a demonstration of a working animation, along with one or more variants of the same animation that don't work as desired.

//  This screen was created for a presentation that I did at iOSDevCamp in 2012.

//  To keep the code simple and easy-to-read, I have used named methods instead of closures with capture lists.  This does mean that there can be strong reference cycles created while animations are running, but this should not cause any long-term problems.

//  In most cases, the code lacks protections that would prevent a user from restarting an animation method that is already running. This is acceptable for a demonstration project like this where one of the goals is to make the code as simple as possible.  


import UIKit

class ProblemAnimations: UIViewController
{
    //MARK: - Properties

    @IBOutlet var nonFadingStar: UIImageView!
    @IBOutlet var blinkStar: UIImageView!
    @IBOutlet var blinkHelperView: UIView!
    @IBOutlet var fadeStar: UIImageView!

    @IBOutlet var rotateColorWorkingView: UIView!
    @IBOutlet var rotateColorProblemView: UIView!
    var colors = [UIColor]()
   
    @IBOutlet var flipCorrectlyView: UIView!
    @IBOutlet var flipTooMuchView: UIView!
   
    @IBOutlet var correctStar: UIImageView!
    @IBOutlet var immobileStar: UIImageView!
    @IBOutlet var wrongWayStar: UIImageView!
    @IBOutlet var jerkyStar: UIImageView!
    var correctRotateCounter = 0
    var jerkyRotateCounter = 0

    //MARK: - Star Fade examples
    
    /// This a working animation. It uses UIView animations to animate changing a star's `alpha` property to zero.  When the animation completes, the `alpha` value is animated back to 1.
    
    @IBAction func fadeTapped()
    {
        UIView.animate(withDuration: 1.0,
                       animations:
                        {
                            self.fadeStar.alpha = 0
                        },
                       completion:
                        {(finished: Bool) in
                            self.fadeStar.alpha = 1
                        })
    }


    /// This animation doesn't work. The star doesn't fade out or even become hidden.  On older devices / versions of iOS it may flicker for a second.
    ///
    /// The code is exactly the same as the working fadeTapped function, except that it adjusted the `isHidden` property instead of the alpha property.  `isHidden` is not an animatable property, so there is nothing animatable in this code.  Thus, UIView applies the `isHidden` property immediately.  UIView doesn't take a full second to do the initial animation, since there's nothing to animate for the requested duration.  Thus, it goes directly to the completion block, where there's also nothing to animate.  The result is that the star might flicker out (i.e. become hidden) for a fraction of a second, and then flicker back immediately. On modern hardward / versions of iOS, you usually cannot even see this happen.
    ///
    /// The lesson to take away here is that not every UIView or CALayer property is animatable.  The documentation is usually pretty clear about which properties are animatable and which aren't. If you're not sure, check the documentation or do a quick using some test code.


    @IBAction func doNotFadeTapped()
    {
        UIView.animate(withDuration: 1.0,
                       animations:
                        {
                            self.nonFadingStar.isHidden = true
                        },
                       completion:
                        {(finished: Bool) in
                            self.nonFadingStar.isHidden = false
                        })
    }
    
            
    /// This animation doesn't work. In this example, the star doesn't fade. It just blinks out and then reappears a second later.
    ///
    /// The code here is essentially the same as the code in `doNotFade`, but there is also a change to an animatable property along with the request to set the star's `isHidden` property.  The animatable change is a barely noticable color change to a tiny helper view, but this is enough so that the initial animation block will take the full 1.0 second duration to complete before executing the completion block.
    ///
    /// While the animation block does take a second to complete, `isHidden` is not animatable and therefore changes to it take effect as soon as the animation block starts.
        
        
    @IBAction func blinkTapped()
    {
        UIView.animate(withDuration: 1.0,
                       animations:
                        {
                            self.blinkStar.isHidden = true
                            self.blinkHelperView.backgroundColor = UIColor.darkGray
                        },
                       completion:
                        {(finished: Bool) in
                            self.blinkStar.isHidden = false
                            self.blinkHelperView.backgroundColor = UIColor.black
                        })
    }
    
    //MARK: - Color Transitions
    
    /// This routine illustrates a way to do a series of color transitions, one following another. When this function is initially called, it creates an array of colors, and then one by one removes colors from the start of the array and animates changing the view's background to the removed color.  This is a recursive function which continues to call itself as long as there are colors remaining in the color array and as long as each animation finishes.
    ///
    /// This function makes use of the `finished` parameter which is sent to the completion block for animations. If the views being animated go offscreen, then the current animation will not complete and the `finished` parameter is set to `false`. In this case, it doesn't make sense to keep trying to do additional animations, so the method cleans up by setting the view to the last color in the color array and then empties the color array so that the view controller will be ready to start fresh if the views come back onscreen again and the method is called a second time.
    
    
    @IBAction func rainbowColorTransition()
    {
        if colors.isEmpty
        {
            colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple, UIColor.black]
        }
        
        UIView.animate(withDuration: 1.0,
                       animations:
                        {
                            self.rotateColorWorkingView.backgroundColor = self.colors.remove(at: 0)
                        },
                       completion:
                        {(finished: Bool) in
                            
                            if finished && !self.colors.isEmpty
                            {
                                self.rainbowColorTransition()
                            }
                            else if !self.colors.isEmpty
                            {
                                print("Rainbow Color Transition animation did not finish. Cleaning up.")
                                
                                self.rotateColorWorkingView.backgroundColor = self.colors.last
                                
                                self.colors.removeAll()
                            }
                        })
    }


    /// The following code appears to transition through a series of colors, but that is not what the user sees.  UIView only animates one change to a particular property at a time. A new animation request for a property that is already being animated will cancel the existing animation and replace it with the new animation. Since the same animatable property is being changed multiple times in the code below, all of the changes except the last change are ignored.

    @IBAction func singleColorTransition()
    {
        UIView.animate(withDuration: 1.5)
        {
            self.rotateColorProblemView.backgroundColor = UIColor.black
            self.rotateColorProblemView.backgroundColor = UIColor.red
            self.rotateColorProblemView.backgroundColor = UIColor.orange
            self.rotateColorProblemView.backgroundColor = UIColor.yellow
            self.rotateColorProblemView.backgroundColor = UIColor.green
            self.rotateColorProblemView.backgroundColor = UIColor.blue
            self.rotateColorProblemView.backgroundColor = UIColor.purple
            self.rotateColorProblemView.backgroundColor = UIColor.black
        }
    }
    

    //MARK: - Flip Animations
    
    /// This method works correctly.  It creates a new view, and flips to it. The user sees a small blue square flip in an appropriate area of the screen.
    ///
    /// An important thing that makes this method work is that the `flipCorrectlyView` has a backing superview which is exactly the same size. This type of view transition occurs in the context of its superview, so it is important to have an appropriately sized super view.
    
    @IBAction func flipCorrectlyPressed()
    {
        let copiedView = UIView(frame:self.flipCorrectlyView.frame)
        copiedView.backgroundColor = self.flipCorrectlyView.backgroundColor
        
        UIView.transition(from: self.flipCorrectlyView,
                          to: copiedView,
                          duration: 1.0,
                          options: .transitionFlipFromLeft)
        {(finished: Bool) in
            self.flipCorrectlyView = copiedView
        }
    }

    /// This method does not work correcly.  The problem is that the transition occurs in the context of the superview of the view being transitioned away from.  Since the superview of the view being transitioned away from is the ProblemViewController's main view, the whole screen flips.
    ///
    /// Note that the code for this method is essentially the same as the code for `flipCorrectlyPressed`.  In this case, the problem isn't in the code itself.  Instead, the problem is in the view hierarchy.

    @IBAction func flipTooMuchPressed()
    {
        let copiedView = UIView(frame:self.flipTooMuchView.frame)
        copiedView.backgroundColor = self.flipTooMuchView.backgroundColor
        
        UIView.transition(from: self.flipTooMuchView,
                          to: copiedView,
                          duration: 1.0,
                          options: .transitionFlipFromLeft)
        {(finished: Bool) in
            self.flipTooMuchView = copiedView
        }
    }
    
    
    //MARK: - Spinning Animations
    
    /// This is a utility function which is used by the various star rotation functions (both working and not working)

    func spinStar(star: UIView, rotations: CGFloat)
    {
        star.transform = star.transform.rotated(by: rotations * 2 * CGFloat.pi)
    }
    
    /// This method does a series of eight 1/4 turn rotations.  This works smoothly because the the animation curve is set to UIViewAnimationOptionCurveLinear.
    ///
    /// This is a recursive method that will call itself until all of the rotations are completed.  It checks the `finished` value passed to the completion block to make sure that the previous animation completed.  If the previous animation did not complete, then no new animations are attempted and the star position and animation counter are reset so that the view controller is ready to start again if the method is called a second time.
    
    @IBAction func correctRotatePressed()
    {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: .curveLinear,
                       animations:
                        {
                            self.spinStar(star: self.correctStar, rotations: 0.25)
                        },
                       completion:
                        {(finished: Bool) in
                            
                            if !finished
                            {
                                print("Correct Rotate animation did not complete. Cleaning up.")
                                
                                self.correctStar.transform = CGAffineTransform.identity
                                self.correctRotateCounter = 0
                            }
                            else
                            {
                                self.correctRotateCounter += 1
                                
                                if self.correctRotateCounter == 8
                                {
                                    self.correctRotateCounter = 0
                                }
                                else
                                {
                                    self.correctRotatePressed()
                                }
                            }
                    })
    }
    
    
    /// This animation attempts to do a 360° rotation, but the user will not see any change.  The problem is that UIView tries to optimize the animation as much as possible, so it compares the end state with the beginning state.  A full rotation will mean that the end state and beginning state are the same, so UIView optimizes this animation by simply not moving the star at all.
        
    @IBAction func doNotRotatePressed()
    {
        UIView.animate(withDuration: 1.0)
        {
            self.spinStar(star:self.immobileStar, rotations:1)
        }
    }
    
    /// This animation works in current versions of iOS, but it has problems under iOS 7 and earlier.  In this case, we're doing series of rations that take the star exactly 180° - 1/2 way around the circle.  UIView looks at the beginning state and end state, and optimizes how to get from the beginning state to the end state.
    ///
    /// Under iOS 7.1 and earlier, In doing the initial rotate, it goes counter-clockwise.  However, if you rotate it again, it will go clockwise the next time.
    ///
    /// Under iOS 8.1, In doing the initial rotate, it goes clockwise for both rotations.
        
    @IBAction func wrongWayRotatePressed()
    {
        UIView.animate(withDuration: 1.0)
        {
            self.spinStar(star:self.wrongWayStar, rotations:0.5)
        }
    }
        
    /// This method does a series of eight 1/4 turn rotations.  This works, but the animation is jerky. The animation is jerky because the default for the animation curve is "ease in / ease out", meaning that the animations will go slowly at the beginning and end of the animation, then more quickly in the middle.  In an animation that is really a series of animations chained together, this causes jerky updating. The solution is to use animateWithDuration:delay:options:animations:completion: so that you can specify to use UIViewAnimationOptionCurveLinear. If you don't specify this, the default is UIViewAnimationCurveEaseInOut)
    ///
    /// This is a recursive method that will call itself until all of the rotations are completed.  It checks the `finished` value passed to the completion block to make sure that the previous animation completed.  If the previous animation did not complete, then no new animations are attempted and the star position and animation counter are reset so that the view controller is ready to start again if the method is called a second time.
        
    @IBAction func jerkyRotatePressed()
    {
        UIView.animate(withDuration: 1.0,
                       animations:
                        {
                            self.spinStar(star: self.jerkyStar, rotations: 0.25)
                        },
                       completion:
                        {(finished: Bool) in
                            
                            if !finished
                            {
                                print("Jerky Rotate animation did not complete. Cleaning up")
                                
                                self.jerkyStar.transform = CGAffineTransform.identity
                                self.jerkyRotateCounter = 0
                            }
                            else
                            {
                                self.jerkyRotateCounter += 1
                                
                                if self.jerkyRotateCounter == 8
                                {
                                    self.jerkyRotateCounter = 0
                                }
                                else
                                {
                                    self.jerkyRotatePressed()
                                }
                            }
                        })
        }
}
