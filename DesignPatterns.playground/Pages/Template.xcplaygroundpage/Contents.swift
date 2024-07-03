/*
 What is the Template Method design pattern in the context of iOS development using Swift's protocol-oriented approach?
 The Template Method pattern, when implemented using Swift's protocol-oriented approach, defines a protocol that outlines the skeleton of an algorithm in a method, deferring some steps to conforming types. It uses protocol extensions to provide default implementations for common steps and the overall algorithm structure, while allowing specific steps to be customized by types that conform to the protocol. This approach leverages Swift's powerful protocol and extension features to achieve code reuse and customization without the need for traditional inheritance hierarchies.
 In iOS development, this pattern is particularly useful for standardizing processes like view controller lifecycle management, network request handling, or, as in this example, order processing workflows. It allows developers to ensure consistency across similar operations while providing the flexibility to handle specific requirements for different use cases.
 */
/*
Problem 14: Order Processing Workflow using Template Method Pattern with Protocols

Description:
You're developing an iOS e-commerce app that needs to handle different types of order processing workflows (e.g., physical product orders, digital product orders, subscription orders). While the general steps of order processing are similar, some steps differ based on the type of order.

Why Template Method Pattern with Protocols?
This approach is suitable for this scenario because:
1. We have a series of steps that are common to all order types, but some steps may vary.
2. We want to define the skeleton of the order processing algorithm in one place.
3. We need to allow different implementations to redefine certain steps without changing the algorithm's structure.
4. Swift's protocol-oriented programming allows us to achieve this without abstract classes.

Requirements:
1. Create an OrderProcessor protocol that defines the template method processOrder() and other required methods.
   Why: This provides the skeleton of the order processing algorithm.

2. Define default implementations for common steps in a protocol extension.
   Why: This allows shared behavior across all conforming types.

3. Declare methods in the protocol for steps that may vary between order types.
   Why: This allows conforming types to provide specific implementations for these steps.

4. Implement concrete structs or classes for different order types (e.g., PhysicalProductOrder, DigitalProductOrder).
   Why: These represent specific order processing workflows.

5. Include a hook method that conforming types can optionally override.
   Why: This demonstrates how template methods can provide additional customization points.

6. Implement a method to simulate order processing and print out the steps.
   Why: This helps visualize the order processing workflow.

Example usage:
let physicalOrder = PhysicalProductOrder(orderId: "P12345")
physicalOrder.processOrder()

let digitalOrder = DigitalProductOrder(orderId: "D67890")
digitalOrder.processOrder()

Implement the Template Method pattern using protocols and related types that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. How this protocol-based approach achieves the goals of the Template Method pattern
2. Advantages of using protocols instead of abstract classes in Swift
3. Potential drawbacks or limitations of this approach in iOS development
4. How this pattern compares to other patterns like Strategy in terms of flexibility and use cases

What is the Template Method design pattern in the context of iOS development using Swift's protocol-oriented approach?
[You'll answer this after implementing the solution]
*/

protocol OrderProcessor {
    var orderId: String { get }
    
    func processOrder()
    func validateOrder() -> Bool
    func calculateTotalCost() -> Double
    func performPayment() -> Bool
    func finalizeOrder()
    
    // Hook method
    func sendNotification()
}

extension OrderProcessor {
    func processOrder() {
        print("Processing order: \(orderId)")
        
        guard validateOrder() else {
            print("Order validation failed")
            return
        }
        
        let totalCost = calculateTotalCost()
        print("Total cost: $\(totalCost)")
        
        guard performPayment() else {
            print("Payment failed")
            return
        }
        
        finalizeOrder()
        sendNotification()
        
        print("Order \(orderId) processed successfully")
    }
    
    // Default implementation for the hook method
    func sendNotification() {
        print("Sending generic order confirmation")
    }
}

struct PhysicalProductOrder: OrderProcessor {
    let orderId: String
    
    func validateOrder() -> Bool {
        print("Validating physical product order")
        return true
    }
    
    func calculateTotalCost() -> Double {
        print("Calculating cost including shipping")
        return 100.0 // Simplified for demonstration
    }
    
    func performPayment() -> Bool {
        print("Processing payment for physical product")
        return true
    }
    
    func finalizeOrder() {
        print("Preparing physical product for shipment")
    }
    
    // Override hook method
    func sendNotification() {
        print("Sending shipping confirmation with tracking number")
    }
}

struct DigitalProductOrder: OrderProcessor {
    let orderId: String
    
    func validateOrder() -> Bool {
        print("Validating digital product order")
        return true
    }
    
    func calculateTotalCost() -> Double {
        print("Calculating cost for digital product")
        return 50.0 // Simplified for demonstration
    }
    
    func performPayment() -> Bool {
        print("Processing payment for digital product")
        return true
    }
    
    func finalizeOrder() {
        print("Preparing download link for digital product")
    }
}

// Usage
let physicalOrder = PhysicalProductOrder(orderId: "P12345")
physicalOrder.processOrder()

print("\n---\n")

let digitalOrder = DigitalProductOrder(orderId: "D67890")
digitalOrder.processOrder()
