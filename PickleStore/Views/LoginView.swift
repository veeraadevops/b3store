//
//  LoginView.swift
//  PickleStore
//
//  Created by V Akula on 13/11/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Login")
                .font(.title2)
                .fontWeight(.bold)
            
            // Email Field
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Forgot Password
            HStack {
                Spacer()
                Button(action: {
                    showForgotPassword = true
                }) {
                    Text("Forgot Password?")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            
            // Login Button
            Button(action: {
                authViewModel.login(email: email, password: password)
            }) {
                Text("Login")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Divider with "OR"
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Social Login Buttons
            VStack(spacing: 12) {
                // Google Sign In
                Button(action: {
                    // TODO: Implement Google Sign In
                    authViewModel.errorMessage = "Google Sign-In coming soon!"
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Continue with Google")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                
                // Facebook Sign In
                Button(action: {
                    // TODO: Implement Facebook Sign In
                    authViewModel.errorMessage = "Facebook Sign-In coming soon!"
                }) {
                    HStack {
                        Image(systemName: "f.circle.fill")
                            .font(.title3)
                        Text("Continue with Facebook")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.23, green: 0.35, blue: 0.60))
                    .cornerRadius(10)
                }
                
                // Apple Sign In
                Button(action: {
                    // TODO: Implement Apple Sign In
                    authViewModel.errorMessage = "Apple Sign-In coming soon!"
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Continue with Apple")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()
                
                Text("Reset Password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    sendResetEmail()
                }) {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Password Reset", isPresented: $showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendResetEmail() {
        // TODO: Implement Firebase password reset
        alertMessage = "Password reset instructions sent to \(email)"
        showAlert = true
    }
}
