Mike Ellard's Simple Animations
===============================

This project demonstrates some iOS animations.  The animations here are teaching tools.  They are examples that have been made as simple as possible in order to demonstrate basic animation techniques.   

The project shows three screens in a tab bar controller:

-	The first screen (Star) is a set of very simple animations that users can control via use of buttons. 

-	The second screen (Cards) is a general demonstration of a variety of iOS animations, along with commented code that explains each technique.

-	The third screen (Problems) illustrates some problems that I or my students have encountered while doing animations, and the comments in the code explain why some animations work while others don't.  In each case, there is a demonstration of a working animation, along with one or more variants of the same animation that don't work as desired.  

The Star and Card screens were originally written for a class that I taught at UCSC's Silicon Valley Extension.  The Problems screen was written for a presentation that I did at iOS Dev Camp in 2012.   

©2012, 2014 Michael Patrick Ellard

This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


-----


Version 2.0 Updates (Work-in-Progress, December 2014)

-   Project is being converted from Objective-C to Swift (in progress)
-	Modernization of Objective-C code
-	Removed speedSetting static variable from project files.  This variable was never really used, and taking it out makes the code a little simpler.
-	Removed the "Flip Too Little" example from the Problem Animations screen.  This animation demonstrated a problem that occurred in earlier versions of Xcode if some similarly named UIKit enumerations were used incorrectly.  Modern versions of Xcode flag this problem with a warning.  
-	Converted "About this Project.rtf" to "README.md"
-   Renamed FirstViewController and related files to CardViewController. Renamed SecondViewController and related files to StarViewController
-   Simplified SALetterLabel class, made it a child of UILabel, and renamed it to CardView
-   Complete re-write of CardViewController.  Broke up some longer methods and eliminated some sub-methods so that each of the eight animation demos is done by a concise method which is responsible only for that animation demo.
-   Upgraded documentation of StarViewController and CardViewController screen
-   Added "Replay" button to CardViewController screen
-   Reordered screens in tab bar controller so that Star comes first, followed by Cards, followed by Problems. This follows a logical progression where the simplest screen is first, and more complex screens come later.

Version 1.2 Updates (July 28, 2012)

-	Added notes to each screen xib identifying where the code underlying the screen can be found
-	On the Star screen, changed the background color of the star from white to ClearColor so that the twinkle effect would work better
-	Added a Fade animation to the Star screen
-	Changed the deployment target to iOS 4.0
-	Changed one weak property to strong in order to be iOS 4 compatible
-	Changed the code in the rotateColors: method to make it more concise and flexible.  
-	Wrote some additional comments for the Star Animations screen.
-	Added descriptive labels to the Star screen and the Problems screen to help viewers understand the animations on each screen

Version 1.1 Updates (July 25, 2012).

-	Improved the commenting in the ProblemAnimations.m file
-	Made the "blink star" code a little simpler and easier to understand
-	Altered the colors on the color rotate example to make the behavior easier to see and understand
-	Changed the ProblemAnimations.xib file so that the working animations are first in the series, followed by the problem animations.  In the previous version, the successful animations were last.  

Version 1.0 (July 21, 2012)
