/*
 What is the State Pattern?
 The State pattern is a behavioral design pattern that allows an object to alter its behavior when its internal state changes. The object will appear to change its class. It provides a structured way to organize state-specific behavior and manage state transitions.
 Key components of the State pattern:
 Context: The class that contains the state and can have its behavior changed. In our example, this is the Product class.
 State: An interface or abstract class defining the methods that each concrete state must implement. In our case, this is the ProductState protocol.
 Concrete States: Classes that implement the State interface, providing specific behavior for each state. We have InStockState, LowStockState, OutOfStockState, and DiscontinuedState.
 The main idea is to represent each state as a separate class and delegate the state-specific behavior to these objects instead of using conditional statements in the context class. This allows for more flexible and maintainable code, especially when dealing with complex state-dependent behaviors.
 In the context of iOS development, the State pattern can be particularly useful for managing complex UI states, app lifecycle states, or business logic states in various types of applications, including e-commerce apps, as we've demonstrated.
 By encapsulating state-specific behavior and transitions, the State pattern helps create more modular, extensible, and easier-to-maintain code, which is crucial in the ever-evolving landscape of iOS app development.
*/
/*
 Let's discuss why the State pattern is often considered better than using if-else statements or enums, especially in more complex scenarios:

 Separation of Concerns:

 State Pattern: Each state's behavior is encapsulated in its own class. This makes it easier to understand, maintain, and modify the behavior of each state independently.
 If-else or Enums: All state-related behavior is typically contained in a single class or method, which can become large and difficult to manage as complexity increases.


 Open/Closed Principle:

 State Pattern: You can add new states by creating new classes without modifying existing code, adhering to the Open/Closed Principle.
 If-else or Enums: Adding a new state often requires modifying existing code, potentially introducing bugs in previously working code.


 Reduced Complexity in Context Class:

 State Pattern: The Product class (context) remains simple, delegating state-specific behavior to state objects.
 If-else or Enums: The context class can become bloated with complex conditional logic for different states.


 Easier State Transitions:

 State Pattern: State transitions are handled by changing the state object, which can encapsulate transition logic if needed.
 If-else or Enums: State transitions often require updating multiple variables and can be error-prone.


 Better for Complex State Machines:

 State Pattern: Scales well for systems with many states and complex transitions.
 If-else or Enums: Can become unwieldy and hard to maintain for complex state machines.


 Runtime Flexibility:

 State Pattern: Allows for dynamic state changes at runtime, which can be powerful for complex systems.
 If-else or Enums: Less flexible for runtime changes, especially if using compile-time enums.


 Improved Testability:

 State Pattern: Each state can be tested in isolation, making unit testing easier and more thorough.
 If-else or Enums: Testing all state combinations can be more challenging and less intuitive.



 Now, to address the discussion points from the original question:

 Comparison to simple enum and switch:
 The State pattern provides better encapsulation and extensibility compared to using enums and switch statements. While enums can be suitable for simpler cases, the State pattern shines in more complex scenarios where behaviors need to be easily extended or modified.
 Other scenarios in an e-commerce app:

 User account states (Guest, Registered, Premium)
 Order processing stages (New, Processing, Shipped, Delivered)
 Payment processing states (Pending, Authorized, Captured, Refunded)
 Product lifecycle (New, Featured, OnSale, Clearance)


 Extending for more complex transitions or actions:

 Add a state history to support more complex undo/redo operations
 Implement composite states for handling hierarchical state machines
 Add observers to state changes for logging or analytics
 Implement state-specific validation rules for transitions



 The State pattern truly shines in scenarios where an object's behavior changes dramatically based on its internal state, and where these states and transitions are complex or likely to evolve over time. It provides a structured way to manage this complexity while keeping the code modular and maintainable.
 
 */

