//
//  PulsaMatchaSpaceApp.swift
//  PulsaMatchaSpace
//

import SwiftUI

@main
struct PulsaMatchaSpaceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate)
                .preferredColorScheme(.dark)
        }
    }
}
