//
//  AppDelegate.swift
//  VPNApp
//
//  Created by Munib Hamza on 12/04/2023.
//

import UIKit
import StoreKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window: UIWindow = {
        let w = UIWindow()
        w.backgroundColor = .white
        w.makeKeyAndVisible()
        return w
    }()    /// set orientations you want to be allowed in this property by default

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IAPService.instance.loadProducts()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if !DataManager.shared.isOpeningDateSet {
            DataManager.shared.isOpeningDateSet = true
        }
        SKPaymentQueue.default().add(IAPService.instance)
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPService.instance)
    }

}

