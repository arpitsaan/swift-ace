/*
 What is the Memento design pattern in the context of iOS development?
 The Memento pattern is a behavioral design pattern that allows capturing and restoring an object's internal state without violating encapsulation. In the context of iOS development:

 Purpose: It's used to implement state-saving mechanisms, such as undo functionality or creating snapshots of an object's state.
 Structure:

 Originator (ShoppingCart): The object whose state needs to be saved and restored.
 Memento (CartMemento): An object that stores the state of the Originator.
 Caretaker (CartCaretaker): Manages and stores Mementos without modifying them.


 Benefits:

 Preserves encapsulation by not exposing the Originator's internal structure.
 Simplifies the Originator by offloading the state-saving responsibility to the Memento.
 Provides an easy way to implement undo/redo functionality.


 iOS/Swift Application:

 Useful in iOS apps for features like undo/redo in text editors, state management in games, or reverting changes in settings.
 Can be implemented efficiently in Swift using value types (structs) for Mementos.


 Considerations:

 Memory usage can be a concern if storing many Mementos.
 Care must be taken to ensure that Mementos don't hold references that could create retain cycles.
 */

/*
Problem: Shopping Cart State Management using Memento Pattern

Description:
You're developing an iOS e-commerce app that needs a robust shopping cart system. Users should be able to add or remove items from their cart, and the app should provide an "undo" functionality to revert the cart to its previous states.

Why Memento Pattern?
The Memento pattern is suitable here because:
1. We need to capture and restore the internal state of the shopping cart object.
2. We want to provide undo functionality without exposing the cart's internal structure.
3. We need to store the cart's state history externally from the cart object itself.

Step-by-Step Requirements:

1. Create a `CartItem` struct:
   - Properties: name (String), price (Double)
   - Initializer that sets both properties
   Why: To represent individual items in the shopping cart.

2. Implement a `ShoppingCart` class (Originator):
   - Property: items (array of CartItem)
   - Method: addItem(_ item: CartItem) -> Void
   - Method: removeItem(at index: Int) -> Void
   - Method: totalPrice() -> Double
   - Method: createMemento() -> CartMemento
   - Method: restoreFromMemento(_ memento: CartMemento) -> Void
   Why: This is the main object whose state we're managing.

3. Define a `CartMemento` struct:
   - Property: items (array of CartItem)
   - Initializer that takes an array of CartItem
   Why: To store the state of the shopping cart at a given time.

4. Create a `CartCaretaker` class:
   - Property: mementos (array of CartMemento)
   - Method: save(_ memento: CartMemento) -> Void
   - Method: undo() -> CartMemento?
   Why: To manage the history of cart states and handle undo operations.

5. In the `ShoppingCart` class, implement createMemento():
   - Return a new CartMemento initialized with the current items
   Why: To allow the cart to save its current state.

6. In the `ShoppingCart` class, implement restoreFromMemento(_ memento: CartMemento):
   - Replace the current items with the items from the memento
   Why: To allow the cart to restore to a previous state.

7. In the `CartCaretaker` class, implement save(_ memento: CartMemento):
   - Add the given memento to the mementos array
   Why: To store a new cart state in the history.

8. In the `CartCaretaker` class, implement undo():
   - Remove and return the last memento from the mementos array, if any
   - Return nil if there are no mementos
   Why: To retrieve the previous cart state for undoing.

Example usage:
let cart = ShoppingCart()
let caretaker = CartCaretaker()

cart.addItem(CartItem(name: "Laptop", price: 1000))
caretaker.save(cart.createMemento())

cart.addItem(CartItem(name: "Mouse", price: 25))
caretaker.save(cart.createMemento())

cart.addItem(CartItem(name: "Keyboard", price: 50))
print(cart.totalPrice()) // Should print 1075

if let previousMemento = caretaker.undo() {
    cart.restoreFromMemento(previousMemento)
    print(cart.totalPrice()) // Should print 1025
}

if let originalMemento = caretaker.undo() {
    cart.restoreFromMemento(originalMemento)
    print(cart.totalPrice()) // Should print 1000
}

Implement the Memento pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Memento pattern compare to simply keeping an array of previous cart states?
2. In what other scenarios in an e-commerce app might the Memento pattern be useful?
3. How might this pattern be extended to support "redo" functionality in addition to "undo"?

What is the Memento design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here

struct CartItem {
    var name: String
    var price: Double
}

class ShoppingCart {
    private var items: [CartItem] = []
    
    func addItem(_ item: CartItem) {
        items.append(item)
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func getTotalPrice() -> Double {
        return items.reduce(0) { partialResult, item in
            item.price + partialResult
        }
    }
    
    func createMemento() -> CartMemento {
        return CartMemento(items: items)
    }
    
    func restoreFromMemento(_ memento: CartMemento) {
        items = memento.items
    }
    
}

struct CartMemento {
    private(set) var items: [CartItem]
    
    init(items: [CartItem]) {
        self.items = items
    }
}

class CartCaretaker {
    private var mementos: [CartMemento] = []
    
    func save(_ memento: CartMemento) {
        mementos.append(memento)
    }
    
    func undo() -> CartMemento? {
        return mementos.popLast()
    }
}


//Example usage:
let cart = ShoppingCart()
let caretaker = CartCaretaker()

cart.addItem(CartItem(name: "Laptop", price: 1000))
caretaker.save(cart.createMemento())

cart.addItem(CartItem(name: "Mouse", price: 25))
caretaker.save(cart.createMemento())

cart.addItem(CartItem(name: "Keyboard", price: 50))
print(cart.getTotalPrice()) // Should print 1075

if let previousMemento = caretaker.undo() {
    cart.restoreFromMemento(previousMemento)
    print(cart.getTotalPrice()) // Should print 1025
}

if let originalMemento = caretaker.undo() {
    cart.restoreFromMemento(originalMemento)
    print(cart.getTotalPrice()) // Should print 1000
}
