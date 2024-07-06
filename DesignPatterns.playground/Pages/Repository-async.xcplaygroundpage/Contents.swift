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

import Foundation
import CoreData
import Combine
import PlaygroundSupport

// MARK: - Error Handling

enum ProductError: Error {
    case networkError(Error)
    case decodingError(Error)
    case databaseError(Error)
    case notFound
    case invalidInput
    case unknown
}

// MARK: - Models

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
}

// MARK: - Core Data Setup

class ProductEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var price: Double
    @NSManaged var productDescription: String?
}

extension ProductEntity {
    static func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }
    
    func toProduct() -> Product {
        return Product(id: Int(id), title: title ?? "", price: price, description: productDescription ?? "")
    }
}

class CustomPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return URL(fileURLWithPath: "/dev/null")
    }
}

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let model = NSManagedObjectModel()
        let productEntity = NSEntityDescription()
        productEntity.name = "ProductEntity"
        productEntity.managedObjectClassName = NSStringFromClass(ProductEntity.self)
        
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .integer64AttributeType
        idAttribute.isOptional = false
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = true
        
        let priceAttribute = NSAttributeDescription()
        priceAttribute.name = "price"
        priceAttribute.attributeType = .doubleAttributeType
        priceAttribute.isOptional = false
        
        let descriptionAttribute = NSAttributeDescription()
        descriptionAttribute.name = "productDescription"
        descriptionAttribute.attributeType = .stringAttributeType
        descriptionAttribute.isOptional = true
        
        productEntity.properties = [idAttribute, titleAttribute, priceAttribute, descriptionAttribute]
        model.entities = [productEntity]
        
        let container = CustomPersistentContainer(name: "ProductModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}


// MARK: - Repository Protocol

protocol ProductRepository {
    func getProduct(id: Int) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func saveProduct(_ product: Product) async throws
    func deleteProduct(id: Int) async throws
}

// MARK: - Local Data Source

class LocalProductDataSource: ProductRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func getProduct(id: Int) async throws -> Product {
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let productEntity = results.first {
                return productEntity.toProduct()
            } else {
                throw ProductError.notFound
            }
        } catch {
            throw ProductError.databaseError(error)
        }
    }
    
    func getAllProducts() async throws -> [Product] {
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { $0.toProduct() }
        } catch {
            throw ProductError.databaseError(error)
        }
    }
    
    func saveProduct(_ product: Product) async throws {
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", product.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let productEntity: ProductEntity
            if let existingProduct = results.first {
                productEntity = existingProduct
            } else {
                productEntity = ProductEntity(context: context)
                productEntity.id = Int64(product.id)
            }
            
            productEntity.title = product.title
            productEntity.price = product.price
            productEntity.productDescription = product.description
            
            try context.save()
        } catch {
            throw ProductError.databaseError(error)
        }
    }
    
    func deleteProduct(id: Int) async throws {
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let productEntity = results.first {
                context.delete(productEntity)
                try context.save()
            } else {
                throw ProductError.notFound
            }
        } catch {
            throw ProductError.databaseError(error)
        }
    }
}

// MARK: - Remote Data Source

class RemoteProductDataSource: ProductRepository {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func getProduct(id: Int) async throws -> Product {
        let url = baseURL.appendingPathComponent(String(id))
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Product.self, from: data)
    }
    
    func getAllProducts() async throws -> [Product] {
        let (data, _) = try await session.data(from: baseURL)
        return try JSONDecoder().decode([Product].self, from: data)
    }
    
    func saveProduct(_ product: Product) async throws {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(product)
        let (_, _) = try await session.data(for: request)
    }
    
    func deleteProduct(id: Int) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(String(id)))
        request.httpMethod = "DELETE"
        let (_, _) = try await session.data(for: request)
    }
}

// MARK: - Cached Product Repository

class CachedProductRepository: ProductRepository {
    private let localDataSource: ProductRepository
    private let remoteDataSource: ProductRepository
    
    init(localDataSource: ProductRepository, remoteDataSource: ProductRepository) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func getProduct(id: Int) async throws -> Product {
        do {
            return try await localDataSource.getProduct(id: id)
        } catch {
            let product = try await remoteDataSource.getProduct(id: id)
            try await localDataSource.saveProduct(product)
            return product
        }
    }
    
    func getAllProducts() async throws -> [Product] {
        do {
            let products = try await remoteDataSource.getAllProducts()
            for product in products {
                try await localDataSource.saveProduct(product)
            }
            return products
        } catch {
            return try await localDataSource.getAllProducts()
        }
    }
    
    func saveProduct(_ product: Product) async throws {
        try await remoteDataSource.saveProduct(product)
        try await localDataSource.saveProduct(product)
    }
    
