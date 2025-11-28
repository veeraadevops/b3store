import Foundation

// MARK: - Product Weight Variant
struct ProductVariant: Identifiable, Codable, Equatable {
    let id: UUID
    let weight: Double // in kg
    let weightLabel: String // e.g., "500gm", "1KG"
    let price: Double
    let originalPrice: Double? // For showing discounts
    let sku: String?
    
    init(id: UUID = UUID(), weight: Double, weightLabel: String, price: Double, originalPrice: Double? = nil, sku: String? = nil) {
        self.id = id
        self.weight = weight
        self.weightLabel = weightLabel
        self.price = price
        self.originalPrice = originalPrice
        self.sku = sku
    }
    
    static func == (lhs: ProductVariant, rhs: ProductVariant) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Product
struct Product: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let category: String
    let rating: Double
    let reviewCount: Int
    let imageName: String // Image name in Assets
    let variants: [ProductVariant] // Weight options with prices
    let tags: [String] // e.g., ["Spicy", "Authentic", "Made in India"]
    
    // Default variant (usually the first/smallest one)
    var defaultVariant: ProductVariant {
        variants.first ?? ProductVariant(weight: 0.5, weightLabel: "500gm", price: 5.99)
    }
    
    // Convenience properties for backward compatibility
    var price: Double {
        defaultVariant.price
    }
    
    var weight: Double {
        defaultVariant.weight
    }
    
    // Equatable conformance - compare by ID only
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed property for delivery charges based on weight
    func deliveryCharges(forWeight weight: Double) -> Double {
        if weight >= 10.0 {
            return 0.0 // Free delivery for 10kg+
        } else if weight >= 4.0 {
            return 8.0
        } else if weight >= 2.0 {
            return 7.0
        } else if weight >= 1.0 {
            return 6.0
        } else {
            return 4.0
        }
    }
    
    // Backward compatibility
    var deliveryCharges: Double {
        deliveryCharges(forWeight: defaultVariant.weight)
    }
    
    // Calculate total for quantity
    func calculateTotal(quantity: Int) -> Double {
        let totalWeight = weight * Double(quantity)
        let deliveryCharge: Double
        
        if totalWeight >= 10.0 {
            deliveryCharge = 0.0
        } else if totalWeight >= 4.0 {
            deliveryCharge = 8.0
        } else if totalWeight >= 2.0 {
            deliveryCharge = 7.0
        } else if totalWeight >= 1.0 {
            deliveryCharge = 6.0
        } else {
            deliveryCharge = 4.0
        }
        
        return (price * Double(quantity)) + deliveryCharge
    }
}
