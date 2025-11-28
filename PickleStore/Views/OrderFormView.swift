import SwiftUI

struct OrderFormView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var city = ""
    @State private var postcode = ""
    @State private var quantity = 1
    @State private var selectedVariant: ProductVariant? = nil
    @State private var expandedDescription = false
    @State private var orderPlaced = false
    @State private var errorMessage = ""
    @StateObject private var viewModel = OrderViewModel()
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var isLookingUpPostcode = false
    @State private var postcodeMessage = ""
    @State private var isSubmitting = false

    let product: Product
    
    // Validation computed property
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
        Form {
            // Section 1: Order Details (moved to top)
            Section(header: Text("Order Details")) {
                HStack {
                    Image(product.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(product.name)
                            .font(.headline)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("Rating: \(product.rating, specifier: "%.1f")")
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 5)
                
                // Expandable Product description
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(expandedDescription ? nil : 2)
                    
                    Button(action: {
                        expandedDescription.toggle()
                    }) {
                        Text(expandedDescription ? "Show less" : "Show more")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
                
                // Weight/Size Selection for multiple variants
                if product.variants.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Size:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 10) {
                            ForEach(product.variants) { variant in
                                Button(action: {
                                    selectedVariant = variant
                                }) {
                                    VStack(spacing: 4) {
                                        Text(variant.weightLabel)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        HStack(spacing: 2) {
                                            Text("$\(variant.price, specifier: "%.2f")")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            
                                            if let originalPrice = variant.originalPrice {
                                                Text("$\(originalPrice, specifier: "%.2f")")
                                                    .font(.caption2)
                                                    .strikethrough()
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        (selectedVariant?.id ?? product.defaultVariant.id) == variant.id
                                            ? Color.green
                                            : Color.gray.opacity(0.1)
                                    )
                                    .foregroundColor(
                                        (selectedVariant?.id ?? product.defaultVariant.id) == variant.id
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Stepper(value: $quantity, in: 1...100) {
                    Text("Quantity: \(quantity)")
                }
                
                let currentVariant = selectedVariant ?? product.defaultVariant
                let currentPrice = currentVariant.price
                let currentDelivery = product.deliveryCharges(forWeight: currentVariant.weight)
                
                Text("Price: $\(currentPrice, specifier: "%.2f") × \(quantity) = $\(currentPrice * Double(quantity), specifier: "%.2f")")
                Text("Delivery Charges: $\(currentDelivery, specifier: "%.2f")")
                Text("Total: $\((currentPrice * Double(quantity)) + currentDelivery, specifier: "%.2f")")
                    .font(.headline)
            }
            
            // Section 2: Your Details
            Section(header: Text("Your Details"), footer: Text("All fields are required")) {
                TextField("Name*", text: $name, prompt: Text("e.g., John Smith"))
                    .textContentType(.name)
                
                TextField("Phone Number*", text: $phoneNumber, prompt: Text("e.g., 07506423301"))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                
                TextField("Email*", text: $email, prompt: Text("e.g., john@example.com"))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
            }
            
            // Section 3: Delivery Address
            Section(header: Text("Delivery Address")) {
                HStack {
                    TextField("Postcode*", text: $postcode, prompt: Text("e.g., SW1A 1AA"))
                        .textContentType(.postalCode)
                        .autocapitalization(.allCharacters)
                    
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
            
            Section {
                Button(action: {
                    placeOrder()
                }) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        } else {
                            Text("Place Order")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                    }
                    .background(isFormValid && !isSubmitting ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || isSubmitting)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            if orderPlaced {
                Text("Order placed successfully!").foregroundColor(.green)
            }
        }
        .navigationTitle("Order Pickle")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Order Placed", isPresented: $showConfirmation) {
            Button("View Orders") {
                selectedTab = 2 // Navigate to Orders tab
                dismiss()
            }
            Button("Continue Shopping") {
                dismiss()
            }
        } message: {
            Text("Your order for \(quantity) \(product.name) has been placed!\n\nTotal: $\((product.price * Double(quantity)) + product.deliveryCharges, specifier: "%.2f")")
        }
    }
    
    // MARK: - Place Order Function
    private func placeOrder() {
        guard isFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        errorMessage = ""
        
        let fullAddress = "\(address), \(city), \(postcode)"
        
        // Create a product with only the selected variant
        let currentVariant = selectedVariant ?? product.defaultVariant
        let productWithSelectedVariant = Product(
            id: product.id,
            name: product.name,
            description: product.description,
            category: product.category,
            rating: product.rating,
            reviewCount: product.reviewCount,
            imageName: product.imageName,
            variants: [currentVariant], // Only include the selected variant
            tags: product.tags
        )
        
        viewModel.placeOrder(product: productWithSelectedVariant, name: name, phone: phoneNumber, email: email, address: fullAddress, quantity: quantity)
        
        // Simulate slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSubmitting = false
            showConfirmation = true
            orderPlaced = true
            
            // Clear form after successful order
            clearForm()
        }
    }
    
    // MARK: - Clear Form Function
    private func clearForm() {
        name = ""
        phoneNumber = ""
        email = ""
        address = ""
        city = ""
        postcode = ""
        quantity = 1
        postcodeMessage = ""
    }
    
    // Function to validate postcode using free Postcode.io API
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
