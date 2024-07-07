/*:
 Now, let's break down the MVC structure and explain the reasoning:

 Model (Product struct):

 Represents the data structure for a product.
 Reason: Separates data representation from business logic and presentation.


 View (UITableView):

 Displays the list of products.
 Reason: Keeps presentation separate from data and logic.


 Controller (ProductListViewController):

 Manages the interaction between Model and View.
 Handles data fetching, view setup, and user interactions.
 Reason: Acts as a mediator, reducing coupling between Model and View.



 Key points about MVC:

 Simple and easy to understand, making it a good starting point.
 Clear separation of concerns, but the controller can become bloated over time.
 Direct connection between View and Controller, which can make testing challenging.

 In this example:

 The Model (Product) is a simple data structure.
 The View is primarily handled by UIKit (UITableView).
 The Controller (ProductListViewController) does most of the work, including view setup, data fetching, and display logic.

 This MVC structure is straightforward but can lead to "Massive View Controllers" as the app grows more complex. In our next steps, we'll explore how other architectures address this and other limitations of MVC.

 */

import UIKit

// Model
struct Product {
    let id: Int
    let name: String
    let price: Double
}

// Controller
class ProductListViewController: UIViewController, UITableViewDataSource {
    var products: [Product] = [] //controller has model
    let tableView = UITableView() //controller has view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchProducts()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
    }
    
    func fetchProducts() {
        // Simulating network call
        products = [
            Product(id: 1, name: "iPhone", price: 999.99),
            Product(id: 2, name: "MacBook", price: 1299.99),
            Product(id: 3, name: "AirPods", price: 159.99)
        ]
        tableView.reloadData()
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

// Usage
let productListVC = ProductListViewController()
// In a real app, you'd present this view controller
