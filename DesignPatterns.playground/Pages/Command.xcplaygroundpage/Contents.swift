/*
 Certainly! Here's a concise answer to "What's the Command design pattern?" that you can use in an interview:

 The Command design pattern is a behavioral pattern that encapsulates a request as an object, allowing you to decouple the sender of a request from the object that performs the request. In the context of iOS development:

 1. Purpose: It turns a request into a stand-alone object containing all information about the request. This transformation allows you to parameterize methods with different requests, delay or queue a request's execution, and support undoable operations.

 2. Structure:
    - Command: An interface for executing an operation.
    - Concrete Command: Implements the Command interface and defines the binding between a Receiver object and an action.
    - Invoker: Asks the command to carry out the request.
    - Receiver: Knows how to perform the operations associated with carrying out a request.
    - Client: Creates a Concrete Command object and sets its receiver.

 3. Benefits:
    - Decoupling: It separates the object that invokes the operation from the one that knows how to perform it.
    - Extensibility: New commands can be added without changing existing code.
    - Composite Commands: Simple commands can be assembled into larger ones.
    - Undo/Redo: The pattern can be extended to implement undo and redo functionality.

 4. iOS/Swift Application:
    - In iOS, it's particularly useful for implementing undo functionality, handling UI actions, managing network operations, or any scenario where you need to queue or log operations.
    - It aligns well with Swift's protocol-oriented programming, where the Command can be defined as a protocol.

 5. Example Use Case:
    - In an e-commerce app, you might use it to manage order operations (place, cancel, modify), where each operation is encapsulated as a command object. This allows for easy implementation of features like order history and undo functionality.

 By using the Command pattern, you create a more flexible and maintainable codebase, especially when dealing with complex sets of actions or operations in your iOS application.8
 */
 /*
Problem: Order Management System using Command Pattern

Description:
You're developing an iOS e-commerce app that needs a flexible order management system. The system should be able to handle various order-related operations (e.g., place order, cancel order, modify order) and support undo functionality. The operations may vary or be added/removed based on business requirements or app updates.

Why Command Pattern?
The Command pattern is suitable here because:
1. We need to encapsulate different order operations as objects.
2. We want to support undo functionality for order operations.
3. We want to decouple the objects that invoke operations from the objects that perform these operations.
4. We may need to queue or log order operations in the future.

Requirements:
1. Create an `OrderCommand` protocol that defines the interface for executing and undoing order operations.
   Why: This provides a common interface for all order commands.

2. Implement concrete command classes for different types of order operations (e.g., `PlaceOrderCommand`, `CancelOrderCommand`, `ModifyOrderCommand`).
   Why: These represent the different actions that can be performed on orders.

3. Create a `OrderService` class that actually performs the order operations.
   Why: This acts as the receiver in the Command pattern, containing the business logic for order operations.

4. Implement an `OrderManager` class that invokes commands and maintains a history of executed commands.
   Why: This serves as the invoker in the Command pattern and manages the execution and undoing of commands.

5. Each command should have a reference to the `OrderService` and any necessary parameters for the operation.
   Why: This allows the command to execute the operation when invoked.

6. Implement methods in the `OrderManager` to execute commands and undo the last executed command.
   Why: This provides the main functionality of the Command pattern.

Example usage:
let orderService = OrderService()
let orderManager = OrderManager()

let placeOrderCommand = PlaceOrderCommand(orderId: "12345", orderService: orderService)
orderManager.executeCommand(placeOrderCommand)

let cancelOrderCommand = CancelOrderCommand(orderId: "12345", orderService: orderService)
orderManager.executeCommand(cancelOrderCommand)

orderManager.undoLastCommand()

Implement the Command pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Command pattern compare to directly calling methods on the OrderService?
2. In what scenarios might you use the Command pattern in conjunction with other patterns we've covered?
3. How might this pattern be extended to support more complex order management scenarios in an e-commerce app?

What is the Command design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here



protocol OrderCommand {
    func execute() -> Bool
    func undo()
}

class OrderService {
    func placeOrder(id: String) {
        //API call to place order
        print("Order placed for order id \(id)")
    }
    
    func undoPlaceOrder(id: String) {
        //API call to undo placed order
        print("Undo place order for order id \(id)")
    }
    
    func cancelOrder(id: String) {
        //API call to cancel order
        print("Cancel order for order id \(id)")
    }
    
    func undoCancelOrder(id: String) {
        //API call to undo cancel order
        print("Undo cancel order for order id \(id)")
    }
    
    func modifyOrder(id: String) {
        //API call to modify order
        print("Modify order for order id \(id)")
    }
    
    func undoModifyOrder(id: String) {
        //API call to undo modify order
        print("Undo modify order for order id \(id)")
    }
}

class PlaceOrderCommand: OrderCommand {
    
    private var orderId: String
    private var orderService: OrderService
    
    init(orderId: String, orderService: OrderService) {
        self.orderId = orderId
        self.orderService = orderService
    }
    
    func execute() -> Bool {
        orderService.placeOrder(id: orderId)
        return true
    }
    func undo() {
        orderService.undoPlaceOrder(id: orderId)
    }
}

class CancelOrderCommand: OrderCommand {
    
    private var orderId: String
    private var orderService: OrderService
    
    init(orderId: String, orderService: OrderService) {
        self.orderId = orderId
        self.orderService = orderService
    }
    
    func execute() -> Bool {
        orderService.cancelOrder(id: orderId)
        return true
    }
    func undo() {
        orderService.undoCancelOrder(id: orderId)
    }
}

class ModifyOrderCommand: OrderCommand {
    
    private var orderId: String
    private var orderService: OrderService
    
    init(orderId: String, orderService: OrderService) {
        self.orderId = orderId
        self.orderService = orderService
    }
    
    func execute() -> Bool {
        orderService.modifyOrder(id: orderId)
        return true
    }
    func undo() {
        orderService.undoModifyOrder(id: orderId)
    }
}

class OrderManager {
    
    private var commands: [OrderCommand] = []
    
    func executeCommand(_ orderCommand: OrderCommand) {
        orderCommand.execute()
        commands.append(orderCommand)
    }
    
    func undoLastCommand() {
        let lastCommand = commands.popLast()
        lastCommand?.undo()
    }
}

    

//Example usage:
let orderService = OrderService()
let orderManager = OrderManager()

let placeOrderCommand = PlaceOrderCommand(orderId: "12345", orderService: orderService)
orderManager.executeCommand(placeOrderCommand)

let cancelOrderCommand = CancelOrderCommand(orderId: "12345", orderService: orderService)
orderManager.executeCommand(cancelOrderCommand)

orderManager.undoLastCommand()

/*
 To answer the discussion questions:

 Compared to directly calling methods on OrderService, the Command pattern provides better encapsulation, supports undo functionality, and allows for easy expansion of operations.
 This pattern could be combined with Observer (to notify of order changes), Factory (to create commands), or Chain of Responsibility (to process orders through multiple steps).
 To extend for more complex scenarios, you could implement command queueing, add logging, or create composite commands for multi-step operations.

 */
