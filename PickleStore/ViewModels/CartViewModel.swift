//
//  CartViewModel.swift
//  PickleStore
//
//  Manages shopping cart operations
//

import Foundation
import Combine

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    
    private let cartKey = "com.b3store.cart"
    
    init() {
        loadCart()
    }
    
    // MARK: - Cart Operations
    
    /// Add item to cart or increase quantity if already exists
    func addToCart(_ product: Product, quantity: Int = 1) {
        // Check if same product with same variant already exists
        // Compare product ID and the first variant (since we pass single-variant products)
        if let index = cartItems.firstIndex(where: { 
            $0.product.id == product.id && 
            $0.product.defaultVariant.id == product.defaultVariant.id 
        }) {
            // Item with same variant exists, increase quantity
            cartItems[index].quantity += quantity
            successMessage = "\(product.name) (\(product.defaultVariant.weightLabel)) quantity updated!"
        } else {
            // New item or different variant
            let newItem = CartItem(product: product, quantity: quantity)
            cartItems.append(newItem)
            successMessage = "\(product.name) (\(product.defaultVariant.weightLabel)) added to cart!"
        }
        saveCart()
        
        // Clear success message after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            successMessage = ""
        }
    }
    
    /// Remove item from cart
    func removeFromCart(_ itemId: UUID) {
        cartItems.removeAll { $0.id == itemId }
        saveCart()
    }
    
    /// Update item quantity
    func updateQuantity(for itemId: UUID, quantity: Int) {
        print("🔄 updateQuantity called: itemId=\(itemId), newQuantity=\(quantity)")
        print("📊 Current cart items count: \(cartItems.count)")
        
        // Clamp quantity to a minimum of 1 to avoid accidental removals
        let clampedQuantity = max(1, quantity)
        
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            print("📍 Found item at index \(index), current quantity: \(cartItems[index].quantity)")
            print("📦 Item name: \(cartItems[index].product.name)")
            
            // Create a new CartItem with updated quantity to trigger SwiftUI update
            let updatedItem = CartItem(
                id: cartItems[index].id,
                product: cartItems[index].product,
                quantity: clampedQuantity
            )
            cartItems[index] = updatedItem
            
            print("✅ Updated quantity to \(cartItems[index].quantity) (requested: \(quantity))")
            print("📊 After update cart items count: \(cartItems.count)")
            saveCart()
        } else {
            print("❌ Item not found in cart")
            print("🔍 Available item IDs: \(cartItems.map { $0.id })")
        }
    }
    
    /// Clear all items from cart
    func clearCart() {
        cartItems.removeAll()
        saveCart()
    }
    
    /// Get total number of items in cart
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    /// Get cart subtotal (without delivery)
    var cartSubtotal: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }
    
    /// Get total delivery charges based on combined weight
    var totalDeliveryCharges: Double {
        // Calculate total weight of all items in cart
        let totalWeight = cartItems.reduce(0.0) { total, item in
            total + (item.product.defaultVariant.weight * Double(item.quantity))
        }
        
        // Calculate delivery charge based on total weight
        if totalWeight >= 10.0 {
            return 0.0 // Free delivery for 10kg+
        } else if totalWeight > 4.0 {
            return 8.0
        } else if totalWeight > 2.0 {
            return 7.0
        } else if totalWeight > 1.0 {
            return 6.0
        } else {
            return 4.0
        }
    }
    
    /// Get cart total (subtotal + delivery)
    var cartTotal: Double {
        cartSubtotal + totalDeliveryCharges
    }
    
    // MARK: - Persistence
    
    private func saveCart() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cartItems)
            UserDefaults.standard.set(data, forKey: cartKey)
            print("✓ Cart saved: \(cartItems.count) items")
        } catch {
            print("✗ Failed to save cart: \(error.localizedDescription)")
            errorMessage = "Failed to save cart"
        }
    }
    
    private func loadCart() {
        guard let data = UserDefaults.standard.data(forKey: cartKey) else {
            print("ℹ No saved cart found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            cartItems = try decoder.decode([CartItem].self, from: data)
            print("✓ Cart loaded: \(cartItems.count) items")
        } catch {
            print("✗ Failed to load cart: \(error.localizedDescription)")
            cartItems = []
        }
    }
}
