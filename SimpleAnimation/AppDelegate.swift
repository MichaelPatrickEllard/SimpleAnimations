//
//  AppDelegate.swift
//  SimpleAnimation
//
//  Created by Rescue Mission Software on 4/20/17.
//
//

@UIApplicationMain class AppDelegate : UIResponder, UIApplicationDelegate, UITabBarControllerDelegate
{
    var window: UIWindow?

    var tabBarController: UITabBarController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.tabBarController = UITabBarController()
        self.tabBarController.viewControllers = [StarViewController(), CardViewController(), ProblemAnimations()]
        
        self.window?.rootViewController = self.tabBarController
        self.window?.makeKeyAndVisible()
        return true
    }

}
