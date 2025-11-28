import SwiftUI

struct OrderFormView: View {
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var city = ""
    @State private var postcode = ""
    @State private var quantity = 1
    @State private var orderPlaced = false
    @State private var errorMessage = ""
    @StateObject private var viewModel = OrderViewModel()
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var isLookingUpPostcode = false
    @State private var postcodeMessage = ""

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
                
                Stepper(value: $quantity, in: 1...100) {
                    Text("Quantity: \(quantity)")
                }
                Text("Price: $\(product.price, specifier: "%.2f")")
                Text("Delivery Charges: $\(product.deliveryCharges, specifier: "%.2f")")
                Text("Total: $\((product.price * Double(quantity)) + product.deliveryCharges, specifier: "%.2f")")
                    .font(.headline)
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
                    if isFormValid {
                        let fullAddress = "\(address), \(city), \(postcode)"
                        viewModel.placeOrder(product: product, name: name, phone: phoneNumber, email: email, address: fullAddress, quantity: quantity)
                        showConfirmation = true
                        errorMessage = ""
                    } else {
                        errorMessage = "Please fill in all required fields (*) with valid information. Phone must be at least 10 digits."
                        showError = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Place Order")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            if orderPlaced {
                Text("Order placed successfully!").foregroundColor(.green)
            }
        }
        .navigationTitle("Order Pickle")
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Order Placed"), 
                message: Text("Your order for \(quantity) \(product.name) has been placed!\n\nTotal: $\((product.price * Double(quantity)) + product.deliveryCharges, specifier: "%.2f")"), 
                dismissButton: .default(Text("OK"))
            )
        }
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
