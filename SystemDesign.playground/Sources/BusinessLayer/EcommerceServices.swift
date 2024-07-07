//https://www.mermaidchart.com/app/projects/dd0c122f-9b14-4673-bd43-c3542a150d94/diagrams/06c38fb4-fe80-481e-8877-d9eb73186d0c/version/v0.1/edit

/*
 This implementation demonstrates several key concepts and design patterns:

Separation of Concerns: Each service is responsible for a specific domain of the business logic.
Dependency Inversion Principle: Services depend on abstractions (protocols) rather than concrete implementations.
Single Responsibility Principle: Each class and protocol has a single, well-defined responsibility.
Repository Pattern: Used to abstract the data layer, allowing for easy switching of data sources.
Factory Method Pattern: The setupServices() function acts as a simple factory, creating and configuring all necessary objects.
Strategy Pattern: Different implementations of services can be easily swapped due to the use of protocols.
Facade Pattern: The OrderProcessingService acts as a facade, coordinating between other services to complete a complex operation (placing an order).
MVVM Architecture: The ViewModel (OrderViewModel) acts as an intermediary between the View and the Model (services).
Asynchronous Programming: Utilizes Swift's async/await for handling asynchronous operations.
Error Handling: Defines and uses domain-specific errors (BusinessError).

Benefits to the business:

Modularity: Each service can be developed, tested, and maintained independently.
Scalability: New features or services can be added without significant changes to existing code.
Testability: The use of protocols and dependency injection makes it easy to write unit tests for each component.
Flexibility: The system can easily adapt to changing business requirements or technologies.
Consistency: Business rules are centralized within their respective services, ensuring consistent application across the app.
Maintainability: The clear separation of concerns makes the codebase easier to understand and maintain.
Reusability: Services can be reused across different parts of the application or even in different applications.

This architecture provides a solid foundation for building complex, enterprise-grade applications. It allows for easy expansion of functionality, such as adding new types of deals, implementing more complex stock management, or integrating with external systems.
*/

import Foundation

// MARK: - Models

struct Product: Identifiable {
    let id: String
    let name: String
    var price: Decimal
    var stockQuantity: Int
}

struct User: Identifiable {
    let id: String
    let name: String
    var loyaltyPoints: Int
}

struct Deal: Identifiable {
    let id: String
    let discountPercentage: Decimal
    let minimumPurchaseAmount: Decimal
}

struct Order: Identifiable {
    let id: String
    let userId: String
    var items: [OrderItem]
    var totalAmount: Decimal
    var status: OrderStatus
}

struct OrderItem {
    let productId: String
    var quantity: Int
    var price: Decimal
}

enum OrderStatus {
    case pending, confirmed, shipped, delivered, cancelled
}

// MARK: - Repositories

protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func updateStock(productId: String, newQuantity: Int) async throws
}

protocol UserRepository {
    func getUser(id: String) async throws -> User
    func updateLoyaltyPoints(userId: String, points: Int) async throws
}

protocol DealRepository {
    func getActiveDeals() async throws -> [Deal]
}

protocol OrderRepository {
    func createOrder(_ order: Order) async throws -> Order
    func updateOrder(_ order: Order) async throws
}

// MARK: - Services

// Product Management Service
protocol ProductManagementService {
    func getProduct(id: String) async throws -> Product
    func updateStock(productId: String, quantityChange: Int) async throws
}

class ProductManagementServiceImpl: ProductManagementService {
    private let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func getProduct(id: String) async throws -> Product {
        return try await repository.getProduct(id: id)
    }
    
    func updateStock(productId: String, quantityChange: Int) async throws {
        let product = try await repository.getProduct(id: productId)
        let newQuantity = product.stockQuantity + quantityChange
        guard newQuantity >= 0 else { throw BusinessError.insufficientStock }
        try await repository.updateStock(productId: productId, newQuantity: newQuantity)
    }
}

// User Management Service
protocol UserManagementService {
    func getUser(id: String) async throws -> User
    func addLoyaltyPoints(userId: String, points: Int) async throws
}

class UserManagementServiceImpl: UserManagementService {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func getUser(id: String) async throws -> User {
        return try await repository.getUser(id: id)
    }
    
