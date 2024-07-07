import Foundation

// MARK: - Logging Decorator

class LoggingProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    private let logger: Logger
    
    init(_ repository: ProductRepository, logger: Logger) {
        self.decoratee = repository
        self.logger = logger
    }
    
    func getProduct(id: String) async throws -> Product {
        logger.log("Fetching product with id: \(id)")
        do {
            let product = try await decoratee.getProduct(id: id)
            logger.log("Successfully fetched product: \(product.name)")
            return product
        } catch {
            logger.log("Error fetching product: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getAllProducts() async throws -> [Product] {
        logger.log("Fetching all products")
        do {
            let products = try await decoratee.getAllProducts()
            logger.log("Successfully fetched \(products.count) products")
            return products
        } catch {
            logger.log("Error fetching all products: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createProduct(_ product: Product) async throws {
        logger.log("Creating product: \(product.name)")
        do {
            try await decoratee.createProduct(product)
            logger.log("Successfully created product: \(product.name)")
        } catch {
            logger.log("Error creating product: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateProduct(_ product: Product) async throws {
        logger.log("Updating product: \(product.name)")
        do {
            try await decoratee.updateProduct(product)
            logger.log("Successfully updated product: \(product.name)")
        } catch {
            logger.log("Error updating product: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteProduct(id: String) async throws {
        logger.log("Deleting product with id: \(id)")
        do {
            try await decoratee.deleteProduct(id: id)
            logger.log("Successfully deleted product with id: \(id)")
        } catch {
            logger.log("Error deleting product: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Validation Decorator

class ValidatingProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    
    init(_ repository: ProductRepository) {
        self.decoratee = repository
    }
    
    func getProduct(id: String) async throws -> Product {
        guard !id.isEmpty else { throw ValidationError.invalidId }
        return try await decoratee.getProduct(id: id)
    }
    
    func getAllProducts() async throws -> [Product] {
        return try await decoratee.getAllProducts()
    }
    
    func createProduct(_ product: Product) async throws {
        try validate(product)
        try await decoratee.createProduct(product)
    }
    
    func updateProduct(_ product: Product) async throws {
        try validate(product)
        try await decoratee.updateProduct(product)
    }
    
    func deleteProduct(id: String) async throws {
        guard !id.isEmpty else { throw ValidationError.invalidId }
        try await decoratee.deleteProduct(id: id)
    }
    
    private func validate(_ product: Product) throws {
        guard !product.name.isEmpty else { throw ValidationError.emptyName }
        guard product.price >= 0 else { throw ValidationError.invalidPrice }
    }
}

// MARK: - Metrics Decorator

class MetricsProductRepository: ProductRepository {
    private let decoratee: ProductRepository
    private let metrics: Metrics
    
    init(_ repository: ProductRepository, metrics: Metrics) {
        self.decoratee = repository
        self.metrics = metrics
    }
    
    func getProduct(id: String) async throws -> Product {
        let startTime = Date()
        do {
            let product = try await decoratee.getProduct(id: id)
            metrics.recordLatency("get_product", startTime: startTime)
            metrics.incrementCounter("get_product_success")
            return product
        } catch {
            metrics.recordLatency("get_product", startTime: startTime)
            metrics.incrementCounter("get_product_error")
            throw error
        }
    }
    
    func getAllProducts() async throws -> [Product] {
        let startTime = Date()
        do {
            let products = try await decoratee.getAllProducts()
            metrics.recordLatency("get_all_products", startTime: startTime)
            metrics.incrementCounter("get_all_products_success")
            metrics.recordGauge("product_count", value: Double(products.count))
            return products
        } catch {
            metrics.recordLatency("get_all_products", startTime: startTime)
            metrics.incrementCounter("get_all_products_error")
            throw error
        }
    }
    
    func createProduct(_ product: Product) async throws {
        let startTime = Date()
        do {
            try await decoratee.createProduct(product)
            metrics.recordLatency("create_product", startTime: startTime)
            metrics.incrementCounter("create_product_success")
        } catch {
            metrics.recordLatency("create_product", startTime: startTime)
            metrics.incrementCounter("create_product_error")
            throw error
        }
    }
    
    func updateProduct(_ product: Product) async throws {
        let startTime = Date()
        do {
            try await decoratee.updateProduct(product)
            metrics.recordLatency("update_product", startTime: startTime)
            metrics.incrementCounter("update_product_success")
        } catch {
            metrics.recordLatency("update_product", startTime: startTime)
            metrics.incrementCounter("update_product_error")
            throw error
        }
    }
    
    func deleteProduct(id: String) async throws {
        let startTime = Date()
        do {
            try await decoratee.deleteProduct(id: id)
            metrics.recordLatency("delete_product", startTime: startTime)
            metrics.incrementCounter("delete_product_success")
        } catch {
            metrics.recordLatency("delete_product", startTime: startTime)
            metrics.incrementCounter("delete_product_error")
            throw error
        }
    }
}

// MARK: - Helper Protocols and Classes

protocol Logger {
    func log(_ message: String)
}

class ConsoleLogger: Logger {
    func log(_ message: String) {
        print("[\(Date())] \(message)")
    }
}

enum ValidationError: Error {
    case invalidId
    case emptyName
    case invalidPrice
}

protocol Metrics {
    func recordLatency(_ operation: String, startTime: Date)
    func incrementCounter(_ metric: String)
    func recordGauge(_ metric: String, value: Double)
}

class SimpleMetrics: Metrics {
    func recordLatency(_ operation: String, startTime: Date) {
        let latency = Date().timeIntervalSince(startTime)
        print("Latency for \(operation): \(latency) seconds")
    }
    
    func incrementCounter(_ metric: String) {
        print("Incrementing counter: \(metric)")
    }
    
    func recordGauge(_ metric: String, value: Double) {
        print("Recording gauge \(metric): \(value)")
    }
}

// MARK: - Usage

class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    @Published var products: [Product] = []
    
    init(repository: ProductRepository) {
        let baseRepository = RemoteProductRepository(apiClient: APIClient())
        let cachingRepository = CachingProductRepository(baseRepository)
        let offlineRepository = OfflineProductRepository(cachingRepository, localRepository: LocalProductRepository(), connectivityChecker: ConnectivityChecker())
        let retryingRepository = RetryProductRepository(offlineRepository)
        let validatingRepository = ValidatingProductRepository(retryingRepository)
        let loggingRepository = LoggingProductRepository(validatingRepository, logger: ConsoleLogger())
        self.repository = MetricsProductRepository(loggingRepository, metrics: SimpleMetrics())
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
