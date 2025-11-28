//
//  AuthViewModel.swift
//  PickleStore
//
//  Created by V Akula on 13/11/2025.
//


import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage = ""

    func login(email: String, password: String) {
        print("🔐 Attempting login for: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Login error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.isLoggedIn = false
                } else {
                    print("✅ Login successful for: \(authResult?.user.email ?? "unknown")")
                    self?.errorMessage = ""
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func register(email: String, password: String) {
        print("📝 Attempting registration for: \(email)")
        
        // Validate Firebase is configured
        guard Auth.auth().app != nil else {
            print("❌ Firebase Auth not configured!")
            DispatchQueue.main.async {
                self.errorMessage = "Firebase is not configured. Check GoogleService-Info.plist"
            }
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Registration error: \(error.localizedDescription)")
                    print("❌ Error details: \(error)")
                    self?.errorMessage = error.localizedDescription
                    self?.isLoggedIn = false
                } else {
                    print("✅ Registration successful for: \(authResult?.user.email ?? "unknown")")
                    self?.errorMessage = ""
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func logout() {
        print("🚪 Attempting logout")
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.errorMessage = ""
                print("✅ Logout successful")
            }
        } catch {
            print("❌ Logout error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}