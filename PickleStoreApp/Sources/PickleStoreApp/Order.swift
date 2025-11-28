import Foundation

struct Order: Identifiable {
    let id: UUID
    let userId: UUID
    let productId: UUID
    let quantity: Int
    let deliveryCharges: Double
}