/*
 The Repository Pattern:
 The Repository pattern is a design pattern that abstracts the data access logic in your application. It acts as a mediator between the domain/business logic and the data mapping layers (like databases, network services, etc.).
 Key aspects of the Repository pattern:

 Abstraction: It provides a clean API for accessing data without exposing the underlying data source details.
 Separation of Concerns: It separates the logic that retrieves the data and maps it to the entity model from the business logic that acts on the model.
 Centralized Data Access Logic: It centralizes common data access functionality, providing better maintainability.
 Improved Testability: By abstracting the data layer, it becomes easier to unit test your application logic.

 In our implementation:

 We defined a ProductRepository protocol that outlines the operations for product data:
 swiftCopyprotocol ProductRepository {
     func getProduct(id: Int) async throws -> Product
     func getAllProducts() async throws -> [Product]
     func saveProduct(_ product: Product) async throws
     func deleteProduct(id: Int) async throws
 }

 We created two concrete implementations of this repository:

 LocalProductDataSource: Manages data in Core Data
 RemoteProductDataSource: Fetches data from a remote API


 We implemented a CachedProductRepository that combines both local and remote data sources, implementing a caching strategy.
 Our ProductViewModel uses this repository, not caring about whether the data comes from a local database or a remote API.

 Discussion points:

 Flexibility: The Repository pattern allows us to easily switch or combine data sources without changing the rest of the application. For example, we could replace Core Data with Realm or SQLite without affecting the ViewModel or UI.
 Testability: We can easily create mock repositories for testing our ViewModel without needing to set up real databases or make network calls.
 Separation of Concerns: Our ViewController doesn't need to know anything about Core Data or network calls. It just works with the ViewModel, which in turn works with the Repository.
 Caching Strategy: The CachedProductRepository demonstrates how we can implement complex data strategies (like caching) behind a simple interface.
 Asynchronous Operations: Our use of async/await in the repository methods allows for easy handling of asynchronous operations like network calls or database access.
 Error Handling: The repository methods are designed to throw errors, allowing for centralized error handling in the ViewModel.

 Comparing to direct data access:
 If we weren't using the Repository pattern, we might have Core Data or network call logic directly in our ViewControllers or ViewModels. This would make the code less modular, harder to test, and more difficult to maintain or change in the future.
 In conclusion, the Repository pattern provides a clean, modular approach to data management in our application, allowing for flexibility, improved testability, and clear separation of concerns.
 */
 /*
Problem: Product Data Management using Repository Pattern

Description:
You're developing an iOS e-commerce app that needs to manage product data efficiently. The app should be able to fetch product information from multiple sources (local database, remote API) and cache it for offline use. You want to implement a system that provides a clean API for product data operations while abstracting away the complexities of data sourcing and caching.

Why Repository Pattern?
The Repository pattern is suitable here because:
1. It provides a clean, consistent API for data operations, regardless of the data source.
2. It allows for easy switching or combination of data sources (e.g., local cache vs. remote API).
3. It centralizes data mapping and error handling logic.
4. It facilitates testing by allowing easy mocking of data sources.

Step-by-Step Requirements:

1. Create a `Product` struct to represent product data.
   Why: This defines the core data model for products in the app.

2. Define a `ProductRepository` protocol with methods for CRUD operations:
   - func getProduct(id: String) -> AnyPublisher<Product, Error>
   - func getAllProducts() -> AnyPublisher<[Product], Error>
   - func saveProduct(_ product: Product) -> AnyPublisher<Void, Error>
   - func deleteProduct(id: String) -> AnyPublisher<Void, Error>
   Why: This establishes a consistent interface for product data operations.

3. Implement a `LocalProductDataSource` class that manages product data in a local database (e.g., Core Data, Realm).
   Why: This handles persistent local storage of product data.

4. Implement a `RemoteProductDataSource` class that fetches product data from a remote API.
   Why: This manages retrieval of up-to-date product data from the server.

5. Create a `ProductRepositoryImpl` class that:
   - Conforms to the `ProductRepository` protocol
   - Uses both `LocalProductDataSource` and `RemoteProductDataSource`
   - Implements caching logic (fetch from remote, save to local)
   Why: This provides the main implementation of the repository, managing data from multiple sources.

6. Use Combine framework for asynchronous operations and data streaming.
   Why: This provides a modern, reactive approach to handling asynchronous data operations.

Example usage:
let repository = ProductRepositoryImpl(localDataSource: localDS, remoteDataSource: remoteDS)

repository.getProduct(id: "12345")
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { product in
            print("Retrieved product: \(product.name)")
        }
    )
    .store(in: &cancellables)

Implement the Repository pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Repository pattern compare to directly using Core Data or URLSession in view controllers?
2. In what other scenarios in an e-commerce app might the Repository pattern be useful?
3. How might this pattern be extended to handle data sync between local and remote sources?

What is the Repository design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here

import Combine
import Foundation

enum Environment {
    case development
    case staging
    case production
}

struct APIConfiguration {
    let baseURL: URL
    
    init(environment: Environment) {
        switch environment {
        case .development:
            baseURL = URL(string: "https://dev-api.example.com/products")!
        case .staging:
            baseURL = URL(string: "https://staging-api.example.com/products")!
        case .production:
            baseURL = URL(string: "https://fakestoreapi.com/products")!
        }
    }
    
    #if DEBUG
    static let current = APIConfiguration(environment: .development)
    #else
    static let current = APIConfiguration(environment: .production)
    #endif
}

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
}

protocol ProductRepository {
    func getProduct(id: Int) -> AnyPublisher<Product, Error>
    func getAllProducts() -> AnyPublisher<[Product], Error>
    func saveProduct(_ product: Product) -> AnyPublisher<Void, Error>
    func deleteProduct(id: Int) -> AnyPublisher<Void, Error>
}

// Local Data Source
class LocalProductDataSource: ProductRepository {
    private var products: [Int: Product] = [:]
    
    func getProduct(id: Int) -> AnyPublisher<Product, Error> {
        guard let product = products[id] else {
            return Fail(error: NSError(domain: "LocalProductDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
                .eraseToAnyPublisher()
        }
        return Just(product)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAllProducts() -> AnyPublisher<[Product], Error> {
        return Just(Array(products.values))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveProduct(_ product: Product) -> AnyPublisher<Void, Error> {
        products[product.id] = product
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteProduct(id: Int) -> AnyPublisher<Void, Error> {
        products.removeValue(forKey: id)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class RemoteProductDataSource: ProductRepository {
    private let baseURL: URL
    private let session: URLSession
    private let backgroundQueue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    init(baseURL: URL, session: URLSession = .shared, backgroundQueue: DispatchQueue = DispatchQueue(label: "com.example.RemoteProductDataSource")) {
        self.baseURL = baseURL
        self.session = session
        self.backgroundQueue = backgroundQueue
    }
    
    func getProduct(id: Int) -> AnyPublisher<Product, Error> {
        let url = baseURL.appendingPathComponent(String(id))
        return session.dataTaskPublisher(for: url)
            .subscribe(on: backgroundQueue)
            .map(\.data)
            .decode(type: Product.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getAllProducts() -> AnyPublisher<[Product], Error> {
        return session.dataTaskPublisher(for: baseURL)
            .subscribe(on: backgroundQueue)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveProduct(_ product: Product) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(NSError(domain: "RemoteProductDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                    return
                }
                
                do {
                    let data = try JSONEncoder().encode(product)
                    var request = URLRequest(url: self.baseURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = data
                    
                    self.session.dataTaskPublisher(for: request)
                        .subscribe(on: self.backgroundQueue)
                        .map { _ in () }
                        .mapError { $0 as Error }
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { promise(.success(())) }
                        )
                        .store(in: &self.cancellables)
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteProduct(id: Int) -> AnyPublisher<Void, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(String(id)))
        request.httpMethod = "DELETE"
        
        return session.dataTaskPublisher(for: request)
            .subscribe(on: backgroundQueue)
            .map { _ in () }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}


class CachedProductRepository: ProductRepository {
    private let localDataSource: ProductRepository
    private let remoteDataSource: ProductRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(localDataSource: ProductRepository, remoteDataSource: ProductRepository) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func getProduct(id: Int) -> AnyPublisher<Product, Error> {
        return localDataSource.getProduct(id: id)
            .catch { _ in
                self.remoteDataSource.getProduct(id: id)
                    .flatMap { product in
                        self.localDataSource.saveProduct(product)
                            .map { product }
                    }
            }
            .eraseToAnyPublisher()
    }
    
    func getAllProducts() -> AnyPublisher<[Product], Error> {
        return remoteDataSource.getAllProducts()
            .flatMap { products in
                self.cacheProducts(products)
                    .map { products }
            }
            .catch { _ in self.localDataSource.getAllProducts() }
            .eraseToAnyPublisher()
    }
    
    func saveProduct(_ product: Product) -> AnyPublisher<Void, Error> {
        return remoteDataSource.saveProduct(product)
            .flatMap { _ in self.localDataSource.saveProduct(product) }
            .eraseToAnyPublisher()
    }
    
    func deleteProduct(id: Int) -> AnyPublisher<Void, Error> {
        return remoteDataSource.deleteProduct(id: id)
            .flatMap { _ in self.localDataSource.deleteProduct(id: id) }
            .eraseToAnyPublisher()
    }
    
    private func cacheProducts(_ products: [Product]) -> AnyPublisher<Void, Error> {
        let savePublishers = products.map { localDataSource.saveProduct($0) }
        return Publishers.MergeMany(savePublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}


class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentProduct: Product?
    @Published var errorMessage: String?
    
    private let repository: ProductRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func loadAllProducts() {
        repository.getAllProducts()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] products in
                    self?.products = products
                }
            )
            .store(in: &cancellables)
    }
    
    func loadProduct(id: Int) {
        repository.getProduct(id: id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] product in
                    self?.currentProduct = product
                }
            )
            .store(in: &cancellables)
    }
    
    func saveProduct(_ product: Product) {
        repository.saveProduct(product)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: {
                    print("Product saved successfully")
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteProduct(id: Int) {
        repository.deleteProduct(id: id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: {
                    print("Product deleted successfully")
                }
            )
            .store(in: &cancellables)
    }
}

// Usage in app startup or dependency injection
func setupRepositories() -> ProductRepository {
    // Setup LocalProductDataSource
    let localDataSource = LocalProductDataSource()
    
    // Setup RemoteProductDataSource
    let baseURL = APIConfiguration.current.baseURL
    let remoteDataSource = RemoteProductDataSource(baseURL: baseURL)
    
    // Create CachedProductRepository
    return CachedProductRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
}

// In your app's main or scene delegate
let productRepository = setupRepositories()
let viewModel = ProductViewModel(repository: productRepository)

// Example usage in a view controller or SwiftUI view
func loadAndDisplayProducts() {
    viewModel.loadAllProducts()
    // Bind viewModel.products to your UI
}

func displayProductDetails(id: Int) {
    viewModel.loadProduct(id: id)
    // Bind viewModel.currentProduct to your UI
}

func saveNewProduct() {
    let newProduct = Product(id: Int.random(in: 0...Int.max), title: "New Product", price: 29.99, description: "A brand new product")
    viewModel.saveProduct(newProduct)
}

func removeProduct(id: Int) {
    viewModel.deleteProduct(id: id)
}



// Usage
let configuration = APIConfiguration.current
let remoteDS = RemoteProductDataSource(baseURL: configuration.baseURL)

// For testing or specific environment needs:
let stagingConfig = APIConfiguration(environment: .staging)
let stagingRemoteDS = RemoteProductDataSource(baseURL: stagingConfig.baseURL)

var cancellables = Set<AnyCancellable>()

remoteDS.getProduct(id: 1)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { product in
            print("Retrieved product: \(product.title)")
        }
    )
    .store(in: &cancellables)
// Updated RemoteProductDataSource
