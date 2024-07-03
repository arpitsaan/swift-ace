/*
 What is the Observer design pattern in the context of iOS development?
 The Observer pattern is a behavioral design pattern that allows objects (observers) to be notified automatically of changes in other objects (observables) without tightly coupling them. In iOS, this pattern is widely used for event handling, data binding, and maintaining consistency between different parts of an application.

 Discussion points:

 1. iOS Framework Examples:
    - NotificationCenter: A system-wide implementation of the Observer pattern.
    - Key-Value Observing (KVO): Allows objects to be notified of changes to specified properties of other objects.
    - Combine framework: Provides a declarative Swift API for processing values over time.
    - SwiftUI's @State and @ObservedObject: Uses a form of the Observer pattern for reactive UI updates.

 2. Advantages in iOS app architecture:
    - Loose Coupling: Observers and observables can interact without detailed knowledge of each other.
    - Flexibility: Easy to add or remove observers at runtime.
    - Scalability: Supports one-to-many relationships between objects.
    - Consistency: Helps maintain consistency across related objects in complex UIs.

 3. Potential drawbacks in iOS:
    - Memory Management: Can lead to retain cycles if not implemented carefully (which your implementation addresses well).
    - Performance: Overuse can lead to performance issues, especially with many observers or frequent updates.
    - Debugging Complexity: In complex systems, it can be challenging to track the flow of updates.

 4. Comparison to other reactive programming approaches in iOS:
    - More flexible but less structured than Combine's publisher-subscriber model.
    - More manual setup required compared to SwiftUI's state management system.
    - Offers more fine-grained control than high-level reactive frameworks like RxSwift.

 5. Best practices in iOS:
    - Use weak references (as you've done) to avoid retain cycles.
    - Consider using Swift's built-in solutions (like Combine) for more complex scenarios.
    - Be mindful of threading issues, especially when notifying observers on background threads.

 6. Real-world iOS application scenarios:
    - Updating UI elements when model data changes (e.g., refreshing a product list when inventory updates).
    - Coordinating between view controllers (e.g., updating a cart badge when items are added).
    - Responding to system events (e.g., keyboard appearance, device orientation changes).

 7. Evolution in Swift and iOS:
    - The introduction of Combine and SwiftUI has provided more declarative ways to implement observer-like patterns.
    - However, understanding the core Observer pattern remains valuable for working with older codebases and for scenarios where more manual control is needed.

 This implementation provides a solid foundation for using the Observer pattern in iOS apps. It's particularly useful in scenarios where you need fine-grained control over observation and don't want to introduce dependencies on larger frameworks like Combine. The use of weak references and the `WeakObserver` wrapper class demonstrates a good understanding of memory management concerns in iOS development.
 */

/*
Problem 12: Real-time Product Stock Updates using Observer Pattern

Description:
You're developing an iOS e-commerce app that needs to display real-time stock updates for products. Multiple views in your app (e.g., product detail view, shopping cart view) need to be notified when the stock status of a product changes.

Why Observer Pattern?
The Observer pattern is suitable for this scenario because:
1. We need to notify multiple objects (views) when a change occurs in another object (product stock).
2. We want to avoid tight coupling between the product and the views displaying its information.
3. We need a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.

Requirements:
1. Create a ProductStock class that maintains the current stock level of a product.
   Why: This represents the subject that other objects will observe.

2. Implement an Observable protocol that allows objects to register and unregister as observers.
   Why: This defines the interface for adding and removing observers.

3. Create an Observer protocol that defines the method to be called when a stock update occurs.
   Why: This ensures all observers implement the update method.

4. Implement concrete observer classes for different views (e.g., ProductDetailViewController, ShoppingCartViewController).
   Why: These represent the different parts of your app that need to react to stock changes.

5. Ensure that when the stock level changes, all registered observers are notified.
   Why: This demonstrates the core functionality of the Observer pattern.

6. (Bonus) Implement a way to avoid retain cycles when using the Observer pattern.
   Why: This is crucial in iOS development to prevent memory leaks.

Example usage:
let productStock = ProductStock(productId: "ABC123", initialStock: 10)

let detailVC = ProductDetailViewController(productId: "ABC123")
let cartVC = ShoppingCartViewController()

productStock.addObserver(detailVC)
productStock.addObserver(cartVC)

productStock.updateStock(newStock: 5)
// Both detailVC and cartVC should be notified and updated

Implement the Observer pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. How the Observer pattern is used in iOS frameworks (e.g., NotificationCenter, KVO, Combine)
2. Advantages of using the Observer pattern in iOS app architecture
3. Potential drawbacks or limitations of the Observer pattern in iOS
4. How the Observer pattern compares to other reactive programming approaches in iOS

What is the Observer design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

protocol Observable: AnyObject {
    func addObserver(_ observer: Observer)
    func removeObserver(_ observer: Observer)
}

protocol Observer: AnyObject {
    func stockUpdated(stock: Int)
}

class WeakObserver {
    weak var object: Observer?
    
    init(_ object: Observer) {
        self.object = object
    }
}

class ProductStock: Observable {
    
    private(set) var productId: String
    
    private(set) var stock: Int {
        didSet {
            notifyObservers()
        }
    }
    
    private var observers: [WeakObserver] = []
        
    init(productId: String, initialStock: Int) {
        self.productId = productId
        self.stock = initialStock
    }
    
    func updateStock(newStock: Int) {
        self.stock = newStock
    }
    
    func addObserver(_ observer: Observer) {
        observers.append(WeakObserver(observer))
    }
    
    func removeObserver(_ observer: Observer) {
        observers = observers.filter { $0.object !== observer }
    }
    
    //private helper methods
    private func notifyObservers() {
        observers.forEach{ weakObserver in
            weakObserver.object?.stockUpdated(stock: stock)
        }
        observers = observers.filter { $0.object != nil }
    }
}

class ProductDetailViewController: Observer {
    private var productId: String
    
    init(productId: String) {
        self.productId = productId
    }
    
    func stockUpdated(stock: Int) {
        print("ProductDetailViewController updated stock to \(stock).")
    }
}

class ShoppingCartViewController: Observer {
    func stockUpdated(stock: Int) {
        print("ShoppingCartViewController updated stock to \(stock).")
    }
}

let productStock = ProductStock(productId: "ABC123", initialStock: 10)

let detailVC = ProductDetailViewController(productId: "ABC123")
let cartVC = ShoppingCartViewController()

productStock.addObserver(detailVC)
productStock.addObserver(cartVC)

productStock.updateStock(newStock: 5)
