//
//  ContentView.swift
//  PickleStore
//
//  Created by V Akula on 13/11/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        if authViewModel.isLoggedIn {
            MainTabView()
                .environmentObject(authViewModel)
        } else {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }
}

// MARK: - Main Tab View with Navigation
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var cartViewModel = CartViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Products Tab
            NavigationView {
                ProductListView(viewModel: ProductListViewModel(), cartViewModel: cartViewModel, selectedTab: $selectedTab)
                    .navigationTitle("B3 Stores")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Products", systemImage: "cart.fill")
            }
            .tag(0)
            
            // Cart Tab
            NavigationView {
                CartView(selectedTab: $selectedTab)
                    .environmentObject(cartViewModel)
            }
            .tabItem {
                Label("Cart", systemImage: "bag.fill")
            }
            .badge(cartViewModel.totalItems > 0 ? "\(cartViewModel.totalItems)" : nil)
            .tag(1)
            
            // Order History Tab
            NavigationView {
                OrderHistoryView()
                    .navigationTitle("My Orders")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Orders", systemImage: "list.bullet.rectangle")
            }
            .tag(2)
            
            // Profile Tab
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
            .tag(3)
        }
        .accentColor(.green)
    }
}

// MARK: - Authentication View (Login/Register)
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Logo/Header
                VStack(spacing: 8) {
                    Image("app-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("B3 Stores")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("We bring all the delicious goodness of India")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Login Section
                LoginView()
                
                Divider()
                    .padding(.vertical, 20)
                
                // Register Section
                RegisterView()
                
                // Error Message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
    }
}

// MARK: - Profile View (Placeholder)
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("B3 Customer")
                            .font(.headline)
                        Text("We bring all the delicious goodness of India")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("Account") {
                NavigationLink(destination: Text("Saved Addresses")) {
                    Label("Saved Addresses", systemImage: "mappin.circle")
                }
                
                NavigationLink(destination: Text("Payment Methods")) {
                    Label("Payment Methods", systemImage: "creditcard")
                }
                
                NavigationLink(destination: Text("Notifications")) {
                    Label("Notifications", systemImage: "bell")
                }
            }
            
            Section("Support") {
                NavigationLink(destination: Text("Help & FAQ")) {
                    Label("Help & FAQ", systemImage: "questionmark.circle")
                }
                
                NavigationLink(destination: Text("Contact Us")) {
                    Label("Contact Us", systemImage: "envelope")
                }
            }
            
            Section {
                Button(action: {
                    authViewModel.logout()
                }) {
                    HStack {
                        Label("Logout", systemImage: "arrow.right.square")
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ContentView()
}
