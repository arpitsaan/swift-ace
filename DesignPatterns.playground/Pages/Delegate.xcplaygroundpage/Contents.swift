/*
 This implementation demonstrates the Delegate pattern for our shopping cart checkout process. Here's a breakdown of the key components:

 Data Models: Item, ShippingMethod, and PaymentDetails structs to represent the data used in the checkout process.
 CheckoutDelegate Protocol: Defines the methods that the delegate must implement to customize the checkout process.
 CheckoutManager Class: Manages the checkout process and uses the delegate to customize each step.
 CheckoutViewController Class: Implements the CheckoutDelegate protocol, showing how a view controller would use the CheckoutManager and respond to each step of the checkout process.

 The Delegate pattern allows us to create a flexible checkout process that can be easily customized without modifying the core CheckoutManager class. The CheckoutViewController can make decisions at each step of the process, which could involve updating the UI, validating user input, or applying business logic.
 To answer the discussion questions:

 Compared to using closures, the Delegate pattern provides a more structured approach, especially when there are multiple callback methods. It also makes it easier to reason about the flow of control and can be more readable in complex scenarios.
 Other scenarios in an e-commerce app where the Delegate pattern might be useful include:

 Product customization (e.g., configuring a computer with different components)
 User registration process
 Search filters and sorting options


 To extend this pattern for a more complex checkout process with optional steps:

 Add optional methods to the delegate protocol (using @objc optional if using Objective-C compatible code)
 In the CheckoutManager, check if the delegate implements optional methods before calling them



 The Delegate design pattern in iOS development is a fundamental pattern used to allow one object to communicate back to its owner in a decoupled way. It's widely used in Apple's frameworks and is particularly useful for:

 Customizing the behavior of reusable components
 Handling asynchronous operations and callbacks
 Separating concerns in MVC architecture (e.g., table view data sources and delegates)

 The pattern promotes loose coupling, making components more reusable and easier to test. It's a powerful tool for creating flexible, modular iOS applications.
 */

