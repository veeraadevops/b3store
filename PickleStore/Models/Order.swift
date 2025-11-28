import Foundation

enum OrderStatus: String, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

struct Order: Identifiable, Codable {
    let id: UUID
    let orderNumber: String
    let userId: String // Changed to String for easier Firebase migration
    let productId: String // Changed to String for easier Firebase migration
    
    // Product details
    let productName: String
    let productPrice: Double
    let productImageName: String
    
    // Customer details
    let customerName: String
    let customerPhone: String
    let customerEmail: String
    let customerAddress: String
    
    // Order details
    let quantity: Int
    let deliveryCharges: Double
    let totalPrice: Double
    let orderDate: Date
    var status: OrderStatus
    
    // Computed property for formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: orderDate)
    }
    
    // Initialize with all parameters
    init(id: UUID = UUID(),
         orderNumber: String,
         userId: String,
         productId: String,
         productName: String,
         productPrice: Double,
         productImageName: String,
         customerName: String,
         customerPhone: String,
         customerEmail: String,
         customerAddress: String,
         quantity: Int,
         deliveryCharges: Double,
         totalPrice: Double,
         orderDate: Date = Date(),
         status: OrderStatus = .pending) {
        self.id = id
        self.orderNumber = orderNumber
        self.userId = userId
        self.productId = productId
        self.productName = productName
        self.productPrice = productPrice
        self.productImageName = productImageName
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.customerEmail = customerEmail
        self.customerAddress = customerAddress
        self.quantity = quantity
        self.deliveryCharges = deliveryCharges
        self.totalPrice = totalPrice
        self.orderDate = orderDate
        self.status = status
    }
}