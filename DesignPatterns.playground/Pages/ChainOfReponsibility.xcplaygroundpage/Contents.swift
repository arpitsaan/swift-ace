/*
 Discussion of the Chain of Responsibility Pattern:

 How does the Chain of Responsibility pattern compare to simple if-else chains for validation?

 More flexible: Validators can be easily added, removed, or reordered without changing existing code.
 More modular: Each validator is self-contained, promoting better separation of concerns.
 Easier to maintain and extend: New validators can be added without modifying existing ones.
 Potentially more performant: Can short-circuit the chain if a validation fails early.


 Scenarios to use Chain of Responsibility with other patterns:

 With Factory Method: To create different validator chains based on order types.
 With Observer: To notify different parts of the system about validation results.
 With Command: To encapsulate each validation step as a command object.


 Extending the pattern for complex validation scenarios:

 Implement branching logic in validators to create more complex chains.
 Add priority levels to validators to dynamically reorder the chain.
 Implement a fallback mechanism for partial validations.
*/

/*
Problem: Order Validation Chain using Chain of Responsibility Pattern

Description:
You're developing an iOS e-commerce app that needs to validate orders before processing them. Different types of validations need to be performed (e.g., inventory check, fraud detection, payment validation), and these validations may change or be added/removed based on the order type or app updates.

Why Chain of Responsibility Pattern?
The Chain of Responsibility pattern is suitable here because:
1. We have a series of checks that need to be performed sequentially.
2. The exact sequence of checks may vary or change over time.
3. We want to decouple the client (order processing system) from the concrete validator classes.

Requirements:
1. Create an `OrderValidator` protocol that defines the interface for handling order validation.
   Why: This provides a common interface for all validators in the chain.

2. Implement concrete validator classes for different types of validations (e.g., `InventoryValidator`, `FraudValidator`, `PaymentValidator`).
   Why: These represent the different steps in the validation process.

3. Each validator should have a reference to the next validator in the chain.
   Why: This allows the request to be passed along the chain.

4. Implement a method in each validator to process the order and pass it to the next validator if necessary.
   Why: This is the core of the Chain of Responsibility pattern.

5. Create an `Order` struct to represent the order being validated.
   Why: This is the object that will be passed through the validation chain.

6. Implement a `ValidationManager` class that sets up and initiates the validation chain.
   Why: This provides a clean interface for the client to use the validation system.

Example usage:
let order = Order(id: "12345", items: ["item1", "item2"], total: 100.0)
let validationManager = ValidationManager()
let result = validationManager.validateOrder(order)
print(result ? "Order is valid" : "Order is invalid")

Implement the Chain of Responsibility pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Chain of Responsibility pattern compare to simple if-else chains for validation?
2. In what scenarios might you use the Chain of Responsibility pattern in conjunction with other patterns we've covered?
3. How might this pattern be extended to handle more complex validation scenarios in an e-commerce app?

What is the Chain of Responsibility design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/


struct Order {
    var id: String
    var items: [String]
    var total: Double
    
    init(id: String, items: [String], total: Double) {
        self.id = id
        self.items = items
        self.total = total
    }
}

enum OrderValidationError: Error, Equatable {
    case inventoryError(String)
    case fraudError
    case paymentError
}

protocol OrderValidator {
    var nextValidator: OrderValidator? { get }
    
    func performLocalValidation(_ order: Order) throws -> Bool
    
    func validateOrder(_ order: Order) throws -> Bool
}

extension OrderValidator {
    func validateOrder(_ order: Order) throws -> Bool {
        //perform a self check
        do {
            try performLocalValidation(order)
        } catch {
            throw error
        }
        
        //next validator
        if let nextValidator = self.nextValidator {
            do {
                try nextValidator.validateOrder(order)
            }
            catch {
                throw error
            }
        }
        
        //return true if no blockers
        return true
    }
}


class InventoryValidator: OrderValidator {
    private var inventoryCount: Int
    private(set) var nextValidator: OrderValidator?
    
    init(inventoryCount: Int, nextValidator: OrderValidator?) {
        self.inventoryCount = inventoryCount
        self.nextValidator = nextValidator
    }
    
    func performLocalValidation(_ order: Order) throws -> Bool {
        guard inventoryCount >= order.items.count else {
            throw OrderValidationError.inventoryError("Error: Missing inventory of \(order.items.count - inventoryCount) items.")
        }
        
        //no other checks needed
        return true
    }
}
        
    
class FraudValidator: OrderValidator {
    private var amountCeiling: Double
    private(set) var nextValidator: OrderValidator?
    
    init(amountCeiling: Double, nextValidator: OrderValidator?) {
        self.amountCeiling = amountCeiling
        self.nextValidator = nextValidator
    }
    
    func performLocalValidation(_ order: Order) throws -> Bool {
        guard amountCeiling >= order.total && order.total >= 0 else {
            throw OrderValidationError.fraudError
        }
        
        //no other checks needed
        return true
    }
}
    

class PaymentValidator: OrderValidator {
    private var targetTotal: Double
    private(set) var nextValidator: OrderValidator?
    
    init(targetTotal: Double, nextValidator: OrderValidator?) {
        self.targetTotal = targetTotal
        self.nextValidator = nextValidator
    }
    
    func performLocalValidation(_ order: Order) throws -> Bool {
        guard targetTotal == order.total else {
            throw OrderValidationError.paymentError
        }
        
        //no other checks needed
        return true
    }
}
 

class ValidationManager {
    
    private let inventoryVal: InventoryValidator
    private let fraudVal: FraudValidator
    private let paymentval: PaymentValidator
    
    init() {
        paymentval = PaymentValidator(targetTotal: 100.0, nextValidator: nil)
        fraudVal = FraudValidator(amountCeiling: 1000.0, nextValidator: paymentval)
        inventoryVal = InventoryValidator(inventoryCount: 2, nextValidator: fraudVal)
    }
    
    func validateOrder(_ order: Order) throws -> Bool {
        try inventoryVal.validateOrder(order)
        return true
    }
}


//Example usage:
let order = Order(id: "12345", items: ["item1", "item2"], total: 100.0)
let validationManager = ValidationManager()

do {
    let result = try validationManager.validateOrder(order)
    print(result ? "Order is valid" : "Order is invalid")
} catch {
    guard let er = error as? OrderValidationError else {
        print(error)
        throw error
    }
    
    switch(er) {
    case .inventoryError(let str):
        print(str)
    case .fraudError:
        print("Error: Fraud")
    case .paymentError:
        print("Error: Payment")
    }
}


import XCTest

class OrderValidationTests: XCTestCase {
    
    var validationManager: ValidationManager!
    
    override func setUp() {
        super.setUp()
        validationManager = ValidationManager()
    }
    
    func testValidOrder() {
        let order = Order(id: "12345", items: ["item1", "item2"], total: 100.0)
        XCTAssertNoThrow(try validationManager.validateOrder(order), "Valid order should not throw an error")
    }
    
    func testInventoryError() {
        let order = Order(id: "12345", items: ["item1", "item2", "item3"], total: 100.0)
        XCTAssertThrowsError(try validationManager.validateOrder(order)) { error in
            XCTAssertEqual(error as? OrderValidationError, .inventoryError("Error: Missing inventory of 1 items."), "Should throw inventory error")
        }
    }
    
    func testFraudError() {
        let order = Order(id: "12345", items: ["item1", "item2"], total: 1500.0)
        XCTAssertThrowsError(try validationManager.validateOrder(order)) { error in
            XCTAssertEqual(error as? OrderValidationError, .fraudError, "Should throw fraud error")
        }
    }
    
    func testPaymentError() {
        let order = Order(id: "12345", items: ["item1", "item2"], total: 99.0)
        XCTAssertThrowsError(try validationManager.validateOrder(order)) { error in
            XCTAssertEqual(error as? OrderValidationError, .paymentError, "Should throw payment error")
        }
    }
    
    func testChainOrder() {
        let inventoryValidator = InventoryValidator(inventoryCount: 2, nextValidator: nil)
        let fraudValidator = FraudValidator(amountCeiling: 1000.0, nextValidator: inventoryValidator)
        let paymentValidator = PaymentValidator(targetTotal: 100.0, nextValidator: fraudValidator)
        
        let order = Order(id: "12345", items: ["item1", "item2"], total: 100.0)
        
        XCTAssertNoThrow(try paymentValidator.validateOrder(order), "Valid order should pass all validations")
    }
}
