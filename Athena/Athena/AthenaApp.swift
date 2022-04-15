//
//  AthenaApp.swift
//  Athena
//
//  Created by Sai Kambampati on 4/6/22.
//

import SwiftUI

@main
struct AthenaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
//            OnboardingOne()
        }
    }
}
