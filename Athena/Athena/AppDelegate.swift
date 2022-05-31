//
//  AppDelegate.swift
//  Athena
//
//  Created by Sai Kambampati on 4/9/22.
//

import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }
}