    func deleteProduct(id: Int) async throws {
        try await remoteDataSource.deleteProduct(id: id)
        try await localDataSource.deleteProduct(id: id)
    }
}

// MARK: - View Model

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentProduct: Product?
    @Published var errorMessage: String?
    
    private let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func loadAllProducts() async {
        do {
            products = try await repository.getAllProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadProduct(id: Int) async {
        do {
            currentProduct = try await repository.getProduct(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func saveProduct(_ product: Product) async {
        do {
            try await repository.saveProduct(product)
            print("Product saved successfully")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteProduct(id: Int) async throws {
        do {
            try await repository.deleteProduct(id: id)
            print("Product deleted successfully")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - API Configuration

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


// MARK: - Setup and Usage

func setupRepositories() -> ProductRepository {
    let localDataSource = LocalProductDataSource(context: CoreDataStack.shared.context)
    let remoteDataSource = RemoteProductDataSource(baseURL: APIConfiguration.current.baseURL)
    return CachedProductRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
}

func createViewModel() -> ProductViewModel {
    let productRepository = setupRepositories()
    return ProductViewModel(repository: productRepository)
}


// MARK: - Example Usage

func exampleUsage(viewModel: ProductViewModel) async throws {
    await viewModel.loadAllProducts()
    print("Loaded \(await viewModel.products.count) products")
    
    await viewModel.loadProduct(id: 1)
    if let product = await viewModel.currentProduct {
        print("Loaded product: \(product.title)")
    }
    
    let newProduct = Product(id: Int.random(in: 1000...9999), title: "New Product", price: 29.99, description: "A brand new product")
    await viewModel.saveProduct(newProduct)
    
    try await viewModel.deleteProduct(id: -1)
}

// MARK: - Preview in Playground 1
//Task {
//    do {
//        let viewModel = await createViewModel()
//        try await exampleUsage(viewModel: viewModel)
//        
//        // If you want to test error handling, you can add a throwing operation here
//        // For example:
//        // try await viewModel.repository.deleteProduct(id: -1) // This should throw an error
//    } catch {
//        print("An error occurred: \(error)")
//    }
//}
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//

// MARK: - Dummy View Controller
class DummyViewController {
    private var viewModel: ProductViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        Task {
            await setupBindings()
        }
    }

    @MainActor
    private func setupBindings() {
        viewModel.$products
            .sink { products in
                print("Updated products: \(products)")
            }
            .store(in: &cancellables)
    }

    func viewDidLoad() {
        print("View did load")
        Task {
            await viewModel.loadAllProducts()
        }
    }

    func refreshButtonTapped() {
        print("Refresh button tapped")
        Task {
            await viewModel.loadAllProducts()
        }
    }
}

// MARK: - Preview in Playground 2 - View Controller

//Task {
    let viewModel = createViewModel()
    let viewController = DummyViewController(viewModel: viewModel)
    
    viewController.viewDidLoad()
    viewController.refreshButtonTapped()
//}

PlaygroundPage.current.needsIndefiniteExecution = true



/*
 import UIKit
 import Combine

 class ProductListViewController: UIViewController {
     private let viewModel: ProductViewModel
     private var cancellables = Set<AnyCancellable>()
     
     private lazy var tableView: UITableView = {
         let table = UITableView()
         table.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
         table.delegate = self
         table.dataSource = self
         return table
     }()
     
     private lazy var activityIndicator: UIActivityIndicatorView = {
         let indicator = UIActivityIndicatorView(style: .large)
         indicator.hidesWhenStopped = true
         return indicator
     }()
     
     init(viewModel: ProductViewModel) {
         self.viewModel = viewModel
         super.init(nibName: nil, bundle: nil)
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupUI()
         bindViewModel()
         loadProducts()
     }
     
     private func setupUI() {
         view.backgroundColor = .white
         title = "Products"
         
         view.addSubview(tableView)
         view.addSubview(activityIndicator)
         
         tableView.translatesAutoresizingMaskIntoConstraints = false
         activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             
             activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
         
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
     }
     
     private func bindViewModel() {
         viewModel.$products
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.tableView.reloadData()
             }
             .store(in: &cancellables)
         
         viewModel.$errorMessage
             .compactMap { $0 }
             .receive(on: DispatchQueue.main)
             .sink { [weak self] error in
                 self?.showError(error)
             }
             .store(in: &cancellables)
     }
     
     private func loadProducts() {
         activityIndicator.startAnimating()
         Task {
             await viewModel.loadAllProducts()
             await MainActor.run {
                 activityIndicator.stopAnimating()
             }
         }
     }
     
     @objc private func refreshTapped() {
         loadProducts()
     }
     
     private func showError(_ error: String) {
         let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
     }
 }

 extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewModel.products.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
         let product = viewModel.products[indexPath.row]
         cell.textLabel?.text = product.title
         cell.detailTextLabel?.text = String(format: "$%.2f", product.price)
         return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         let product = viewModel.products[indexPath.row]
         showProductDetails(product)
     }
     
     private func showProductDetails(_ product: Product) {
         let alert = UIAlertController(title: product.title, message: product.description, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
     }
 }
 
 
 */


class MockProductRepository: ProductRepository {
    var products: [Product] = []
    var error: Error?
    
    func getProduct(id: Int) async throws -> Product {
        if let error = error {
            throw error
        }
        return products.first { $0.id == id } ?? Product(id: id, title: "Test Product", price: 9.99, description: "Test Description")
    }
    
    func getAllProducts() async throws -> [Product] {
        if let error = error {
            throw error
        }
        return products
    }
    
    func saveProduct(_ product: Product) async throws {
        if let error = error {
            throw error
        }
        products.append(product)
    }
    
    func deleteProduct(id: Int) async throws {
        if let error = error {
            throw error
        }
        products.removeAll { $0.id == id }
    }
}



import XCTest
@testable import YourAppModule // Replace with your actual module name

class CachedProductRepositoryTests: XCTestCase {
    var localRepository: MockProductRepository!
    var remoteRepository: MockProductRepository!
    var cachedRepository: CachedProductRepository!
    
    override func setUp() {
        super.setUp()
        localRepository = MockProductRepository()
        remoteRepository = MockProductRepository()
        cachedRepository = CachedProductRepository(localDataSource: localRepository, remoteDataSource: remoteRepository)
    }
    
    func testGetProductFetchesFromLocalFirst() async throws {
        let product = Product(id: 1, title: "Test", price: 9.99, description: "Test")
        localRepository.products = [product]
        
        let fetchedProduct = try await cachedRepository.getProduct(id: 1)
        XCTAssertEqual(fetchedProduct.id, product.id)
    }
    
    func testGetProductFetchesFromRemoteWhenLocalFails() async throws {
        let product = Product(id: 1, title: "Test", price: 9.99, description: "Test")
        localRepository.error = NSError(domain: "test", code: 0, userInfo: nil)
        remoteRepository.products = [product]
        
        let fetchedProduct = try await cachedRepository.getProduct(id: 1)
        XCTAssertEqual(fetchedProduct.id, product.id)
        XCTAssertEqual(localRepository.products.count, 1) // Verify it was saved locally
    }
    
    func testGetAllProductsFetchesFromRemoteAndSavesLocally() async throws {
        let products = [
            Product(id: 1, title: "Test1", price: 9.99, description: "Test1"),
            Product(id: 2, title: "Test2", price: 19.99, description: "Test2")
        ]
        remoteRepository.products = products
        
        let fetchedProducts = try await cachedRepository.getAllProducts()
        XCTAssertEqual(fetchedProducts.count, products.count)
        XCTAssertEqual(localRepository.products.count, products.count) // Verify they were saved locally
    }
}




import XCTest
@testable import YourAppModule // Replace with your actual module name

@MainActor
class ProductViewModelTests: XCTestCase {
    var repository: MockProductRepository!
    var viewModel: ProductViewModel!
    
    override func setUp() {
        super.setUp()
        repository = MockProductRepository()
        viewModel = ProductViewModel(repository: repository)
    }
    
    func testLoadAllProducts() async throws {
        let products = [
            Product(id: 1, title: "Test1", price: 9.99, description: "Test1"),
            Product(id: 2, title: "Test2", price: 19.99, description: "Test2")
        ]
        repository.products = products
        
        await viewModel.loadAllProducts()
        
        XCTAssertEqual(viewModel.products.count, products.count)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadAllProductsError() async throws {
        repository.error = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        await viewModel.loadAllProducts()
        
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Test error")
    }
    
    func testLoadProduct() async throws {
        let product = Product(id: 1, title: "Test", price: 9.99, description: "Test")
        repository.products = [product]
        
        await viewModel.loadProduct(id: 1)
        
        XCTAssertEqual(viewModel.currentProduct?.id, product.id)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSaveProduct() async throws {
        let product = Product(id: 1, title: "Test", price: 9.99, description: "Test")
        
        await viewModel.saveProduct(product)
        
        XCTAssertEqual(repository.products.count, 1)
        XCTAssertEqual(repository.products.first?.id, product.id)
        XCTAssertNil(viewModel.errorMessage)
    }
}
