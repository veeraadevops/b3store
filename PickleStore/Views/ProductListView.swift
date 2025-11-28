import SwiftUI

// Import models if needed - assuming they're in the same target
// If Product/ProductVariant are in a different module, add: import PickleStoreApp

struct ProductListView: View {
    @ObservedObject var viewModel: ProductListViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @Binding var selectedTab: Int
    @State private var expandedDescriptions: Set<UUID> = []

    var body: some View {
        List(viewModel.products) { product in
            VStack(alignment: .leading, spacing: 10) {
                // Clickable product area - navigates to Order Form
                NavigationLink(destination: OrderFormView(selectedTab: $selectedTab, product: product)) {
                    HStack(spacing: 15) {
                        // Product image
                        Image(product.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.name)
                                .font(.headline)
                            
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("\(product.rating, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("(\(product.reviewCount))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Price range if multiple variants
                            if product.variants.count > 1 {
                                Text("From $\(product.variants.map { $0.price }.min() ?? 0, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            } else {
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            // Tags
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(product.tags.prefix(3), id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                
                // Description preview
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
                
                // Quick Add to Cart Button (adds default variant)
                Button(action: {
                    // Create product with only the default variant
                    let productWithDefaultVariant = Product(
                        id: product.id,
                        name: product.name,
                        description: product.description,
                        category: product.category,
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        imageName: product.imageName,
                        variants: [product.defaultVariant],
                        tags: product.tags
                    )
                    cartViewModel.addToCart(productWithDefaultVariant, quantity: 1)
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("Quick Add")
                        Spacer()
                        Text("$\(product.defaultVariant.price, specifier: "%.2f")")
                            .fontWeight(.bold)
                        if product.variants.count > 1 {
                            Text("(\(product.defaultVariant.weightLabel))")
                                .font(.caption)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
    }
}
