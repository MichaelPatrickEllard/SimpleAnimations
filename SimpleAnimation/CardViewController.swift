//
//  CardViewController.swift
//  SimpleAnimation
//
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


/*  This screen demonstrates eight animations in sequence.  The first four animations are animations of UIView properties.  The next four animations are view transition animations, which animate the act of replacing an existing subview with a new one.  The animations shown are:
 
 1)  Hiding cards by setting their alpha to zero
 2)  Moving cards in an animated way, with all animations beginning and ending at the same time
 3)  Moving cards in an animated way, with each animation beginning and ending at a different time
 4)  Animating changes in the background color of a view
 5)  Doing a "flip from left" view transition from one view to another
 6)  Doing a "curl up" view transition from one view to another
 7)  Doing a "flip from bottom" view transition from one view to another
 8)  Doing a "cross disolve" view transition from one view to another
 
 Each animation is done using a separate method. In a few cases, sub-methods are used in order to keep the code clear and concise.
 
 The animation methods are managed using a very simple task queue created as part of this class.  */

import UIKit

class CardViewController : UIViewController
{

    //MARK: Properties

    /// The leftmost card on the screen.  Important because it is sometimes treated differently from the other cards.
    @IBOutlet var firstCard: CardView!
    
    /// All of the card views on the screen, including the firstCard.
    @IBOutlet var cards: [CardView]!
    
    /// Used for color change animation
    let blueColor = UIColor(colorLiteralRed: 0, green: 100/255, blue: 155/255, alpha: 1)
    
    /// Used for color change animation
    let pinkColor = UIColor(colorLiteralRed: 1, green: 111/255, blue: 207/255, alpha: 0.6)

    /// Container views which serve as a context for the view transition demos
    var containerViews = [UIView]()
    
    /// Views which are exchanged with card views for the view transition demos
    var flipsides = [UIView]()
    
    /// Allows the user to restart the animation demo once it has completed
    @IBOutlet var replayButton: UIButton!
    
    /// Holds an array of closures to be executed in sequence.
    var tasks = [() -> ()]()
    

    //MARK: -  View Lifecycle Routines