/*
Problem: Product Listing System using State Pattern

Description:
You're developing an iOS e-commerce app that needs a dynamic product listing system. A product's behavior in the app (how it's displayed, whether it can be purchased, etc.) changes based on its inventory level. The product can be in various states (In Stock, Low Stock, Out of Stock, Discontinued) and transitions between these states based on inventory changes.

Why State Pattern?
The State pattern is suitable here because:
1. The product's behavior changes based on its inventory state.
2. There are distinct state-dependent behaviors and transitions.
3. State-specific behavior should be defined independently.

Step-by-Step Requirements:

1. Create a `ProductState` protocol:
   - Method: addToCart() -> String
   - Method: displayMessage() -> String
   - Method: updateInventory(count: Int)
   Why: To define a common interface for all concrete states.

2. Implement concrete state classes:
   - InStockState
   - LowStockState
   - OutOfStockState
   - DiscontinuedState
   Each should conform to ProductState and implement state-specific behavior.
   Why: To encapsulate behavior for each state of the product.

3. Create a `Product` class:
   - Property: state (of type ProductState)
   - Property: name (String)
   - Property: inventory (Int)
   - Methods: addToCart(), displayMessage() that delegate to the current state
   - Method: updateInventory(count: Int) to change inventory and potentially the state
   Why: This is the context class whose behavior changes based on its state.

4. In each concrete state class:
   - Implement state-specific behavior in the protocol methods
   - Change the product's state when inventory changes cause a state transition
   Why: To define how the product behaves in each state and how it transitions between states.

Example usage:
let product = Product(name: "Fancy Gadget", inventory: 50)
print(product.displayMessage()) // "In stock: Buy now!"
print(product.addToCart()) // "Product added to cart."

product.updateInventory(count: 5)
print(product.displayMessage()) // "Low stock: Only 5 left!"

product.updateInventory(count: 0)
print(product.displayMessage()) // "Out of stock: Coming soon!"
print(product.addToCart()) // "Cannot add to cart: Out of stock."

product.updateInventory(count: -1) // Use negative value to indicate discontinuation
print(product.displayMessage()) // "Discontinued: No longer available."

Implement the State pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the State pattern compare to using a simple enum and switch statement for managing product states?
2. In what other scenarios in an e-commerce app might the State pattern be useful?
3. How might this pattern be extended to handle more complex state transitions or additional actions?

What is the State design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here

protocol ProductState {
    func addToCart() -> String
    func displayMessage() -> String
    func isSameStateAs(_ state: ProductState) -> Bool
}

class InStockState: ProductState {
    func addToCart() -> String {
        return "Product added to cart."
    }
    
    func displayMessage() -> String {
        return "In stock: Buy now!"
    }
    
    func isSameStateAs(_ state: ProductState) -> Bool {
        return state is InStockState
    }
}

class LowStockState: ProductState {
    func addToCart() -> String {
        return "Product added to cart. Hurry, almost gone!"
    }
    
    func displayMessage() -> String {
        return "Low stock: Only a few left!"
    }
    
    func isSameStateAs(_ state: ProductState) -> Bool {
        return state is LowStockState
    }
}

class OutOfStockState: ProductState {
    func addToCart() -> String {
        return "Cannot add to cart: Out of stock."
    }
    
    func displayMessage() -> String {
        return "Out of stock: Coming soon!"
    }
    
    func isSameStateAs(_ state: ProductState) -> Bool {
        return state is OutOfStockState
    }
}

class DiscontinuedState: ProductState {
    func addToCart() -> String {
        return "Cannot add to cart: Product discontinued."
    }
    
    func displayMessage() -> String {
        return "Discontinued: No longer available."
    }
    
    func isSameStateAs(_ state: ProductState) -> Bool {
        return state is DiscontinuedState
    }
}


class Product {
    
    private(set) var state: ProductState
    let name: String
    private(set) var inventory: Int
    
    init(name: String, inventory: Int) {
        self.name = name
        self.inventory = inventory
        self.state = Product.getStateFor(inventory)
    }
    
    func addToCart() -> String {
        return state.addToCart()
    }
    
    func displayMessage() -> String {
        return state.displayMessage()
    }
    
    func updateInventory(count: Int) {
        self.inventory = count
        self.state = Product.getStateFor(inventory)
    }
    
    private static func getStateFor(_ inventoryCount: Int) -> ProductState {
        let newState: ProductState
        
        switch inventoryCount {
        case ..<0:
            newState = DiscontinuedState()
        case 0:
            newState = OutOfStockState()
        case 1...5:
            newState = LowStockState()
        default:
            newState = InStockState()
        }
        
        return newState
    }
}


//Example usage:
let product = Product(name: "Fancy Gadget", inventory: 50)
print(product.displayMessage()) // "In stock: Buy now!"
print(product.addToCart()) // "Product added to cart."

product.updateInventory(count: 5)
print(product.displayMessage()) // "Low stock: Only 5 left!"

product.updateInventory(count: 0)
print(product.displayMessage()) // "Out of stock: Coming soon!"
print(product.addToCart()) // "Cannot add to cart: Out of stock."

product.updateInventory(count: -1) // Use negative value to indicate discontinuation
print(product.displayMessage()) // "Discontinued: No longer available."

