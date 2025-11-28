import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    init() {
        loadProducts()
    }
    
    // Load products from JSON file
    private func loadProducts() {
        isLoading = true
        errorMessage = ""
        
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json") else {
            errorMessage = "Products file not found"
            print("❌ products.json not found in bundle")
            loadFallbackProducts()
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            products = try decoder.decode([Product].self, from: data)
            print("✅ Loaded \(products.count) products from JSON")
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
            loadFallbackProducts()
            isLoading = false
        }
    }
    
    // Fallback products if JSON fails to load
    private func loadFallbackProducts() {
        print("⚠️ Loading fallback products")
        products = [
            Product(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Classic Pickle",
                description: "Traditional Indian pickle with a perfect blend of spices",
                category: "Pickles",
                rating: 4.8,
                reviewCount: 10,
                imageName: "classic-pickle",
                variants: [
                    ProductVariant(weight: 0.5, weightLabel: "500gm", price: 5.99)
                ],
                tags: ["Traditional", "Spicy"]
            ),
            Product(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                name: "Spicy Pickle",
                description: "Extra hot pickle for those who love intense flavors",
                category: "Pickles",
                rating: 4.6,
                reviewCount: 8,
                imageName: "spicy-pickle",
                variants: [
                    ProductVariant(weight: 0.5, weightLabel: "500gm", price: 6.49)
                ],
                tags: ["Spicy", "Hot"]
            ),
            Product(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                name: "Sweet Pickle",
                description: "A delightful sweet and tangy pickle",
                category: "Pickles",
                rating: 4.7,
                reviewCount: 6,
                imageName: "sweet-pickle",
                variants: [
                    ProductVariant(weight: 0.5, weightLabel: "500gm", price: 5.49)
                ],
                tags: ["Sweet", "Tangy"]
            )
        ]
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText) ||
                product.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    // Reload products (useful for admin features later)
    func reloadProducts() {
        loadProducts()
    }
}
