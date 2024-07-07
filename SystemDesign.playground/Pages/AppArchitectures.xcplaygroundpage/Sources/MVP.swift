
/*:
 Now, let's break down the MVP structure and explain the reasoning behind the changes:

 Model:

 Still includes the Product struct.
 Now also includes the ProductService protocol and MockProductService implementation.
 Reason: The Model in MVP includes both data structures and business logic.


 View:

 Now includes a ProductListView protocol and the ProductListViewController.
 The ViewController is much simpler, focusing only on UI-related tasks.
 Reason: This makes the View more passive and easier to test.


 Presenter:

 New addition: ProductListPresenter class.
 Handles the business logic of fetching products and updating the view.
 Reason: Separates business logic from the ViewController, making it more testable and maintainable.



 Key points about MVP:

 Separation of Concerns:

 The View (ViewController) is now only responsible for displaying data and capturing user input.
 The Presenter handles the business logic and acts as a mediator between Model and View.
 This separation makes each component more focused and easier to maintain.


 Testability:

 The Presenter can be easily unit tested without dependencies on UIKit.
 The View can be mocked for testing the Presenter.


 Flexibility:

 The View and Presenter are connected through protocols, allowing easy substitution of implementations.


 Reduced View Controller Complexity:

 The ViewController is now much simpler, avoiding the "Massive View Controller" problem common in MVC.


 Unidirectional Data Flow:

 Data flows from Model -> Presenter -> View, making the app's behavior more predictable.



 This MVP structure addresses several limitations of MVC:

 It reduces the responsibilities of the ViewController.
 It improves testability by decoupling business logic from UIKit.
 It provides a clearer separation of concerns.

 However, MVP can lead to a lot of boilerplate code, especially for complex views. In our next step, we'll look at how MVVM addresses this while maintaining the benefits of MVP.
*/

import UIKit

// Model
struct Product {
    let id: Int
    let name: String
    let price: Double
}

// View Protocol
protocol ProductListView: AnyObject {
    func displayProducts(_ products: [Product])
    func displayError(_ error: Error)
}

// Presenter
class ProductListPresenter {
    weak var view: ProductListView?
    private let productService: ProductService
    
    init(productService: ProductService) {
        self.productService = productService
    }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        productService.fetchProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.view?.displayProducts(products)
            case .failure(let error):
                self?.view?.displayError(error)
            }
        }
    }
}

// View
class ProductListViewController: UIViewController, UITableViewDataSource, ProductListView {
    private let tableView = UITableView()
    private var products: [Product] = []
    private let presenter: ProductListPresenter
    
    init(presenter: ProductListPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
    }
    
    // ProductListView protocol methods
    func displayProducts(_ products: [Product]) {
        self.products = products
        tableView.reloadData()
    }
    
    func displayError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        // In a real app, you'd show an alert or error view to the user
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = "\(product.name) - $\(product.price)"
        return cell
    }
}

// Service (part of the Model in MVP)
protocol ProductService {
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)
}

class MockProductService: ProductService {
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        let products = [
            Product(id: 1, name: "iPhone", price: 999.99),
            Product(id: 2, name: "MacBook", price: 1299.99),
            Product(id: 3, name: "AirPods", price: 159.99)
        ]
        completion(.success(products))
    }
}

// Usage
let productService = MockProductService()
let presenter = ProductListPresenter(productService: productService)
let productListVC = ProductListViewController(presenter: presenter)
// In a real app, you'd present this view controller
