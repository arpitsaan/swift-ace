/*
 This implementation demonstrates the key aspects of the Coordinator pattern:

 A Coordinator protocol defines the basic structure for all coordinators.
 An AppCoordinator serves as the root coordinator, managing the main flow of the app.
 Child coordinators (ProductBrowsingCoordinator, ShoppingCartCoordinator, CheckoutCoordinator) manage specific sections of the app.
 Each coordinator has its own navigation controller and manages its own flow.
 View controllers are kept simple, with navigation logic handled by coordinators.
 Coordinators can start child coordinators, allowing for complex navigation hierarchies.

 This pattern allows for a clear separation of concerns, with navigation logic centralized in coordinators and view controllers focused on their specific functionality. It makes it easier to modify the app's flow and reuse view controllers in different contexts.
 */

/*
Problem: Navigation Flow Management using Coordinator Pattern

Description:
You're developing an iOS e-commerce app that has a complex navigation flow. The app includes features such as product browsing, product details, shopping cart, checkout process, and user account management. You want to implement a system that decouples the navigation logic from view controllers, making it easier to modify the app's flow and reuse view controllers in different contexts.

Why Coordinator Pattern?
The Coordinator pattern is suitable here because:
1. It centralizes navigation logic, removing it from view controllers.
2. It allows for easier modification of the app's flow without changing view controllers.
3. It facilitates the reuse of view controllers in different navigation contexts.
4. It helps manage dependencies and pass data between view controllers.

Step-by-Step Requirements:

1. Create a `Coordinator` protocol with the following requirements:
   - Property: childCoordinators: [Coordinator]
   - Method: start()
   Why: This defines the basic structure for all coordinators.

2. Implement an `AppCoordinator` class that conforms to `Coordinator`:
   - Should manage the main flow of the app
   - Should create and manage child coordinators for major sections of the app
   Why: This serves as the root coordinator for the entire app.

3. Implement the following child coordinators:
   - `ProductBrowsingCoordinator`
   - `ShoppingCartCoordinator`
   - `CheckoutCoordinator`
   - `AccountCoordinator`
   Why: These manage specific sections of the app.

4. Create basic view controllers for each section:
   - `ProductListViewController`
   - `ProductDetailViewController`
   - `ShoppingCartViewController`
   - `CheckoutViewController`
   - `AccountViewController`
   Why: These represent the main screens of the app.

5. Implement navigation methods in each coordinator to manage transitions between view controllers.
   Why: This centralizes navigation logic in the coordinators.

6. Use a `UINavigationController` in each coordinator to manage the view controller hierarchy.
   Why: This provides a standard iOS navigation structure.

7. Implement a method to pass data between coordinators when necessary.
   Why: This allows for communication between different sections of the app.

Example usage:
let window = UIWindow(frame: UIScreen.main.bounds)
let appCoordinator = AppCoordinator(window: window)
appCoordinator.start()

// Later, in AppCoordinator
func showProductBrowsing() {
    let productBrowsingCoordinator = ProductBrowsingCoordinator(navigationController: navigationController)
    childCoordinators.append(productBrowsingCoordinator)
    productBrowsingCoordinator.start()
}

Implement the Coordinator pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Coordinator pattern compare to using Storyboards for managing app flow?
2. In what other scenarios in an e-commerce app might the Coordinator pattern be useful?
3. How might this pattern be extended to handle deep linking or complex user flows?

What is the Coordinator design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here.


import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showProductBrowsing()
    }
    
    func showProductBrowsing() {
        let productCoordinator = ProductBrowsingCoordinator(navigationController: navigationController)
        childCoordinators.append(productCoordinator)
        productCoordinator.start()
    }
}

class ProductBrowsingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let productListVC = ProductListViewController()
        productListVC.coordinator = self
        navigationController.pushViewController(productListVC, animated: false)
    }
    
    func showProductDetail(for productId: String) {
        let productDetailVC = ProductDetailViewController(productId: productId)
        productDetailVC.coordinator = self
        navigationController.pushViewController(productDetailVC, animated: true)
    }
    
    func showShoppingCart() {
        let cartCoordinator = ShoppingCartCoordinator(navigationController: navigationController)
        childCoordinators.append(cartCoordinator)
        cartCoordinator.start()
    }
}

class ShoppingCartCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let cartVC = ShoppingCartViewController()
        cartVC.coordinator = self
        navigationController.pushViewController(cartVC, animated: true)
    }
    
    func startCheckout() {
        let checkoutCoordinator = CheckoutCoordinator(navigationController: navigationController)
        childCoordinators.append(checkoutCoordinator)
        checkoutCoordinator.start()
    }
}

class CheckoutCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let checkoutVC = CheckoutViewController()
        checkoutVC.coordinator = self
        navigationController.pushViewController(checkoutVC, animated: true)
    }
}

// Basic View Controller implementations
class ProductListViewController: UIViewController {
    weak var coordinator: ProductBrowsingCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
    }
}

class ProductDetailViewController: UIViewController {
    weak var coordinator: ProductBrowsingCoordinator?
    let productId: String
    
    init(productId: String) {
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Detail"
    }
}

class ShoppingCartViewController: UIViewController {
    weak var coordinator: ShoppingCartCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shopping Cart"
    }
}

class CheckoutViewController: UIViewController {
    weak var coordinator: CheckoutCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
    }
}

// Usage
let navigationController = UINavigationController()
let appCoordinator = AppCoordinator(navigationController: navigationController)
appCoordinator.start()
