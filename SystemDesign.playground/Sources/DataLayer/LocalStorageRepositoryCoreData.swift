# Local Storage with Repository Design Pattern

## Overview

The repository pattern provides an abstraction layer between the data access logic and the business logic of an application. When implementing local storage, we'll create a `LocalProductRepository` that conforms to the same `ProductRepository` protocol as our `RemoteProductRepository`. This allows us to easily switch between or combine local and remote data sources.

## Structure

1. **Core Data Model**: Defines the structure of our local database.
2. **ProductRepository Protocol**: Defines the interface for all product repositories.
3. **LocalProductRepository**: Implements the ProductRepository protocol using Core Data.
4. **CoreDataStack**: Manages the Core Data stack (persistent container, contexts).
5. **ProductMapper**: Converts between Core Data entities and domain models.

## Implementation

### 1. Core Data Model

First, create a Core Data model file (`Product.xcdatamodeld`) with a `ProductEntity`:

Attributes:
- id: String
- name: String
- price: Double

### 2. ProductRepository Protocol

```swift
protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func createProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(id: String) async throws
}
```

### 3. LocalProductRepository

```swift
import CoreData

class LocalProductRepository: ProductRepository {
    private let coreDataStack: CoreDataStack
    private let mapper: ProductMapper

    init(coreDataStack: CoreDataStack = CoreDataStack.shared, mapper: ProductMapper = ProductMapper()) {
        self.coreDataStack = coreDataStack
        self.mapper = mapper
    }

    func getProduct(id: String) async throws -> Product {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        let results = try context.fetch(fetchRequest)
        guard let productEntity = results.first else {
            throw RepositoryError.notFound
        }

        return mapper.mapToDomain(productEntity)
    }

    func getAllProducts() async throws -> [Product] {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()

        let productEntities = try context.fetch(fetchRequest)
        return productEntities.map(mapper.mapToDomain)
    }

    func createProduct(_ product: Product) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let productEntity = ProductEntity(context: context)
            self.mapper.mapToEntity(product, entity: productEntity)
            try context.save()
        }
    }

    func updateProduct(_ product: Product) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", product.id)
            
            guard let productEntity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }
            
            self.mapper.mapToEntity(product, entity: productEntity)
            try context.save()
        }
    }

    func deleteProduct(id: String) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            guard let productEntity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.notFound
            }
            
            context.delete(productEntity)
            try context.save()
        }
    }
}
```

### 4. CoreDataStack

```swift
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Product")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}
```

### 5. ProductMapper

```swift
struct ProductMapper {
    func mapToDomain(_ entity: ProductEntity) -> Product {
        return Product(
            id: entity.id ?? "",
            name: entity.name ?? "",
            price: entity.price
        )
    }

    func mapToEntity(_ domain: Product, entity: ProductEntity) {
        entity.id = domain.id
        entity.name = domain.name
        entity.price = domain.price
    }
}
```

### Usage in ViewModel

```swift
class ProductViewModel: ObservableObject {
    private let repository: ProductRepository

    init(repository: ProductRepository = LocalProductRepository()) {
        self.repository = repository
    }

    @Published var products: [Product] = []

    func fetchProducts() async {
        do {
            products = try await repository.getAllProducts()
        } catch {
            print("Error fetching products: \(error)")
        }
    }

    // Add other methods for creating, updating, and deleting products
}
```
