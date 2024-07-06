/*
Problem: Product Stock Alert System using Multicast Delegate Pattern

Description:
You're developing an iOS e-commerce app that needs a flexible product stock alert system. When a product comes back in stock, multiple parts of the app need to be notified (e.g., update UI, send push notification, refresh recommendations). You want to create a system that allows multiple objects to subscribe to these stock update events without creating strong coupling between components.

Why Multicast Delegate Pattern?
The Multicast Delegate pattern is suitable here because:
1. It allows multiple objects to respond to the same event.
2. It maintains loose coupling between the event source and the listeners.
3. It provides flexibility in adding or removing listeners dynamically.

Step-by-Step Requirements:

1. Create a `StockUpdateListener` protocol with a method for handling stock updates:
   - func productDidRestockOccur(productID: String, newStockLevel: Int)
   Why: This defines the interface for objects that want to listen for stock updates.

2. Create a `MulticastDelegate` class that can manage multiple delegates:
   - Method: addDelegate(_ delegate: StockUpdateListener)
   - Method: removeDelegate(_ delegate: StockUpdateListener)
   - Method: invokeDelegates(_ invocation: (StockUpdateListener) -> Void)
   Why: This class will manage the collection of listeners and invoke them when an event occurs.

3. Create a `ProductStockManager` class that uses the `MulticastDelegate`:
   - Property: stockUpdateNotifier: MulticastDelegate<StockUpdateListener>
   - Method: updateStockLevel(for productID: String, to newLevel: Int)
   Why: This class will manage product stock levels and notify listeners of changes.

4. Implement at least three different listener classes that conform to `StockUpdateListener`:
   - `UIUpdater`: Simulates updating the UI when stock levels change.
   - `PushNotificationSender`: Simulates sending a push notification for restocked items.
   - `RecommendationEngine`: Simulates updating product recommendations based on stock changes.
   Why: These demonstrate different use cases for the stock update events.

5. Create a simple `Product` struct with an id and a stock level.
   Why: This represents the basic data model for products in the system.

Example usage:
let stockManager = ProductStockManager()
let uiUpdater = UIUpdater()
let pushNotificationSender = PushNotificationSender()
let recommendationEngine = RecommendationEngine()

stockManager.stockUpdateNotifier.addDelegate(uiUpdater)
stockManager.stockUpdateNotifier.addDelegate(pushNotificationSender)
stockManager.stockUpdateNotifier.addDelegate(recommendationEngine)

stockManager.updateStockLevel(for: "PROD-001", to: 10)

Implement the Multicast Delegate pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Multicast Delegate pattern compare to using NotificationCenter for broadcasting events?
2. In what other scenarios in an e-commerce app might the Multicast Delegate pattern be useful?
3. How might this pattern be extended to support prioritized or conditional event handling?

What is the Multicast Delegate design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here

import Foundation

// Change the protocol to a base class
class StockUpdateListener {
    func productDidRestockOccur(productID: String, newStockLevel: Int) {
        fatalError("This method must be overridden")
    }
}

class MulticastDelegate<T: AnyObject> {
    private var delegates = [Weak<T>]()
    
    func addDelegate(_ delegate: T) {
        delegates.append(Weak(value: delegate))
    }
    
    func removeDelegate(_ delegate: T) {
        delegates.removeAll { $0.value === delegate }
    }
    
    func invokeDelegates(_ invocation: (T) -> Void) {
        delegates = delegates.filter { $0.value != nil }
        delegates.forEach {
            if let delegate = $0.value {
                invocation(delegate)
            }
        }
    }
}

private class Weak<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

class ProductStockManager {
    let stockUpdateNotifier = MulticastDelegate<StockUpdateListener>()
    private var stock: [String: Int] = [:]
    
    init(productIDs: [String]) {
        productIDs.forEach { stock[$0] = 0 }
    }
    
    func updateStockLevel(for productID: String, to newLevel: Int) {
        stock[productID] = newLevel
        stockUpdateNotifier.invokeDelegates { listener in
            listener.productDidRestockOccur(productID: productID, newStockLevel: newLevel)
        }
    }
}

// Listener Classes now inherit from StockUpdateListener
class UIUpdater: StockUpdateListener {
    override func productDidRestockOccur(productID: String, newStockLevel: Int) {
        print("UI Update: Product \(productID) now has \(newStockLevel) items in stock. Updating product list view.")
    }
}

class PushNotificationSender: StockUpdateListener {
    override func productDidRestockOccur(productID: String, newStockLevel: Int) {
        if newStockLevel > 0 {
            print("Push Notification: Product \(productID) is back in stock! Notifying interested customers.")
        }
    }
}

class RecommendationEngine: StockUpdateListener {
    override func productDidRestockOccur(productID: String, newStockLevel: Int) {
        print("Recommendation Engine: Updating recommendations based on restock of product \(productID).")
    }
}

// Usage
let stockManager = ProductStockManager(productIDs: ["PROD-001", "PROD-002"])
let uiUpdater = UIUpdater()
let pushNotificationSender = PushNotificationSender()
let recommendationEngine = RecommendationEngine()

stockManager.stockUpdateNotifier.addDelegate(uiUpdater)
stockManager.stockUpdateNotifier.addDelegate(pushNotificationSender)
stockManager.stockUpdateNotifier.addDelegate(recommendationEngine)

stockManager.updateStockLevel(for: "PROD-001", to: 10)
