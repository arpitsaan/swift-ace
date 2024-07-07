# Advanced Data Layer Concepts

// MARK: - Repository Protocol

protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func saveProduct(_ product: Product) async throws
}


## 1. Caching Strategy

Implementing a proper caching strategy can significantly improve your app's performance and user experience.

### Example: Time-based caching

```swift
class CachedProductRepository: ProductRepository {
    private let remoteRepository: ProductRepository
    private let localRepository: ProductRepository
    private let cacheTimeout: TimeInterval
    
    init(remoteRepository: ProductRepository, localRepository: ProductRepository, cacheTimeout: TimeInterval = 3600) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
        self.cacheTimeout = cacheTimeout
    }
    
    func getAllProducts() async throws -> [Product] {
        if let lastFetchTime = UserDefaults.standard.object(forKey: "lastProductFetchTime") as? Date,
           Date().timeIntervalSince(lastFetchTime) < cacheTimeout {
            return try await localRepository.getAllProducts()
        }
        
        let products = try await remoteRepository.getAllProducts()
        try await localRepository.createProducts(products)
        UserDefaults.standard.set(Date(), forKey: "lastProductFetchTime")
        return products
    }
    
    // Implement other methods similarly
}
```

## 2. Offline Support

Ensuring your app works offline can greatly improve user experience.

```swift
class OfflineFirstProductRepository: ProductRepository {
    private let remoteRepository: ProductRepository
    private let localRepository: ProductRepository
    private let connectivityChecker: ConnectivityChecking
    
    init(remoteRepository: ProductRepository, localRepository: ProductRepository, connectivityChecker: ConnectivityChecking) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
        self.connectivityChecker = connectivityChecker
    }
    
    func getAllProducts() async throws -> [Product] {
        if connectivityChecker.isConnected {
            do {
                let products = try await remoteRepository.getAllProducts()
                try await localRepository.createProducts(products)
                return products
            } catch {
                return try await localRepository.getAllProducts()
            }
        } else {
            return try await localRepository.getAllProducts()
        }
    }
    
    // Implement other methods similarly
}
```

## 3. Data Synchronization

For apps that work offline, implementing a robust synchronization mechanism is crucial.

```swift
class SyncManager {
    private let remoteRepository: ProductRepository
    private let localRepository: ProductRepository
    
    init(remoteRepository: ProductRepository, localRepository: ProductRepository) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }
    
    func sync() async throws {
        let localProducts = try await localRepository.getAllProducts()
        let remoteProducts = try await remoteRepository.getAllProducts()
        
        let productsToUpdate = localProducts.filter { localProduct in
            remoteProducts.contains { $0.id == localProduct.id && $0 != localProduct }
        }
        
        for product in productsToUpdate {
            try await remoteRepository.updateProduct(product)
        }
        
        let newRemoteProducts = remoteProducts.filter { remoteProduct in
            !localProducts.contains { $0.id == remoteProduct.id }
        }
        
        for product in newRemoteProducts {
            try await localRepository.createProduct(product)
        }
    }
}
```

## 4. Pagination

For large datasets, implementing pagination can improve performance and reduce data usage.

```swift
protocol PaginatedProductRepository: ProductRepository {
    func getProducts(page: Int, pageSize: Int) async throws -> (products: [Product], hasNextPage: Bool)
}

class PaginatedRemoteProductRepository: PaginatedProductRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getProducts(page: Int, pageSize: Int) async throws -> (products: [Product], hasNextPage: Bool) {
        let endpoint = ProductEndpoint.getProducts(page: page, pageSize: pageSize)
        let response: PaginatedResponse<Product> = try await apiClient.request(endpoint)
        return (products: response.items, hasNextPage: response.hasNextPage)
    }
    
    // Implement other methods
}
```

## 5. Error Handling and Retry Logic

Implementing robust error handling and retry logic can make your app more resilient.

```swift
class RetryingProductRepository: ProductRepository {
    private let repository: ProductRepository
    private let maxRetries: Int
    
    init(repository: ProductRepository, maxRetries: Int = 3) {
        self.repository = repository
        self.maxRetries = maxRetries
    }
    
    func getAllProducts() async throws -> [Product] {
        var lastError: Error?
        for _ in 0..<maxRetries {
            do {
                return try await repository.getAllProducts()
            } catch {
                lastError = error
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retrying
            }
        }
        throw lastError ?? RepositoryError.unknown
    }
    
    // Implement other methods similarly
}
```

## 6. Reactive Programming

Consider using Combine (or RxSwift) for reactive data updates.

```swift
import Combine

class ReactiveProductRepository: ProductRepository {
    private let repository: ProductRepository
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private(set) var products: [Product] = []
    
    init(repository: ProductRepository) {
        self.repository = repository
        
        $products
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] products in
                Task {
                    try await self?.syncProducts(products)
                }
            }
            .store(in: &cancellables)
    }
    
    private func syncProducts(_ products: [Product]) async throws {
        for product in products {
            try await repository.updateProduct(product)
        }
    }
    
    func updateProduct(_ product: Product) async throws {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
    }
    
    // Implement other methods
}
```
