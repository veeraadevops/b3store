//
//  PickleStoreApp.swift
//  PickleStore
//
//  Created by V Akula on 13/11/2025.
//

import SwiftUI
import FirebaseCore

@main
struct PickleStoreApp: App {
    init() {
        // Print detailed Firebase initialization info
        print("🔥 Attempting to configure Firebase...")
        
        // Check if GoogleService-Info.plist exists in bundle
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ GoogleService-Info.plist found at: \(path)")
        } else {
            print("❌ GoogleService-Info.plist NOT FOUND in bundle!")
            print("📦 Bundle path: \(Bundle.main.bundlePath)")
        }
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configured successfully")
        } else {
            print("ℹ️ Firebase already configured")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
