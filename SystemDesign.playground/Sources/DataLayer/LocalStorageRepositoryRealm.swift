import Foundation
import RealmSwift

// MARK: - Realm Object

class RealmProduct: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var name: String = ""
    @Persisted var price: Double = 0.0
}

// MARK: - Domain Model

struct Product: Identifiable {
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

// MARK: - Realm Manager

class RealmManager {
    static let shared = RealmManager()
    private init() {}
    
    func realm() throws -> Realm {
        try Realm()
    }
}

// MARK: - Product Mapper

struct ProductMapper {
    func mapToDomain(_ realmProduct: RealmProduct) -> Product {
        Product(id: realmProduct.id, name: realmProduct.name, price: realmProduct.price)
    }
    
    func mapToRealm(_ product: Product) -> RealmProduct {
        let realmProduct = RealmProduct()
        realmProduct.id = product.id
        realmProduct.name = product.name
        realmProduct.price = product.price
        return realmProduct
    }
}

// MARK: - Local Product Repository

class LocalProductRepository: ProductRepository {
    private let realmManager: RealmManager
    private let mapper: ProductMapper
    
    init(realmManager: RealmManager = .shared, mapper: ProductMapper = ProductMapper()) {
        self.realmManager = realmManager
        self.mapper = mapper
    }
    
    func getProduct(id: String) async throws -> Product {
        let realm = try realmManager.realm()
        guard let realmProduct = realm.object(ofType: RealmProduct.self, forPrimaryKey: id) else {
            throw RepositoryError.notFound
        }
        return mapper.mapToDomain(realmProduct)
    }
    
    func getAllProducts() async throws -> [Product] {
        let realm = try realmManager.realm()
        let realmProducts = realm.objects(RealmProduct.self)
        return realmProducts.map(mapper.mapToDomain)
    }
    
    func createProduct(_ product: Product) async throws {
        let realm = try realmManager.realm()
        let realmProduct = mapper.mapToRealm(product)
        try await realm.asyncWrite {
            realm.add(realmProduct)
        }
    }
    
    func updateProduct(_ product: Product) async throws {
        let realm = try realmManager.realm()
        try await realm.asyncWrite {
            realm.create(RealmProduct.self, value: mapper.mapToRealm(product), update: .modified)
        }
    }
    
    func deleteProduct(id: String) async throws {
        let realm = try realmManager.realm()
        guard let realmProduct = realm.object(ofType: RealmProduct.self, forPrimaryKey: id) else {
            throw RepositoryError.notFound
        }
        try await realm.asyncWrite {
            realm.delete(realmProduct)
        }
    }
}

// MARK: - Repository Error

enum RepositoryError: Error {
    case notFound
}

// MARK: - View Model

@MainActor
class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    @Published var products: [Product] = []
    @Published var error: Error?
    
    init(repository: ProductRepository = LocalProductRepository()) {
        self.repository = repository
    }
    
    func fetchProducts() async {
        do {
            products = try await repository.getAllProducts()
        } catch {
            self.error = error
        }
    }
    
    func addProduct(_ product: Product) async {
        do {
            try await repository.createProduct(product)
            await fetchProducts()
        } catch {
            self.error = error
        }
    }
    
    // Implement other methods (updateProduct, deleteProduct) similarly
}

// MARK: - View

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    Text("Price: $\(product.price, specifier: "%.2f")")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Products")
            .task {
                await viewModel.fetchProducts()
            }
        }
    }
}
