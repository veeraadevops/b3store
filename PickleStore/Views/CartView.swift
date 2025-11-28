//
//  CartView.swift
//  PickleStore
//
//  Shopping cart interface
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Binding var selectedTab: Int
    @State private var showCheckout = false
    
    var body: some View {
        VStack(spacing: 0) {
            if cartViewModel.cartItems.isEmpty {
                // Empty Cart State
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "cart")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add some delicious pickles to get started!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            } else {
                // Cart Items List
                List {
                    ForEach(cartViewModel.cartItems) { item in
                        CartItemRow(item: item, viewModel: cartViewModel)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let item = cartViewModel.cartItems[index]
                            cartViewModel.removeFromCart(item.id)
                        }
                    }
                    
                    // Order Summary Section
                    Section("Order Summary") {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text("$\(cartViewModel.cartSubtotal, specifier: "%.2f")")
                        }
                        
                        HStack {
                            Text("Delivery Charges")
                            Spacer()
                            Text("$\(cartViewModel.totalDeliveryCharges, specifier: "%.2f")")
                        }
                        
                        HStack {
                            Text("Total")
                                .fontWeight(.bold)
                            Spacer()
                            Text("$\(cartViewModel.cartTotal, specifier: "%.2f")")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .font(.title3)
                    }
                }
                .listStyle(.insetGrouped)
                
                // Checkout Button
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        showCheckout = true
                    }) {
                        HStack {
                            Text("Proceed to Checkout")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("$\(cartViewModel.cartTotal, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                }
                .background(Color(.systemBackground))
            }
            
            // Success Message
            if !cartViewModel.successMessage.isEmpty {
                Text(cartViewModel.successMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
                    .transition(.move(edge: .top))
            }
        }
        .navigationTitle("Cart (\(cartViewModel.totalItems))")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !cartViewModel.cartItems.isEmpty {
                    Button(action: {
                        cartViewModel.clearCart()
                    }) {
                        Text("Clear")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            CheckoutView(cartViewModel: cartViewModel, selectedTab: $selectedTab)
        }
    }
}

// MARK: - Cart Item Row Component
struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var viewModel: CartViewModel
    
    // Get the current item from viewModel to ensure we have the latest quantity
    private var currentItem: CartItem? {
        viewModel.cartItems.first(where: { $0.id == item.id })
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            Image(item.product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text("$\(item.product.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(item.product.defaultVariant.weightLabel)
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                
                // Quantity Stepper
                HStack(spacing: 12) {
                    Button(action: {
                        if let current = currentItem {
                            let newQuantity = current.quantity - 1
                            if newQuantity > 0 {
                                viewModel.updateQuantity(for: item.id, quantity: newQuantity)
                            } else {
                                viewModel.removeFromCart(item.id)
                            }
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor((currentItem?.quantity ?? 1) > 1 ? .green : .gray)
                            .font(.title2)
                    }
                    .disabled((currentItem?.quantity ?? 1) <= 1)
                    
                    Text("\(currentItem?.quantity ?? item.quantity)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        if let current = currentItem {
                            viewModel.updateQuantity(for: item.id, quantity: current.quantity + 1)
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            Spacer()
            
            // Item Total
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(currentItem?.subtotal ?? item.subtotal, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Button(action: {
                    viewModel.removeFromCart(item.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Checkout View
struct CheckoutView: View {
    @ObservedObject var cartViewModel: CartViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var orderViewModel = OrderViewModel()
    @Binding var selectedTab: Int // Add binding to control parent tab
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var city = ""
    @State private var postcode = ""
    @State private var isLookingUpPostcode = false
    @State private var postcodeMessage = ""
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !postcode.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".") &&
        phoneNumber.count >= 10
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Order Summary
                Section(header: Text("Order Summary")) {
                    ForEach(cartViewModel.cartItems) { item in
                        HStack {
                            Text(item.product.name)
                            Spacer()
                            Text("\(item.quantity) × $\(item.product.price, specifier: "%.2f")")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("$\(cartViewModel.cartSubtotal, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Delivery Charges")
                        Spacer()
                        Text("$\(cartViewModel.totalDeliveryCharges, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(cartViewModel.cartTotal, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                // Your Details
                Section(header: Text("Your Details"), footer: Text("All fields are required")) {
                    TextField("Name*", text: $name, prompt: Text("e.g., John Smith"))
                        .textContentType(.name)
                    
                    TextField("Phone Number*", text: $phoneNumber, prompt: Text("e.g., 07506423301"))
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    
                    TextField("Email*", text: $email, prompt: Text("e.g., john@example.com"))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                }
                
                // Delivery Address
                Section(header: Text("Delivery Address")) {
                    HStack {
                        TextField("Postcode*", text: $postcode, prompt: Text("e.g., SW1A 1AA"))
                            .textContentType(.postalCode)
                            .textInputAutocapitalization(.characters)
                        
                        Button(action: {
                            Task {
                                await lookupPostcode()
                            }
                        }) {
                            if isLookingUpPostcode {
                                ProgressView()
                            } else {
                                Text("Validate")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(postcode.trimmingCharacters(in: .whitespaces).isEmpty || isLookingUpPostcode)
                    }
                    
                    if !postcodeMessage.isEmpty {
                        Text(postcodeMessage)
                            .font(.caption)
                            .foregroundColor(postcodeMessage.contains("✓") ? .green : .red)
                    }
                    
                    TextField("Street Address*", text: $address, prompt: Text("e.g., 123 Main Street"))
                        .textContentType(.streetAddressLine1)
                    
                    TextField("City*", text: $city, prompt: Text("e.g., London"))
                        .textContentType(.addressCity)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Place Order Button
                Section {
                    Button(action: {
                        placeOrders()
                    }) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            } else {
                                Text("Place Order - $\(cartViewModel.cartTotal, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            Spacer()
                        }
                        .background(isFormValid && !isSubmitting ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Order Placed Successfully!", isPresented: $showSuccess) {
                Button("OK") {
                    cartViewModel.clearCart()
                    selectedTab = 0 // Navigate to Products tab
                    dismiss()
                }
            } message: {
                Text("Your order has been placed!\n\nTotal: $\(cartViewModel.cartTotal, specifier: "%.2f")")
            }
        }
    }
    
    // MARK: - Place Orders Function
    private func placeOrders() {
        guard isFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        errorMessage = ""
        
        let fullAddress = "\(address), \(city), \(postcode)"
        
        // Place order for each item in cart
        for item in cartViewModel.cartItems {
            orderViewModel.placeOrder(
                product: item.product,
                name: name,
                phone: phoneNumber,
                email: email,
                address: fullAddress,
                quantity: item.quantity
            )
        }
        
        // Simulate slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            showSuccess = true
        }
    }
    
    // MARK: - Postcode Lookup Function
    func lookupPostcode() async {
        isLookingUpPostcode = true
        postcodeMessage = ""
        
        do {
            let result = try await PostcodeService.shared.lookupPostcode(postcode)
            
            // Auto-fill city with the most relevant location data
            if let adminDistrict = result.admin_district {
                city = adminDistrict
            } else if let region = result.region {
                city = region
            }
            
            // Format the postcode nicely
            postcode = result.postcode
            
            postcodeMessage = "✓ Valid postcode! City auto-filled."
        } catch {
            postcodeMessage = error.localizedDescription
        }
        
        isLookingUpPostcode = false
    }
}

#Preview {
    CartViewPreview()
}

struct CartViewPreview: View {
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationView {
            CartView(selectedTab: $selectedTab)
                .environmentObject(CartViewModel())
        }
    }
}
