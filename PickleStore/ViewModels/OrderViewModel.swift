//
//  OrderViewModel.swift
//  PickleStore
//
//  Manages order operations with persistent storage
//

import Foundation
import Combine
import FirebaseAuth

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var successMessage: String = ""
    
    private let storageService: OrderStorageProtocol
    
    // Dependency injection for easy testing and Firebase migration
    init(storageService: OrderStorageProtocol = OrderStorageService.shared) {
        self.storageService = storageService
        loadOrders()
    }
    
    /// Load orders from storage
    func loadOrders() {
        Task {
            await MainActor.run { isLoading = true }
            do {
                let loadedOrders = try await storageService.loadOrders()
                await MainActor.run {
                    self.orders = loadedOrders
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load orders: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Place a new order
    func placeOrder(product: Product, name: String, phone: String, email: String, address: String, quantity: Int) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                // Calculate delivery charges based on weight
                let deliveryCharges = calculateDeliveryCharges(weight: product.weight, quantity: quantity)
                let totalPrice = (product.price * Double(quantity)) + deliveryCharges
                
                // Generate order number (format: BO + timestamp + random)
                let orderNumber = generateOrderNumber()
                
                // Get current user ID (or use guest if not logged in)
                let userId = Auth.auth().currentUser?.uid ?? "guest"
                
                // Create order
                let order = Order(
                    orderNumber: orderNumber,
                    userId: userId,
                    productId: product.id.uuidString,
                    productName: product.name,
                    productPrice: product.price,
                    productImageName: product.imageName,
                    customerName: name,
                    customerPhone: phone,
                    customerEmail: email,
                    customerAddress: address,
                    quantity: quantity,
                    deliveryCharges: deliveryCharges,
                    totalPrice: totalPrice,
                    orderDate: Date(),
                    status: .pending
                )
                
                // Add to orders array
                orders.insert(order, at: 0) // Add to beginning (most recent first)
                
                // Save to storage
                try await storageService.saveOrders(orders)
                
                await MainActor.run {
                    self.successMessage = "Order #\(orderNumber) placed successfully!"
                    self.isLoading = false
                }
                
                print("✓ Order placed successfully:")
                print("  Order Number: \(orderNumber)")
                print("  Product: \(product.name)")
                print("  Customer: \(name)")
                print("  Phone: \(phone)")
                print("  Email: \(email)")
                print("  Address: \(address)")
                print("  Quantity: \(quantity)")
                print("  Total: £\(String(format: "%.2f", totalPrice))")
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to place order: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Delete an order
    func deleteOrder(_ orderId: UUID) {
        Task {
            do {
                try await storageService.deleteOrder(orderId)
                await MainActor.run {
                    self.orders.removeAll { $0.id == orderId }
                    self.successMessage = "Order deleted successfully"
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete order: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Update order status
    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) {
        Task {
            do {
                try await storageService.updateOrderStatus(orderId, status: status)
                await MainActor.run {
                    if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                        self.orders[index].status = status
                    }
                    self.successMessage = "Order status updated to \(status.rawValue)"
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update order status: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Calculate delivery charges based on weight
    /// Formula: <1kg=£4, 1-2kg=£6, 2-4kg=£7, 4-10kg=£8, >10kg=free
    func calculateDeliveryCharges(weight: Double, quantity: Int) -> Double {
        let totalWeight = weight * Double(quantity)
        
        if totalWeight >= 10.0 {
            return 0.0 // Free delivery for 10kg+
        } else if totalWeight >= 4.0 {
            return 8.0
        } else if totalWeight >= 2.0 {
            return 7.0
        } else if totalWeight >= 1.0 {
            return 6.0
        } else {
            return 4.0
        }
    }
    
    /// Generate unique order number
    private func generateOrderNumber() -> String {
        let timestamp = Date().timeIntervalSince1970
        let random = Int.random(in: 1000...9999)
        return "BO\(Int(timestamp))\(random)" // BO = Bharat Orders
    }
    
    /// Clear success/error messages
    func clearMessages() {
        successMessage = ""
        errorMessage = ""
    }
}
