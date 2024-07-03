/*
 What is the Facade design pattern?
 The Facade pattern is a structural design pattern that provides a simplified interface to a complex subsystem of classes, library, or framework. It defines a higher-level interface that makes the subsystem easier to use by reducing complexity and hiding the implementation details.
 Real-world applications in e-commerce:

 Order processing systems (as demonstrated)
 Payment gateway integrations
 Inventory management systems
 Customer support ticket systems

 Advantages in this scenario:

 Simplifies the client interface for complex order processing
 Decouples the order processing logic from client code
 Makes the system easier to use and maintain

 Potential drawbacks:

 The facade might become a god object coupled to all classes of the app
 It can hide useful complexity that clients might need to be aware of

 Compared to other solutions:

 More maintainable than having client code interact directly with subsystems
 More flexible than hard-coding the interactions between subsystems
 Easier to understand and use than exposing all subsystem interfaces to the client
 */

/*
Problem 10: Simplified Order Processing System using Facade Pattern

Description:
You're working on an e-commerce platform that has a complex order processing system. The system involves multiple subsystems for inventory checking, payment processing, shipping calculation, and order confirmation. To simplify the ordering process for client code, you need to create a facade that encapsulates the complexities of these subsystems.

Why Facade Pattern?
The Facade pattern is suitable for this scenario because:
1. We have a complex subsystem with multiple components.
2. We want to provide a simple interface for client code to use the subsystem.
3. We need to decouple the client code from the subsystem's components.

Requirements:
1. Create interfaces or classes for the following subsystems:
   - InventorySystem: checks if items are in stock
   - PaymentSystem: processes payments
   - ShippingSystem: calculates shipping costs
   - NotificationSystem: sends order confirmations
   Why: These represent the complex subsystems in our e-commerce platform.

2. Implement a simple version of each subsystem.
   Why: To demonstrate how the subsystems work without exposing their complexities.

3. Create an OrderFacade class that uses these subsystems to process an order.
   Why: This is the facade that will simplify the order processing for client code.

4. The OrderFacade should have a method processOrder() that coordinates all the steps of order processing.
   Why: This method encapsulates the complexity of using multiple subsystems.

5. Implement error handling in the facade to deal with issues like out-of-stock items or payment failures.
   Why: To demonstrate how the facade can manage complex workflows and error scenarios.

Example usage:
let orderFacade = OrderFacade(
    inventory: InventorySystem(),
    payment: PaymentSystem(),
    shipping: ShippingSystem(),
    notification: NotificationSystem()
)

let order = Order(items: ["item1", "item2"], totalAmount: 100.0)
do {
    try orderFacade.processOrder(order)
    print("Order processed successfully")
} catch {
    print("Order processing failed: \(error)")
}

Implement the Facade pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Facade pattern in e-commerce systems
2. Advantages of using the Facade pattern in this scenario
3. Potential drawbacks or limitations of the Facade pattern
4. How the Facade pattern compares to other potential solutions for simplifying complex subsystems

What is the Facade design pattern?
[You'll answer this after implementing the solution]
*/


class InventorySystem {
    //...
    
    func hasItemsInStock(items: [String]) -> Bool {
        return true
    }
    
    //...
}

class PaymentSystem {
    //...
    
    func processPayment(paymentId: Int, amount: Double) -> Bool {
        return Bool.random()
    }
    
    //...
}

class ShippingSystem {
    //...
    
    func getShippingCost(item: String, address: String) -> Double {
        return 10.0
    }
    
    //...
}

class NotificationSystem {
    //...
    
    func sendOrderConfirmation(_ orderId: Int) {
        print("Order confirmed notification: id \(orderId).")
    }
    
    //...
}

protocol PaymentMethod {
    func getPaymentId() -> Int
}

struct CreditCardPayment: PaymentMethod {
    func getPaymentId() -> Int {
        return 8888888888888888
    }
}

struct Order {
    var orderId: Int
    var items: [String]
    var totalAmount: Double
    var paymentMethod: PaymentMethod
}

enum OrderProcessingError: Error {
    case outOfStock
    case paymentFailed
    
    case uncategorized
}

class OrderFacade {
    private let inventory: InventorySystem
    private let payment: PaymentSystem
    private let shipping: ShippingSystem
    private let notification: NotificationSystem
    
    init(inventory: InventorySystem, payment: PaymentSystem, shipping: ShippingSystem, notification: NotificationSystem) {
        self.inventory = inventory
        self.payment = payment
        self.shipping = shipping
        self.notification = notification
    }
    
    func processOrder(_ order: Order) throws {
        //inventory
        guard inventory.hasItemsInStock(items: order.items) else {
            throw OrderProcessingError.outOfStock
        }
        
        //shipping cost
        var shippingCost = 0.0
        order.items.forEach { item in
            shippingCost += shipping.getShippingCost(item: item, address: "Shipping Address")
        }
        
        //payment
        guard payment.processPayment(paymentId: order.paymentMethod.getPaymentId(), amount: order.totalAmount + shippingCost) else {
            throw OrderProcessingError.paymentFailed
        }
        
        //notification
        notification.sendOrderConfirmation(order.orderId)
    }
}


let orderFacade = OrderFacade(
    inventory: InventorySystem(),
    payment: PaymentSystem(),
    shipping: ShippingSystem(),
    notification: NotificationSystem()
)

let order = Order(orderId: 1234, items: ["Puma Red Tshirt", "Adidas Cap"], totalAmount: 90.0, paymentMethod: CreditCardPayment())

do {
    try orderFacade.processOrder(order)
    print("Order processed successfully")

} catch {
    switch error as? OrderProcessingError ?? .uncategorized {
        
    case .outOfStock:
        print("Order processing failed, items out of stock.")
    case .paymentFailed:
        print("Order processing failed due to payment error.")
        
    default:
        print("Order processing failed: \(error)")
    }
}