    /// `viewDidLoad` is used for code that should be executed once when the main view and its subviews are loaded from the storyboard, but not again after that.
    /// This method stores the "home" center information for all of our card views. This indicates the default position for the views.

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for card in self.cards
        {
            card.homeCenter = card.center
        }
    }
    
    
    //  `viewWillAppear` is used for operations that should be done every time that the view controller's main view is about to appear onscreen.
    //  An animation from a previous appearance of the screen might have left the views in an altered state, so this setup should be done every time the main view is about to appear.

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        for card in self.cards
        {
            card.backgroundColor = UIColor.white
            card.alpha = 1
        }
        
        self.replayButton.alpha = 0
    }
    
    
    /// `viewDidAppear` is used for operations that should be done as soon as the view appears onscreen. This will be called the first time that a user goes to a screen.  However, it will not be called if the app goes into the background and then is made active again. This screen uses `viewDidAppear` to run the `showAllAnimations` method as soon as the view has appeared on screen.


    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.showAllAnimations()
    }


    //MARK: - Simple View Animations

    //  The following routine moves all views to their "home" positions, which were set in `viewDidLoad`.
    //  To move a view around, change its center.  You should only change a view's frame if you are resizing the view.
    //
    //  Note the completion block, which can be used for housekeeping or to set up another animation.  This method, like all of the other animation methods for this class, calls queueTaskEnded: when it is done.

    func moveCardViewsToHomePositionsAnimated()
    {
        UIView.animate(withDuration: 2.0, animations:
        {
            for card in self.cards
            {
                card.center = card.homeCenter
            }
        },
       completion:
       { (finished: Bool) in
        
            self.queuedTaskEnded(finished: finished)
       })
    }

    /// This routine sets the alpha of all of the card views to zero (except for the first card).
    ///
    /// There are three ways to make a view invisible:
    ///      1)  Set its alpha to zero.  This is always animatable.
    ///      2)  Set its hidden property to true.  This is never animatable.
    ///      3)  Set its background color to [UIColor clearColor].  This may or may not be animatable depending on the type of view you're dealing with.  It usually will not hide your entire view - just the background.
    ///
    /// Note the completion block.  After animating the transition from an alpha of 1.0 to an alpha of 0.0, the views are moved behind the first card and their alpha is restored to 1.0.  Since the firstCard view is the last-added subview, it is drawn last and hides all of the views that are behind it.

    func hideCardsAnimated()
    {
        UIView.animate(withDuration: 1.0, animations:
        {
            for card in self.cards
            {
                if card == self.firstCard
                {
                    card.alpha = 1.0
                }
                else
                {
                    card.alpha = 0.0
                }
            }
        }, completion:
            {(finished: Bool) in
                
            for label in self.cards
            {
                label.center = self.firstCard.homeCenter
                label.alpha = 1.0
            }
        
            self.queuedTaskEnded(finished: finished)
        })
    }

    /// This method is very similar to moveCardViewsToHomePositionsAnimated, except that instead of moving the cards all at once, it moves them one-by-one.
    ///
    /// Previous methods have used UIView's animationWithDuration:animation:completion:.  This method uses UIView's animationWithDuration:delay:options:animation:completion:, which allows us to specify a delay before the animation should be run.  By specifying a different delay for each card, we can move them one-by-one.


    func moveCardsOneByOneAnimated()
    {
        var cardCounter: TimeInterval = 0
        var completionCount = 0
        
        for card in self.cards.reversed()
        {
            card.alpha = 1
            
            UIView.animate(withDuration: 0.5,
                           delay: cardCounter * 0.5,
                           options: .curveEaseOut,
                           animations:
                            {
                                card.center = card.homeCenter
                            },
                           completion:
                            {(finished: Bool) in
                                
                                completionCount += 1
                            
                                if (completionCount == self.cards.count)
                                {
                                    self.queuedTaskEnded(finished :finished)
                                }
                            })
            
            cardCounter += 1
        }
    }


    //  The following method rotates the background colors of our cards from white to blue to pink and then back to white again.
    //
    //  The background colors of UILabels are not animatable.  So this routine changes the card views' backgrounds to ClearColor, creates a backing view for each card, puts the backing view behind each card view, and animates the colors on the backing view.  In the final completion block, the backing views are removed.
    //
    //  Note that this method nests calls to UIView animateWithDuration: in the completion block for previous animations.

    func changeCardColorsAnimated()
        {
            var cardCounter = 0
            
            for card in self.cards
            {
                card.backgroundColor = UIColor.clear
                
                let backingView = UIView(frame: card.frame)
                backingView.backgroundColor = UIColor.clear
                backingView.layer.cornerRadius = card.layer.cornerRadius;
                
                card.superview?.insertSubview(backingView, belowSubview: card)
                
                
                UIView.animate(withDuration: 1.0, delay:0.4 * Double(cardCounter), options: .curveLinear, animations:
                {
                    backingView.backgroundColor = self.blueColor
                },
               completion:
                {(finished: Bool) in
                    
                    UIView.animate(withDuration: 1.0, animations:
                    {
                        backingView.backgroundColor = self.pinkColor
                    },
                   completion:
                   { (finished: Bool) in     //  Start of first nested completion block
                        
                        UIView.animate(withDuration: 1.0, animations:
                        {
                            backingView.alpha = 0;
                        },
                        completion:
                        {(finished: Bool) in
                            
                            backingView.removeFromSuperview()
                            
                            if (card == self.cards.last)
                            {
                                self.queuedTaskEnded(finished: finished)
                            }
                        })
                   })
                })
                
                cardCounter += 1
            }
    }

    //MARK: - View Transition Animations

    /// All of the previous animations methods have used variations on UIView's animateWithDuration: methods.  The next four animations use a different approach - they use UIView transitionWithView... methods.  The transitionWithView:... methods involve three views:
    ///
    ///      A)  A container view.  This view isn't animated per se, but it provides the context in which the animation should occur.  See the flip animations on the ProblemAnimations screen for an example of what can happen if the container view isn't set up appropriately.
    ///      B)  A "from view" this is a current subview of the container view which is going to be removed as a subview of the container view.
    ///      C)  A "to view" this is a view which is going to be added as subview of the container view in place of the "from view."
    ///
    /// While the view transition animations appear very different to the user, the code used to produce them is almost exactly the same.  For this reason, a single demoViewTransition: submethod is used to perform all four different view transition animations.  The only difference between the four is the UIViewAnimationOptions passed to each view.

    func demoViewTransition(options: UIViewAnimationOptions)
    {
        for i in 0..<self.cards.count
        {
            let containerView = self.containerViews[i]
            
            let fromView = self.transitionDemoFromViewForIndex(index: i)
            let toView = self.transitionDemoToViewForIndex(index: i)
            
            UIView.transition(from: fromView, to: toView, duration: 2.5, options: options)
            {(finished: Bool) in
                
                if !finished
                {
                    self.queuedTaskEnded(finished: finished)
                }
                
                if (containerView == self.containerViews.last) {
                    
                    if (!finished)
                    {
                        self.tearDownAfterViewTransitionDemo()
                    }
                    else
                    {
                        self.queuedTaskEnded(finished: finished)
                    }
                }
            }
        }
    }

    func transitionDemoFromViewForIndex(index: Int) -> UIView
    {
        let card = self.cards[index]
        
        return card.superview != nil ? card as UIView : self.flipsides[index]
    }


    func transitionDemoToViewForIndex(index : Int) -> UIView
    {
        let card = self.cards[index]
        
        return card.superview != nil ? self.flipsides[index] : card as UIView
    }


    func demoViewTransitionFlipFromLeft()
    {
        self.demoViewTransition(options: .transitionFlipFromLeft)
    }


    func demoViewTransitionCurlUp()
    {
        self.demoViewTransition(options: .transitionCurlUp)
    }


    func demoViewTransitionFlipFromBottom()
    {
        self.demoViewTransition(options: .transitionFlipFromBottom)
    }


    func demoViewTransitionCrossDissolve()
    {
        self.demoViewTransition(options: .transitionCrossDissolve)
    }


    /// The following method sets up the appropriate container views and "flipside views" in order to do our view transitions.

    func setupForViewTransitionDemo()
    {
        for card in self.cards
        {
            card.backgroundColor = UIColor.white
            
            let containerView = UIView(frame: card.frame)
            
            containerView.backgroundColor = UIColor.white
            
            self.containerViews.append(containerView)
            
            self.view.addSubview(containerView)
            
            card.frame = card.bounds
            
            containerView.addSubview(card)
            
            let flipside = UIImageView(image: UIImage(named:"GoldStar.png"))
            
            flipside.contentMode = .scaleAspectFit;
            
            flipside.frame = card.frame;
            
            flipside.backgroundColor = UIColor.white
            flipside.layer.cornerRadius = card.layer.cornerRadius
            flipside.layer.borderWidth = card.layer.borderWidth
            flipside.layer.borderColor = card.layer.borderColor
        
            self.flipsides.append(flipside)
        }
        
        DispatchQueue.main.async
        {
            self.queuedTaskEnded(finished: true)
        }
    }

    /// This method removes any leftover container views and flipside views from the view transition demos.

    func tearDownAfterViewTransitionDemo()
    {
        print("Tearing down after view transitions")
        
        for eachView in self.flipsides
        {
            if eachView.superview != nil
            {
                eachView.removeFromSuperview()
            }
        }
        
        self.flipsides.removeAll();
        
        if self.containerViews.count > 0
        {
            for i in stride(from: self.containerViews.count - 1, through: 0, by: -1)
            {
                let card = self.cards[i]
                let containerView = self.containerViews[i]
                
                card.frame = containerView.frame
                
                self.view.addSubview(card)
                containerView.removeFromSuperview()
            }
            
            self.containerViews.removeAll()
        }
        
        self.queuedTaskEnded(finished: true)
}

    //MARK: - Task Queue

    /// The methods in this section implement a simple task queue which is used to execute the desired animations in sequence, along with some other necessary maintenance tasks.

    @IBAction func showAllAnimations()
    {
        self.addTask(task: hideReplayButton)
        
        self.addTask(task: hideCardsAnimated)
        
        self.addTask(task: moveCardViewsToHomePositionsAnimated)
        
        self.addTask(task: hideCardsAnimated)
        
        self.addTask(task: moveCardsOneByOneAnimated)
        
        self.addTask(task: changeCardColorsAnimated)
        
        self.addTask(task: setupForViewTransitionDemo)
        
        self.addTask(task: demoViewTransitionFlipFromLeft)
        
        self.addTask(task: demoViewTransitionCurlUp)
    
        self.addTask(task: demoViewTransitionFlipFromBottom)
        
        self.addTask(task: demoViewTransitionCrossDissolve)
        
        self.addTask(task: tearDownAfterViewTransitionDemo)
        
        self.addTask(task: showReplayButtonAnimated)
        
        self.runNextTask()
    }


    func runNextTask()
    {
        if self.tasks.isEmpty
        {
            NSLog("All done. The task array is empty");
        }
        else
        {
            let nextAnimation = self.tasks.remove(at: 0)
            
            nextAnimation()
        }
    }

    func addTask(task: @escaping () -> ())
    {
        self.tasks.append(task)
    }

    /// If a task didn't complete, empty the task queue so that we can start from scratch next time.  Animations might not complete if the app went into the background or if another screen became active.
    ///
    /// If the task did complete, start the next task (if any).

    func queuedTaskEnded(finished: Bool)
    {
        if !finished
        {
            NSLog("Task did not complete. Cleaning up")
            
            self.tasks.removeAll()
            
            self.showReplayButton()
        }
        else
        {
            self.runNextTask()
        }
    }

    //MARK: - Replay Button
    
    func showReplayButtonAnimated()
    {
        UIView.animate(withDuration: 0.25, animations:
        {
            self.showReplayButton()
        },
        completion:
        {(finished: Bool) in
            
            self.queuedTaskEnded(finished: finished)
        })
    }

    func showReplayButton()
    {
        self.replayButton.alpha = 1
    }

    func hideReplayButton()
    {
        UIView.animate(withDuration: 0.5, animations:
        {
            self.replayButton.alpha = 0
        },
        completion:
        {(finished: Bool) in
            
            self.queuedTaskEnded(finished: finished)
        })
    }
}
