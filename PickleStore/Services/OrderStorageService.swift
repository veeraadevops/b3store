//
//  OrderStorageService.swift
//  PickleStore
//
//  Local storage service for orders using UserDefaults
//  Protocol-based design for easy migration to Firebase Firestore
//

import Foundation

// MARK: - Protocol for Storage Service
// This allows easy switching between UserDefaults and Firebase
protocol OrderStorageProtocol {
    func saveOrders(_ orders: [Order]) async throws
    func loadOrders() async throws -> [Order]
    func deleteOrder(_ orderId: UUID) async throws
    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) async throws
}

// MARK: - UserDefaults Implementation
class OrderStorageService: OrderStorageProtocol {
    static let shared = OrderStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let ordersKey = "com.b3store.orders"
    
    private init() {}
    
    /// Save orders to UserDefaults
    func saveOrders(_ orders: [Order]) async throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(orders)
            userDefaults.set(data, forKey: ordersKey)
            userDefaults.synchronize()
            print("✓ Successfully saved \(orders.count) orders to UserDefaults")
        } catch {
            print("✗ Failed to save orders: \(error.localizedDescription)")
            throw OrderStorageError.saveFailed(error)
        }
    }
    
    /// Load orders from UserDefaults
    func loadOrders() async throws -> [Order] {
        guard let data = userDefaults.data(forKey: ordersKey) else {
            print("ℹ No orders found in UserDefaults")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let orders = try decoder.decode([Order].self, from: data)
            print("✓ Successfully loaded \(orders.count) orders from UserDefaults")
            return orders.sorted { $0.orderDate > $1.orderDate } // Most recent first
        } catch {
            print("✗ Failed to load orders: \(error.localizedDescription)")
            throw OrderStorageError.loadFailed(error)
        }
    }
    
    /// Delete a specific order
    func deleteOrder(_ orderId: UUID) async throws {
        var orders = try await loadOrders()
        orders.removeAll { $0.id == orderId }
        try await saveOrders(orders)
        print("✓ Successfully deleted order: \(orderId)")
    }
    
    /// Update order status
    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) async throws {
        var orders = try await loadOrders()
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index].status = status
            try await saveOrders(orders)
            print("✓ Updated order \(orderId) status to \(status.rawValue)")
        } else {
            throw OrderStorageError.orderNotFound
        }
    }
    
    /// Clear all orders (useful for testing)
    func clearAllOrders() {
        userDefaults.removeObject(forKey: ordersKey)
        userDefaults.synchronize()
        print("✓ Cleared all orders from storage")
    }
}

// MARK: - Custom Errors
enum OrderStorageError: LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case orderNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save orders: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load orders: \(error.localizedDescription)"
        case .orderNotFound:
            return "Order not found"
        }
    }
}

// MARK: - Future Firebase Implementation (commented out for now)
/*
class FirebaseOrderStorageService: OrderStorageProtocol {
    private let db = Firestore.firestore()
    private let ordersCollection = "orders"
    
    func saveOrders(_ orders: [Order]) async throws {
        // Implementation for Firebase Firestore
        // for order in orders {
        //     try await db.collection(ordersCollection).document(order.id.uuidString).setData(...)
        // }
    }
    
    func loadOrders() async throws -> [Order] {
        // Implementation for Firebase Firestore
        // let snapshot = try await db.collection(ordersCollection).getDocuments()
        // return snapshot.documents.compactMap { ... }
        return []
    }
    
    func deleteOrder(_ orderId: UUID) async throws {
        // Implementation for Firebase Firestore
        // try await db.collection(ordersCollection).document(orderId.uuidString).delete()
    }
    
    func updateOrderStatus(_ orderId: UUID, status: OrderStatus) async throws {
        // Implementation for Firebase Firestore
        // try await db.collection(ordersCollection).document(orderId.uuidString).updateData(["status": status.rawValue])
    }
}
*/
