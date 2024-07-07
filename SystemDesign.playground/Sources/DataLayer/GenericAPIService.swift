//https://www.mermaidchart.com/raw/2fe68ec3-6cf3-4629-9a2a-9d9087cca597?theme=light&version=v0.1&format=svg

import Foundation

// MARK: - API Service Protocol

protocol APIServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - API Service Implementation

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

// MARK: - Endpoint

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

// MARK: - Endpoint Factory

class EndpointFactory {
    static func makeProductEndpoint(id: String) -> Endpoint {
        Endpoint(path: "/products/\(id)", method: .get, headers: [:], body: nil)
    }
    
    static func makeUserEndpoint(id: String) -> Endpoint {
        Endpoint(path: "/users/\(id)", method: .get, headers: [:], body: nil)
    }
    
    static func makeCartEndpoint() -> Endpoint {
        Endpoint(path: "/cart", method: .get, headers: [:], body: nil)
    }
}

// MARK: - API Errors

enum APIError: Error {
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}

// MARK: - Usage in Repository

class ProductRepository {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func getProduct(id: String) async throws -> Product {
        let endpoint = EndpointFactory.makeProductEndpoint(id: id)
        return try await apiService.request(endpoint)
    }
}

// MARK: - Usage in View Model

@MainActor
class ProductViewModel: ObservableObject {
    private let repository: ProductRepository
    @Published var product: Product?
    @Published var error: Error?
    
    init(repository: ProductRepository = ProductRepository()) {
        self.repository = repository
    }
    
    func fetchProduct(id: String) async {
        do {
            product = try await repository.getProduct(id: id)
        } catch {
            self.error = error
        }
    }
}

// MARK: - Usage in View

struct ProductView: View {
    @StateObject private var viewModel = ProductViewModel()
    let productId: String
    
    var body: some View {
        Group {
            if let product = viewModel.product {
                Text(product.name)
                // More product details...
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetchProduct(id: productId)
        }
    }
}
