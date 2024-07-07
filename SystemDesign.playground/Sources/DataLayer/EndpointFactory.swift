import Foundation

// MARK: - Environment

enum Environment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.example.com"
        case .staging:
            return "https://staging-api.example.com"
        case .production:
            return "https://api.example.com"
        }
    }
}

// MARK: - API Endpoint Factory

enum APIEndpoint {
    case getProduct(id: String)
    case getAllProducts
    case createProduct(product: Product)
    case updateProduct(id: String, product: Product)
    case deleteProduct(id: String)
    
    // MARK: - Current Environment
    
    static var current: Environment = .development
    
    // MARK: - Endpoint Generation
    
    func endpoint() -> Endpoint {
        switch self {
        case .getProduct(let id):
            return Endpoint(
                path: "/products/\(id)",
                method: .get,
                headers: defaultHeaders
            )
        case .getAllProducts:
            return Endpoint(
                path: "/products",
                method: .get,
                headers: defaultHeaders
            )
        case .createProduct(let product):
            return Endpoint(
                path: "/products",
                method: .post,
                headers: defaultHeaders,
                body: try? JSONEncoder().encode(product)
            )
        case .updateProduct(let id, let product):
            return Endpoint(
                path: "/products/\(id)",
                method: .put,
                headers: defaultHeaders,
                body: try? JSONEncoder().encode(product)
            )
        case .deleteProduct(let id):
            return Endpoint(
                path: "/products/\(id)",
                method: .delete,
                headers: defaultHeaders
            )
        }
    }
    
    // MARK: - Helper Properties
    
    private var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

// MARK: - Endpoint Structure

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    
    init(path: String, method: HTTPMethod, headers: [String: String], body: Data? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: APIEndpoint.current.baseURL) else {
            return nil
        }
        components.path = path
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}

// MARK: - HTTP Method Enum

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Environment Switching

func switchToProductionEnvironment() {
    APIEndpoint.current = .production
}

func switchToStagingEnvironment() {
    APIEndpoint.current = .staging
}

func switchToDevelopmentEnvironment() {
    APIEndpoint.current = .development
}

// MARK: - API Client

class APIClient {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func getProduct(id: String) async throws -> Product {
        let endpoint = APIEndpoint.getProduct(id: id).endpoint()
        return try await apiService.request(endpoint)
    }
    
    func getAllProducts() async throws -> [Product] {
        let endpoint = APIEndpoint.getAllProducts.endpoint()
        return try await apiService.request(endpoint)
    }
    
    func createProduct(_ product: Product) async throws -> Product {
        let endpoint = APIEndpoint.createProduct(product: product).endpoint()
        return try await apiService.request(endpoint)
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        let endpoint = APIEndpoint.updateProduct(id: product.id, product: product).endpoint()
        return try await apiService.request(endpoint)
    }
    
    func deleteProduct(id: String) async throws {
        let endpoint = APIEndpoint.deleteProduct(id: id).endpoint()
        _: try await apiService.request(endpoint) as EmptyResponse
    }
}


import Foundation

// MARK: - Product Model

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
}

// MARK: - Product Repository Protocol

protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func createProduct(_ product: Product) async throws -> Product
    func updateProduct(_ product: Product) async throws -> Product
    func deleteProduct(id: String) async throws
}

// MARK: - Remote Product Repository

class RemoteProductRepository: ProductRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getProduct(id: String) async throws -> Product {
        return try await apiClient.getProduct(id: id)
    }
    
    func getAllProducts() async throws -> [Product] {
        return try await apiClient.getAllProducts()
    }
    
    func createProduct(_ product: Product) async throws -> Product {
        return try await apiClient.createProduct(product)
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        return try await apiClient.updateProduct(product)
    }
    
    func deleteProduct(id: String) async throws {
        try await apiClient.deleteProduct(id: id)
    }
}

// MARK: - Usage Example

@MainActor
class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(repository: ProductRepository = RemoteProductRepository()) {
        self.repository = repository
    }
    
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await repository.getAllProducts()
        } catch {
            errorMessage = "Failed to fetch products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addProduct(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newProduct = try await repository.createProduct(product)
            products.append(newProduct)
        } catch {
            errorMessage = "Failed to add product: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProduct(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedProduct = try await repository.updateProduct(product)
            if let index = products.firstIndex(where: { $0.id == updatedProduct.id }) {
                products[index] = updatedProduct
            }
        } catch {
            errorMessage = "Failed to update product: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteProduct(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteProduct(id: id)
            products.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete product: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Helpers

struct EmptyResponse: Decodable {}
