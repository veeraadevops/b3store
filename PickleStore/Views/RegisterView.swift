//
//  RegisterView.swift
//  PickleStore
//
//  Created by V Akula on 13/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.bold)
            
            // Email Field
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Register Button
            Button(action: {
                if password == confirmPassword {
                    authViewModel.register(email: email, password: password)
                } else {
                    authViewModel.errorMessage = "Passwords do not match"
                }
            }) {
                Text("Register")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
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
            
            // Social Sign Up Buttons
            VStack(spacing: 12) {
                // Google Sign Up
                Button(action: {
                    // TODO: Implement Google Sign Up
                    authViewModel.errorMessage = "Google Sign-Up coming soon!"
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Sign up with Google")
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
                
                // Facebook Sign Up
                Button(action: {
                    // TODO: Implement Facebook Sign Up
                    authViewModel.errorMessage = "Facebook Sign-Up coming soon!"
                }) {
                    HStack {
                        Image(systemName: "f.circle.fill")
                            .font(.title3)
                        Text("Sign up with Facebook")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.23, green: 0.35, blue: 0.60))
                    .cornerRadius(10)
                }
                
                // Apple Sign Up
                Button(action: {
                    // TODO: Implement Apple Sign Up
                    authViewModel.errorMessage = "Apple Sign-Up coming soon!"
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Sign up with Apple")
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
    }
}