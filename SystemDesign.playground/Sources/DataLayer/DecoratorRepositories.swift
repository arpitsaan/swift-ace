import Foundation

// MARK: - Product Model

struct Product: Identifiable, Equatable {
    let id: String
    var name: String
    var price: Double
}

// MARK: - Product Repository Protocol

protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func createProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(id: String) async throws
}

// MARK: - Base Remote Product Repository

class RemoteProductRepository: ProductRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getProduct(id: String) async throws -> Product {
        // Implementation using apiClient
        fatalError("Not implemented")
    }
    
    func getAllProducts() async throws -> [Product] {
        // Implementation using apiClient
        fatalError("Not implemented")
    }
    
    func createProduct(_ product: Product) async throws {
        // Implementation using apiClient
        fatalError("Not implemented")
    }
    
    func updateProduct(_ product: Product) async throws {
        // Implementation using apiClient
        fatalError("Not implemented")
    }
    
    func deleteProduct(id: String) async throws {
        // Implementation using apiClient
        fatalError("Not implemented")
    }
}

// MARK: - Caching Decorator

class CachingProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    private var cache: [String: Product] = [:]
    
    init(_ repository: ProductRepository) {
        self.decoratee = repository
    }
    
    func getProduct(id: String) async throws -> Product {
        if let cachedProduct = cache[id] {
            return cachedProduct
        }
        let product = try await decoratee.getProduct(id: id)
        cache[id] = product
        return product
    }
    
    func getAllProducts() async throws -> [Product] {
        let products = try await decoratee.getAllProducts()
        products.forEach { cache[$0.id] = $0 }
        return products
    }
    
    func createProduct(_ product: Product) async throws {
        try await decoratee.createProduct(product)
        cache[product.id] = product
    }
    
    func updateProduct(_ product: Product) async throws {
        try await decoratee.updateProduct(product)
        cache[product.id] = product
    }
    
    func deleteProduct(id: String) async throws {
        try await decoratee.deleteProduct(id: id)
        cache.removeValue(forKey: id)
    }
}

// MARK: - Offline Support Decorator

class OfflineProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    private let localRepository: ProductRepository
    private let connectivityChecker: ConnectivityChecking
    
    init(_ repository: ProductRepository, localRepository: ProductRepository, connectivityChecker: ConnectivityChecking) {
        self.decoratee = repository
        self.localRepository = localRepository
        self.connectivityChecker = connectivityChecker
    }
    
    func getProduct(id: String) async throws -> Product {
        guard connectivityChecker.isConnected else {
            return try await localRepository.getProduct(id: id)
        }
        let product = try await decoratee.getProduct(id: id)
        try? await localRepository.createProduct(product)
        return product
    }
    
    func getAllProducts() async throws -> [Product] {
        guard connectivityChecker.isConnected else {
            return try await localRepository.getAllProducts()
        }
        let products = try await decoratee.getAllProducts()
        try? await localRepository.createProducts(products)
        return products
    }
    
    func createProduct(_ product: Product) async throws {
        guard connectivityChecker.isConnected else {
            try await localRepository.createProduct(product)
            return
        }
        try await decoratee.createProduct(product)
        try? await localRepository.createProduct(product)
    }
    
    func updateProduct(_ product: Product) async throws {
        guard connectivityChecker.isConnected else {
            try await localRepository.updateProduct(product)
            return
        }
        try await decoratee.updateProduct(product)
        try? await localRepository.updateProduct(product)
    }
    
    func deleteProduct(id: String) async throws {
        guard connectivityChecker.isConnected else {
            try await localRepository.deleteProduct(id: id)
            return
        }
        try await decoratee.deleteProduct(id: id)
        try? await localRepository.deleteProduct(id: id)
    }
}

// MARK: - Retry Decorator

class RetryProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    private let maxRetries: Int
    
    init(_ repository: ProductRepository, maxRetries: Int = 3) {
        self.decoratee = repository
        self.maxRetries = maxRetries
    }
    
    func getProduct(id: String) async throws -> Product {
        try await retry { try await self.decoratee.getProduct(id: id) }
    }
    
    func getAllProducts() async throws -> [Product] {
        try await retry { try await self.decoratee.getAllProducts() }
    }
    
    func createProduct(_ product: Product) async throws {
        try await retry { try await self.decoratee.createProduct(product) }
    }
    
    func updateProduct(_ product: Product) async throws {
        try await retry { try await self.decoratee.updateProduct(product) }
    }
    
    func deleteProduct(id: String) async throws {
        try await retry { try await self.decoratee.deleteProduct(id: id) }
    }
    
    private func retry<T>(_ operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        for _ in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retrying
            }
        }
        throw lastError ?? RepositoryError.unknown
    }
}

// MARK: - Usage

class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    @Published var products: [Product] = []
    
    init(repository: ProductRepository) {
        // Compose decorators
        let baseRepository = RemoteProductRepository(apiClient: APIClient())
        let cachingRepository = CachingProductRepository(baseRepository)
        let offlineRepository = OfflineProductRepository(cachingRepository, localRepository: LocalProductRepository(), connectivityChecker: ConnectivityChecker())
        self.repository = RetryProductRepository(offlineRepository)
    }
    
    func fetchProducts() async {
        do {
            products = try await repository.getAllProducts()
        } catch {
            // Handle error
        }
    }
    
    // Other methods...
}

// MARK: - Helpers

protocol ConnectivityChecking {
    var isConnected: Bool { get }
}

class ConnectivityChecker: ConnectivityChecking {
    var isConnected: Bool {
        // Implementation to check network connectivity
        return true
    }
}

enum RepositoryError: Error {
    case unknown
}

class APIClient {
    // API client implementation
}

class LocalProductRepository: ProductRepository {
    // Local storage implementation
}
