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
    @State private var availableAddresses: [Address] = []
    @State private var showAddressPicker = false

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
                            Text("Find")
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
                        .foregroundColor(postcodeMessage.contains("found") ? .green : .red)
                }
                
                // Show address picker if addresses are available
                if !availableAddresses.isEmpty {
                    Picker("Select Address", selection: $showAddressPicker) {
                        Text("Select an address...").tag(false)
                    }
                    .pickerStyle(.menu)
                    
                    ForEach(availableAddresses) { addr in
                        Button(action: {
                            selectAddress(addr)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(addr.line1)
                                    .font(.body)
                                if let line2 = addr.line2, !line2.isEmpty {
                                    Text(line2)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Text("\(addr.city), \(addr.postcode)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                TextField("Street Address*", text: $address, prompt: Text("e.g., 123 Main Street"))
                    .textContentType(.streetAddressLine1)
                
                TextField("City*", text: $city, prompt: Text("e.g., London"))
                    .textContentType(.addressCity)
            }
            Section(header: Text("Order Details")) {
                Stepper(value: $quantity, in: 1...100) {
                    Text("Quantity: \(quantity)")
                }
                Text("Product: \(product.name)")
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
    
    // Function to lookup postcode using address lookup API
    func lookupPostcode() async {
        isLookingUpPostcode = true
        postcodeMessage = ""
        availableAddresses = []
        
        do {
            let addresses = try await PostcodeService.shared.lookupAddresses(for: postcode)
            
            if addresses.isEmpty {
                postcodeMessage = "No addresses found for this postcode"
            } else {
                availableAddresses = addresses
                postcodeMessage = "✓ \(addresses.count) address(es) found. Select one below:"
            }
        } catch PostcodeError.apiKeyMissing {
            postcodeMessage = "Address lookup requires API key. Please enter address manually."
        } catch {
            postcodeMessage = error.localizedDescription
        }
        
        isLookingUpPostcode = false
    }
    
    // Function to select an address from the list
    func selectAddress(_ addr: Address) {
        address = addr.line1
        city = addr.city
        postcode = addr.postcode
        availableAddresses = [] // Clear the list after selection
        postcodeMessage = "✓ Address selected"
    }
}
