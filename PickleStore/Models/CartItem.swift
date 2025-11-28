//
//  CartItem.swift
//  PickleStore
//
//  Shopping cart item model
//

import Foundation

struct CartItem: Identifiable, Codable, Equatable {
    let id: UUID
    let product: Product
    var quantity: Int
    
    init(id: UUID = UUID(), product: Product, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    var subtotal: Double {
        product.price * Double(quantity)
    }
    
    var deliveryCharge: Double {
        product.deliveryCharges
    }
    
    var total: Double {
        subtotal + deliveryCharge
    }
    
    // Equatable conformance to compare cart items
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}
