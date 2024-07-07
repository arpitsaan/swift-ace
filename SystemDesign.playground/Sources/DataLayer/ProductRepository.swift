//https://www.mermaidchart.com/raw/900919b8-0ac1-4b39-8dc6-2ad4da7815a7?theme=light&version=v0.1&format=svg
import Foundation

// MARK: - Product Model

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
}

// MARK: - API Service Protocol and Implementation

protocol APIServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: configuration)
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let urlRequest = endpoint.urlRequest else {
            throw APIError.invalidRequest
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Endpoint and APIError

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: "https://api.example.com\(path)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}

// MARK: - Repository Protocol

protocol ProductRepository {
    func getProduct(id: String) async throws -> Product
    func getAllProducts() async throws -> [Product]
    func saveProduct(_ product: Product) async throws
}

// MARK: - Remote Repository Implementation

class RemoteProductRepository: ProductRepository {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func getProduct(id: String) async throws -> Product {
        let endpoint = Endpoint(path: "/products/\(id)", method: .get, headers: [:], body: nil)
        return try await apiService.request(endpoint)
    }
    
    func getAllProducts() async throws -> [Product] {
        let endpoint = Endpoint(path: "/products", method: .get, headers: [:], body: nil)
        return try await apiService.request(endpoint)
    }
    
    func saveProduct(_ product: Product) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(product)
        let endpoint = Endpoint(path: "/products", method: .post, headers: ["Content-Type": "application/json"], body: data)
        _: try await apiService.request(endpoint) as EmptyResponse
    }
}

// MARK: - Local Repository Implementation

class LocalProductRepository: ProductRepository {
    private var storage: [String: Product] = [:]
    
    func getProduct(id: String) async throws -> Product {
        guard let product = storage[id] else {
            throw RepositoryError.productNotFound
        }
        return product
    }
    
    func getAllProducts() async throws -> [Product] {
        Array(storage.values)
    }
    
    func saveProduct(_ product: Product) async throws {
        storage[product.id] = product
    }
}

// MARK: - Cached Repository Implementation

class CachedProductRepository: ProductRepository {
    private let remoteRepository: ProductRepository
    private let localRepository: ProductRepository
    
    init(remoteRepository: ProductRepository = RemoteProductRepository(),
         localRepository: ProductRepository = LocalProductRepository()) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }
    
    func getProduct(id: String) async throws -> Product {
        do {
            return try await localRepository.getProduct(id: id)
        } catch {
            let product = try await remoteRepository.getProduct(id: id)
            try await localRepository.saveProduct(product)
            return product
        }
    }
    
    func getAllProducts() async throws -> [Product] {
        do {
            return try await localRepository.getAllProducts()
        } catch {
            let products = try await remoteRepository.getAllProducts()
            for product in products {
                try await localRepository.saveProduct(product)
            }
            return products
        }
    }
    
    func saveProduct(_ product: Product) async throws {
        try await remoteRepository.saveProduct(product)
        try await localRepository.saveProduct(product)
    }
}

// MARK: - View Model

@MainActor
class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    @Published var products: [Product] = []
    @Published var error: Error?
    
    init(repository: ProductRepository = CachedProductRepository()) {
        self.repository = repository
    }
    
    func fetchAllProducts() async {
        do {
            products = try await repository.getAllProducts()
        } catch {
            self.error = error
        }
    }
}

// MARK: - Helpers

struct EmptyResponse: Decodable {}

enum RepositoryError: Error {
    case productNotFound
}
