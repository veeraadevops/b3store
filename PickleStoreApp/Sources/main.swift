
import Foundation
// Import model files
// If using a module, use: import PickleStoreApp

let product = Product(id: UUID(), name: "Classic Pickle", price: 5.99, rating: 4.8, deliveryCharges: 1.5)
let user = User(id: UUID(), name: "John Doe", phoneNumber: "1234567890", email: "john@example.com", address: "123 Main St")
let order = Order(id: UUID(), userId: user.id, productId: product.id, quantity: 2, deliveryCharges: product.deliveryCharges)

print("Product: \(product)")
print("User: \(user)")
print("Order: \(order)")
