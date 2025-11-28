import Foundation

struct User: Identifiable {
    let id: UUID
    let name: String
    let phoneNumber: String
    let email: String
    let address: String
}