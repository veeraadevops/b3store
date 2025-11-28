//
//  OrderHistoryView.swift
//  PickleStore
//
//  Display all past orders with filtering and details
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderViewModel()
    @State private var selectedFilter: OrderStatusFilter = .all
    @State private var searchText = ""
    @State private var selectedOrder: Order?
    @State private var showOrderDetail = false
    
    enum OrderStatusFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case processing = "Processing"
        case shipped = "Shipped"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
        
        var status: OrderStatus? {
            switch self {
            case .all: return nil
            case .pending: return .pending
            case .processing: return .processing
            case .shipped: return .shipped
            case .delivered: return .delivered
            case .cancelled: return .cancelled
            }
        }
    }
    
    var filteredOrders: [Order] {
        var orders = viewModel.orders
        
        // Filter by status
        if let status = selectedFilter.status {
            orders = orders.filter { $0.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            orders = orders.filter { order in
                order.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                order.productName.localizedCaseInsensitiveContains(searchText) ||
                order.customerName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return orders
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search orders...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(OrderStatusFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                count: filter == .all ? viewModel.orders.count : viewModel.orders.filter { $0.status == filter.status }.count
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                Divider()
                
                // Orders List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading orders...")
                    Spacer()
                } else if filteredOrders.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No orders found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        if searchText.isEmpty && selectedFilter == .all {
                            Text("Your orders will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredOrders) { order in
                            OrderCard(order: order)
                                .onTapGesture {
                                    selectedOrder = order
                                    showOrderDetail = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if order.status == .pending {
                                        Button(role: .destructive) {
                                            viewModel.deleteOrder(order.id)
                                        } label: {
                                            Label("Cancel", systemImage: "xmark")
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.loadOrders()
                    }
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showOrderDetail) {
                if let order = selectedOrder {
                    OrderDetailView(order: order, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Order Card Component
struct OrderCard: View {
    let order: Order
    
    var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderNumber)")
                        .font(.headline)
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(order.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // Product Info
            HStack(spacing: 12) {
                Image(order.productImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.productName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Qty: \(order.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("£\(order.totalPrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: Order
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status Badge
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: statusIcon)
                                .font(.system(size: 50))
                                .foregroundColor(statusColor)
                            Text(order.status.rawValue)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Order Info
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Order Information")
                        
                        InfoRow(label: "Order Number", value: order.orderNumber)
                        InfoRow(label: "Date", value: order.formattedDate)
                        InfoRow(label: "Status", value: order.status.rawValue)
                    }
                    
                    Divider()
                    
                    // Product Details
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Product Details")
                        
                        HStack(spacing: 15) {
                            Image(order.productImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(order.productName)
                                    .font(.headline)
                                Text("Quantity: \(order.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("£\(order.productPrice, specifier: "%.2f") each")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Customer Details
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Customer Details")
                        
                        InfoRow(label: "Name", value: order.customerName)
                        InfoRow(label: "Phone", value: order.customerPhone)
                        InfoRow(label: "Email", value: order.customerEmail)
                    }
                    
                    Divider()
                    
                    // Delivery Address
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Delivery Address")
                        
                        Text(order.customerAddress)
                            .font(.body)
                    }
                    
                    Divider()
                    
                    // Price Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Price Breakdown")
                        
                        HStack {
                            Text("Product Price")
                            Spacer()
                            Text("£\(order.productPrice * Double(order.quantity), specifier: "%.2f")")
                        }
                        
                        HStack {
                            Text("Delivery Charges")
                            Spacer()
                            if order.deliveryCharges == 0 {
                                Text("FREE")
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            } else {
                                Text("£\(order.deliveryCharges, specifier: "%.2f")")
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("£\(order.totalPrice, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Cancel Button (only for pending orders)
                    if order.status == .pending {
                        Button(action: { showCancelConfirmation = true }) {
                            Text("Cancel Order")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Cancel Order?", isPresented: $showCancelConfirmation) {
                Button("Cancel Order", role: .destructive) {
                    viewModel.updateOrderStatus(order.id, status: .cancelled)
                    dismiss()
                }
                Button("Keep Order", role: .cancel) { }
            } message: {
                Text("Are you sure you want to cancel this order?")
            }
        }
    }
    
    var statusIcon: String {
        switch order.status {
        case .pending: return "clock"
        case .processing: return "gearshape.2"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Helper Components
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
