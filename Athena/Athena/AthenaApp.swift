//
//  AthenaApp.swift
//  Athena
//
//  Created by Sai Kambampati on 4/6/22.
//

import SwiftUI
import FirebaseAuth

@main
struct AthenaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser == nil {
                OnboardingOne()
                    .navigationViewStyle(.stack)
            } else {
                RootView()
            }
        }
    }
}