/*
Problem: Shopping Cart Checkout Process using Delegate Pattern

Description:
You're developing an iOS e-commerce app that needs a flexible and reusable shopping cart checkout process. The checkout process involves several steps (e.g., reviewing items, selecting shipping method, entering payment details), and you want to create a reusable component that can be customized for different types of checkouts without modifying the core checkout logic.

Why Delegate Pattern?
The Delegate pattern is suitable here because:
1. It allows the checkout process to be customizable without subclassing.
2. It enables loose coupling between the checkout process and the specific implementation details.
3. It provides a way for the checkout process to communicate back to its container (e.g., a view controller) without creating strong dependencies.

Step-by-Step Requirements:

1. Create a `CheckoutDelegate` protocol with methods for each step of the checkout process:
   - func checkoutDidReviewItems(items: [Item]) -> Bool
   - func checkoutDidSelectShippingMethod(method: ShippingMethod) -> Bool
   - func checkoutDidEnterPaymentDetails(details: PaymentDetails) -> Bool
   - func checkoutDidComplete(with orderNumber: String)
   - func checkoutDidCancel()
   Why: This defines the interface for customizing the checkout process.

2. Create a `CheckoutManager` class that manages the checkout process:
   - Property: delegate: CheckoutDelegate?
   - Method: startCheckout()
   - Private methods for each checkout step
   Why: This encapsulates the core checkout logic and uses the delegate for customization.

3. Create simple structs or classes for `Item`, `ShippingMethod`, and `PaymentDetails`.
   Why: These represent the data models used in the checkout process.

4. In the `CheckoutManager`, implement the checkout process using the delegate methods.
   Why: This allows for customization of each step through the delegate.

5. Create a `CheckoutViewController` that conforms to `CheckoutDelegate`:
   - Property: checkoutManager: CheckoutManager
   - Implement all required delegate methods
   Why: This demonstrates how to use the CheckoutManager and implement the delegate methods.

Example usage:
class CheckoutViewController: UIViewController, CheckoutDelegate {
    let checkoutManager = CheckoutManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkoutManager.delegate = self
        checkoutManager.startCheckout()
    }
    
    // Implement delegate methods...
}

let checkoutVC = CheckoutViewController()
// Present checkoutVC...

Implement the Delegate pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Delegate pattern compare to using closures for handling each step of the checkout process?
2. In what other scenarios in an e-commerce app might the Delegate pattern be useful?
3. How might this pattern be extended to support a more complex checkout process with optional steps?

What is the Delegate design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here

import Foundation

// MARK: - Data Models
struct Item {
    let name: String
    let price: Double
}

struct ShippingMethod {
    let name: String
    let price: Double
}

struct PaymentDetails {
    let cardNumber: String
    let expiryDate: String
    let cvv: String
}

// MARK: - Delegate Protocol
protocol CheckoutDelegate: AnyObject {
    func checkoutDidReviewItems(items: [Item]) -> Bool
    func checkoutDidSelectShippingMethod(method: ShippingMethod) -> Bool
    func checkoutDidEnterPaymentDetails(details: PaymentDetails) -> Bool
    func checkoutDidComplete(with orderNumber: String)
    func checkoutDidCancel()
}

// MARK: - Checkout Manager
class CheckoutManager {
    weak var delegate: CheckoutDelegate?
    private var items: [Item] = []
    private var selectedShippingMethod: ShippingMethod?
    private var paymentDetails: PaymentDetails?
    
    func startCheckout() {
        // Simulate fetching items from cart
        items = [Item(name: "Laptop", price: 1000), Item(name: "Mouse", price: 50)]
        
        if processReviewItems() {
            processSelectShippingMethod()
        }
    }
    
    private func processReviewItems() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.checkoutDidReviewItems(items: items)
    }
    
    private func processSelectShippingMethod() {
        // Simulate fetching shipping methods
        let shippingMethods = [
            ShippingMethod(name: "Standard", price: 5),
            ShippingMethod(name: "Express", price: 15)
        ]
        
        for method in shippingMethods {
            if delegate?.checkoutDidSelectShippingMethod(method: method) == true {
                selectedShippingMethod = method
                processEnterPaymentDetails()
                return
            }
        }
        
        delegate?.checkoutDidCancel()
    }
    
    private func processEnterPaymentDetails() {
        // Simulate entering payment details
        let details = PaymentDetails(cardNumber: "1234-5678-9012-3456", expiryDate: "12/24", cvv: "123")
        
        if delegate?.checkoutDidEnterPaymentDetails(details: details) == true {
            paymentDetails = details
            completeCheckout()
        } else {
            delegate?.checkoutDidCancel()
        }
    }
    
    private func completeCheckout() {
        // Simulate order completion
        let orderNumber = "ORD" + String(Int.random(in: 10000...99999))
        delegate?.checkoutDidComplete(with: orderNumber)
    }
}

// MARK: - Checkout View Controller (Delegate Implementation)
class CheckoutViewController: CheckoutDelegate {
    let checkoutManager: CheckoutManager
    
    init() {
        checkoutManager = CheckoutManager()
        checkoutManager.delegate = self
    }
    
    func startCheckout() {
        checkoutManager.startCheckout()
    }
    
    // MARK: - CheckoutDelegate Methods
    func checkoutDidReviewItems(items: [Item]) -> Bool {
        // In a real app, you might show these items in a UI and let the user confirm
        print("Reviewing items:")
        items.forEach { print("\($0.name): $\($0.price)") }
        return true
    }
    
    func checkoutDidSelectShippingMethod(method: ShippingMethod) -> Bool {
        // In a real app, you might show a picker and let the user select
        print("Selected shipping method: \(method.name) ($\(method.price))")
        return true
    }
    
    func checkoutDidEnterPaymentDetails(details: PaymentDetails) -> Bool {
        // In a real app, you might show a form for the user to enter these details
        print("Entered payment details: Card ending in \(details.cardNumber.suffix(4))")
        return true
    }
    
    func checkoutDidComplete(with orderNumber: String) {
        print("Checkout completed! Order number: \(orderNumber)")
    }
    
    func checkoutDidCancel() {
        print("Checkout was cancelled")
    }
}

// MARK: - Usage
let checkoutVC = CheckoutViewController()
checkoutVC.startCheckout()
