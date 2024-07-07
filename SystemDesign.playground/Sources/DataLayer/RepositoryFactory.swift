//https://www.mermaidchart.com/raw/723cb048-9252-4bfc-b15a-7d46e9718d74?theme=light&version=v0.1&format=svg

// MARK: - Repositories

protocol ProductRepository {
    func getProducts() async throws -> [Product]
    func getProduct(id: String) async throws -> Product
}

protocol UserRepository {
    func getUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws
}

protocol CartRepository {
    func getCart() async throws -> Cart
    func addToCart(product: Product) async throws
    func removeFromCart(product: Product) async throws
}

// Implementations would be similar to the ProductRepositoryImpl shown earlier

// MARK: - Repository Factory

class RepositoryFactory {
    static let shared = RepositoryFactory()
    
    private let apiService: APIService
    private let storageService: LocalStorageService
    
    private init() {
        self.apiService = APIService()
        self.storageService = LocalStorageService()
    }
    
    func makeProductRepository() -> ProductRepository {
        return ProductRepositoryImpl(apiService: apiService, storageService: storageService)
    }
    
    func makeUserRepository() -> UserRepository {
        return UserRepositoryImpl(apiService: apiService, storageService: storageService)
    }
    
    func makeCartRepository() -> CartRepository {
        return CartRepositoryImpl(apiService: apiService, storageService: storageService)
    }
}

// MARK: - View Model Usage

class ProductCatalogViewModel: ObservableObject {
    private let productRepository: ProductRepository
    private let cartRepository: CartRepository
    
    init(productRepository: ProductRepository, cartRepository: CartRepository) {
        self.productRepository = productRepository
        self.cartRepository = cartRepository
    }
    
    func loadProducts() async throws {
        // Use productRepository
    }
    
    func addToCart(_ product: Product) async throws {
        // Use cartRepository
    }
}

// MARK: - View Usage

struct ProductCatalogView: View {
    @StateObject private var viewModel: ProductCatalogViewModel
    
    init() {
        let repositoryFactory = RepositoryFactory.shared
        let productRepository = repositoryFactory.makeProductRepository()
        let cartRepository = repositoryFactory.makeCartRepository()
        _viewModel = StateObject(wrappedValue: ProductCatalogViewModel(
            productRepository: productRepository,
            cartRepository: cartRepository
        ))
    }
    
    var body: some View {
        // Use viewModel
    }
}
