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
//      -   a second method that wraps the first method in an animation block which is passed to the UIView class to execute.
//
//  For example, moveStar does the work of moving the star, moveStarAnimated: calls moveStar from within an animation block.
//
//  This division is useful, since sometimes you want to manipulate views while your view is offscreen and preparing to go on screen. In this case, you don't want to animate something that the user can't see.
//  Also helpful to note: when you wrap a method call in a UIView animation block, view property changes in sub-methods are included as well.
//
//  This screen also demonstrates that you can have multiple animations running on different properties of the same view at the same time, even if the start and stop times for the animations are not the same.  Thus, you can start a second animation while the first animation is still running, and both animations will run at the same time and each will finish according to the duration you set for that animation.  You can have a number of different animations running at once, each with a different start and stop time.
//
//  However, you cannot have two animations running on the same property of the same view at the same time.  Thus, you can have a move animation running on a view at the same time that you have a fade animation running. However, if you start a second move animation while a move animation is running, the first move animation will immediately terminate and the second will start.
//  A final thing to note: some of these animations are more expensive than others.  In particular, the twinkle animation is very expensive.  If you start a twinkle animation at the same time that other animations are running, performance will become noticeably bad.





class StarViewController : UIViewController
{
    @IBOutlet var starImage: UIImageView!    // Thie UIImageView manipulated in all of this screen's animation demos
    var spinCounter: Int = 0                 //  Used by the SpinStarAnimated: method, keeps track of how many quarter turns the star has spun


//MARK: - Initializers

//  The only custom behavior in our initializer is setting the title and icon for this screen's tab in the tab bar controller.  Everything else is inherited from superclasses.
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = NSLocalizedString("Star", comment: "Star")
        self.tabBarItem.image = UIImage(named: "StarIcon")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")  // Should be upgraded
    }
    
    
    //  viewDidLoad is used for code that should be executed once when the main view and its subviews are loaded from the nib file, but not again after that.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.starImage.layer.shadowOffset = CGSize(width: 0, height:0)
        self.starImage.layer.shadowColor = UIColor.orange.cgColor
        self.starImage.layer.shadowRadius = 30

    }
    

//MARK: - Move Star

//  This method does the work of moving the star from one location to another.
//  To move a view around, change its center.  You should only change a view's frame if you are resizing the view.

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

//  This method wraps moveStar in a simple animation block.

    @IBAction func moveStarAnimated()
    {
        UIView.animate(withDuration: 5.0,   // Using an explicit argument for animations rather than a trailing closure
        animations:
        {
            self.moveStar()
        })
    }


//MARK: - Zoom Star

//  zoomStar follows the same model as moveStar.  There's a non-animated method that does the actual work, then a second method that encloses the first method in an animation block.

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



    @IBAction func zoomStarAnimated()
    {
        UIView.animate(withDuration: 3.5)      // Note the use of a trailing closure here.
        {
            self.zoomStar()
        }
    }

//MARK: - Fade Star

//  Fading things in and out is one of the most common animations that you'll use in any app.
//  This animation introduces the use of a completion block.  We can use the completion block to schedule actions to occur when our animation finishes.
//  Sometimes completion blocks are used to do housekeeping, such as removing a view that has been faded to transparent.
//  In this case, we use the completion block to schedule a second animation.

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

//  For reasons that will become clear in the Problem Animations screen, we need to do our star rotation as a series of quarter rotations.
//  As before, we have two methods:  one to do the work, the other to enclose the first method in an animation block.

    func spinStar()
    {
        self.starImage.transform = self.starImage.transform.rotated(by: 0.5 * CGFloat.pi)
    }


//  Note that this second method is a recursive method.  It calls itself until repeatedly until the screen's spinCounter property reaches 8.  At that point it resets the counter and stops calling itself.

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
                            self.spinCounter += 1
                            
                            self.spinCounter == 8 ? self.spinCounter = 0 : self.spinStarAnimated()
                        })
    }


//MARK: - Twinkle Star

//  This routine involves a different kind of animation.  We're not just altering view properties here, we're manipulating the properties of the view's Core Animation layer.
//  Three notes on this animation:
//      1) We're not using UIView block-based animations here.  Instead, management of this animation is done by the view's CALayer.
//      2) We set up some of the layer's shadow properties in the viewDidLoad method.  Without that prep work, this animation wouldn't work.
//      3) This animation is very expensive.

    func changeShadow()
    {
        let targetOpacity: Float = self.starImage.layer.shadowOpacity == 1 ? 0 : 1
        
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.duration = 1.0
        self.starImage.layer.add(animation, forKey: "shadowOpacity")
        
        self.starImage.layer.shadowOpacity = targetOpacity
    }


    @IBAction func changeShadowAnimated()
    {
        self.changeShadow()
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)
        {
            self.changeShadow()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2)
        {
            self.changeShadow()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3)
        {
            self.changeShadow()
        }
    }
}
