/**
* @file AppDelegate.swift
* @brief LWPrintSampleSwift AppDelegate Class definition
* @par Copyright:
* Copyright (C) SEIKO EPSON CORPORATION 2019. All rights reserved.<BR>
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: public member
    var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    // MARK: UIApplicationDelegate
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let integerSize = MemoryLayout<NSInteger>.size
        if integerSize >= 8
        {
            print("Running by 64bit.")
        }
        else
        {
            print("Running by 32bit.")
        }
        
        if #available(iOS 8.0, *)
        {
            let types: UIUserNotificationType = [.sound, .alert]
            let userNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(userNotificationSettings)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        if let _viewController = window!.rootViewController as? ViewController
        {
            if _viewController.getProcessing() == false
            {
                return
            }
            
            let app = UIApplication.shared
            assert(bgTask == UIBackgroundTaskIdentifier.invalid)
            
            bgTask = app.beginBackgroundTask(expirationHandler: { () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if self.bgTask != UIBackgroundTaskIdentifier.invalid
                    {
                        app.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.bgTask.rawValue))
                        self.bgTask = UIBackgroundTaskIdentifier.invalid
                    }
                })
            })
            
            DispatchQueue.global(qos: .default).async(execute: { () -> Void in
                
                while _viewController.getProcessing() == true && self.bgTask != UIBackgroundTaskIdentifier.invalid
                {
                    Thread.sleep(forTimeInterval: 2.0)
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    if self.bgTask != UIBackgroundTaskIdentifier.invalid
                    {
                        app.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.bgTask.rawValue))
                        self.bgTask = UIBackgroundTaskIdentifier.invalid
                    }
                })
            })
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        let app = UIApplication.shared
        DispatchQueue.main.async(execute: { () -> Void in
            if self.bgTask != UIBackgroundTaskIdentifier.invalid
            {
                app.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.bgTask.rawValue))
                self.bgTask = UIBackgroundTaskIdentifier.invalid
            }
        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