    func addLoyaltyPoints(userId: String, points: Int) async throws {
        let user = try await repository.getUser(id: userId)
        let newPoints = user.loyaltyPoints + points
        try await repository.updateLoyaltyPoints(userId: userId, points: newPoints)
    }
}

// Deal Management Service
protocol DealManagementService {
    func applyDeals(to amount: Decimal) async throws -> Decimal
}

class DealManagementServiceImpl: DealManagementService {
    private let repository: DealRepository
    
    init(repository: DealRepository) {
        self.repository = repository
    }
    
    func applyDeals(to amount: Decimal) async throws -> Decimal {
        let deals = try await repository.getActiveDeals()
        let applicableDeal = deals.filter { amount >= $0.minimumPurchaseAmount }
                                  .max(by: { $0.discountPercentage < $1.discountPercentage })
        
        guard let deal = applicableDeal else { return amount }
        
        let discountAmount = amount * (deal.discountPercentage / 100)
        return amount - discountAmount
    }
}

// Order Processing Service
protocol OrderProcessingService {
    func placeOrder(userId: String, items: [OrderItem]) async throws -> Order
}

class OrderProcessingServiceImpl: OrderProcessingService {
    private let orderRepository: OrderRepository
    private let productService: ProductManagementService
    private let userService: UserManagementService
    private let dealService: DealManagementService
    
    init(orderRepository: OrderRepository, productService: ProductManagementService, userService: UserManagementService, dealService: DealManagementService) {
        self.orderRepository = orderRepository
        self.productService = productService
        self.userService = userService
        self.dealService = dealService
    }
    
    func placeOrder(userId: String, items: [OrderItem]) async throws -> Order {
        // Validate stock and calculate total
        var totalAmount: Decimal = 0
        for item in items {
            let product = try await productService.getProduct(id: item.productId)
            guard product.stockQuantity >= item.quantity else {
                throw BusinessError.insufficientStock
            }
            totalAmount += product.price * Decimal(item.quantity)
        }
        
        // Apply deals
        let discountedAmount = try await dealService.applyDeals(to: totalAmount)
        
        // Create order
        let order = Order(id: UUID().uuidString, userId: userId, items: items, totalAmount: discountedAmount, status: .pending)
        let createdOrder = try await orderRepository.createOrder(order)
        
        // Update stock
        for item in items {
            try await productService.updateStock(productId: item.productId, quantityChange: -item.quantity)
        }
        
        // Add loyalty points
        let loyaltyPoints = Int(discountedAmount / 10) // Simplified loyalty point calculation
        try await userService.addLoyaltyPoints(userId: userId, points: loyaltyPoints)
        
        return createdOrder
    }
}

// MARK: - ViewModel

class OrderViewModel: ObservableObject {
    private let orderService: OrderProcessingService
    @Published var order: Order?
    @Published var error: Error?
    
    init(orderService: OrderProcessingService) {
        self.orderService = orderService
    }
    
    func placeOrder(userId: String, items: [OrderItem]) async {
        do {
            order = try await orderService.placeOrder(userId: userId, items: items)
        } catch {
            self.error = error
        }
    }
}

// MARK: - Errors

enum BusinessError: Error {
    case insufficientStock
}

// MARK: - Usage Example

func setupServices() -> OrderViewModel {
    // Setup repositories (assume implementations exist)
    let productRepo = ProductRepositoryImpl()
    let userRepo = UserRepositoryImpl()
    let dealRepo = DealRepositoryImpl()
    let orderRepo = OrderRepositoryImpl()
    
    // Setup services
    let productService = ProductManagementServiceImpl(repository: productRepo)
    let userService = UserManagementServiceImpl(repository: userRepo)
    let dealService = DealManagementServiceImpl(repository: dealRepo)
    let orderService = OrderProcessingServiceImpl(orderRepository: orderRepo, productService: productService, userService: userService, dealService: dealService)
    
    // Create ViewModel
    return OrderViewModel(orderService: orderService)
}

// In a SwiftUI View
struct OrderView: View {
    @StateObject private var viewModel = setupServices()
    
    var body: some View {
        // UI implementation
    }
}
