/*
 What is the Bridge design pattern?
 The Bridge pattern is a structural design pattern that separates an abstraction from its implementation so that the two can vary independently. It's especially useful when both the abstraction and its implementation need to be extensible by subclassing.
 Real-world applications in e-commerce systems:

 Payment processing systems (as demonstrated)
 Shipping method implementations across different carriers
 Product catalog systems with varying database backends
 Order fulfillment processes across different warehouse systems

 Advantages in this scenario:

 Allows payment methods and checkout processes to evolve independently
 Makes it easy to add new payment methods or checkout processes without affecting existing code
 Promotes loose coupling between payment methods and checkout processes

 Potential drawbacks:

 Increases overall complexity of the code
 May be overkill for simple payment systems with few variations
 Requires planning and foresight to implement correctly

 Compared to other solutions:

 More flexible than using inheritance alone
 Allows for more separation of concerns than a monolithic approach
 More maintainable than using conditional statements to handle different combinations
*/

 
 /*
Problem 7: E-commerce Payment Processing System using Bridge Pattern

Description:
You're developing an e-commerce platform that needs to support multiple payment methods (Credit Card and PayPal) across different checkout processes (Web Checkout and Mobile App Checkout). The challenge is to create a flexible structure that allows different payment methods to be used with various checkout processes without creating a separate class for each combination.

Why Bridge Pattern?
The Bridge pattern is suitable for this scenario because:
1. We have two independent dimensions of variability: payment methods and checkout processes.
2. We want to avoid a proliferation of classes (e.g., CreditCardWebCheckout, PayPalWebCheckout, CreditCardMobileCheckout, PayPalMobileCheckout).
3. We need to be able to add new payment methods or checkout processes independently.
The Bridge pattern allows us to separate the abstraction (payment method) from the implementation (checkout process), enabling them to vary independently.

Requirements:
1. Create a CheckoutAPI protocol with methods processPayment(amount: Double) -> Bool and getLastError() -> String?.
   Why: This defines the interface for checkout-specific payment processing implementations.

2. Implement concrete classes WebCheckoutAPI and MobileCheckoutAPI conforming to CheckoutAPI.
   Why: These provide checkout-specific implementations of payment processing.

3. Create an abstract PaymentMethod class with a reference to CheckoutAPI and abstract methods pay(amount: Double) -> Bool and getType() -> String.
   Why: This forms the abstraction that will use the CheckoutAPI implementation.

4. Implement concrete CreditCardPayment and PayPalPayment classes inheriting from PaymentMethod.
   Why: These provide payment method-specific implementations using the CheckoutAPI.

5. Demonstrate the use of the bridge pattern by processing payments with different methods on different checkout processes.
   Why: This shows how payment methods and checkout processes can be mixed and matched flexibly.

6. Implement a simple algorithm in the PaymentMethod class to calculate a transaction fee based on the payment amount and method type.
   Why: This demonstrates that the PaymentMethod abstraction can have its own complex behavior.

Example usage:
let webCheckout = WebCheckoutAPI()
let mobileCheckout = MobileCheckoutAPI()

let creditCardOnWeb = CreditCardPayment(checkoutAPI: webCheckout, cardNumber: "1234-5678-9012-3456")
let paypalOnMobile = PayPalPayment(checkoutAPI: mobileCheckout, email: "user@example.com")

creditCardOnWeb.pay(amount: 100.0)  // Should use web-specific payment processing
paypalOnMobile.pay(amount: 50.0)  // Should use mobile-specific payment processing

print(creditCardOnWeb.getType())  // Should print "Credit Card"
print(paypalOnMobile.getType())  // Should print "PayPal"

print(creditCardOnWeb.calculateFee(amount: 100.0))  // Should print the calculated fee for credit card
print(paypalOnMobile.calculateFee(amount: 50.0))  // Should print the calculated fee for PayPal

Implement the Bridge pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Bridge pattern in e-commerce systems
2. Advantages of using the Bridge pattern in this scenario
3. Potential drawbacks or limitations of the Bridge pattern
4. How the Bridge pattern compares to other potential solutions for this e-commerce payment processing problem

What is the Bridge design pattern?
[You'll answer this after implementing the solution]
*/

protocol CheckoutAPI {
    
    func processPayment(amount: Double) -> Bool
    
    func getLastError() -> String?
}


class WebCheckoutAPI: CheckoutAPI {
    
    private let lastError: String?
    
    init() {
        self.lastError = nil
    }
    
    func processPayment(amount: Double) -> Bool {
        print("Processed payment of \(amount) through Web API")
        return true
    }
    
    func getLastError() -> String? {
        return lastError
    }
    
}

class MobileCheckoutAPI: CheckoutAPI {
    
    private let lastError: String?
    
    init() {
        self.lastError = nil
    }
    
    func processPayment(amount: Double) -> Bool {
        print("Processed payment of \(amount) through Mobile API")
        return true
    }
    
    func getLastError() -> String? {
        return lastError
    }
}

protocol PaymentMethod {
    var checkoutAPI: CheckoutAPI { get } //protocol depending on protocol: bridge, loosely coupled
    func pay(amount: Double) -> Bool
    func getType() -> String
}

extension PaymentMethod {
    func calculateFee(amount: Double) -> Double {
        return amount * 0.05 //5% fee
    }
    
    func pay(amount: Double) -> Bool {
        self.checkoutAPI.processPayment(amount: amount)
    }
}

class CreditCardPayment: PaymentMethod {
    
    private(set) var checkoutAPI: CheckoutAPI
    
    init(checkoutAPI: CheckoutAPI) {
        self.checkoutAPI = checkoutAPI
    }
    
    func getType() -> String {
        return "Credit Card"
    }
}


class PayPalPayment: PaymentMethod {
    
    private(set) var checkoutAPI: CheckoutAPI
    
    init(checkoutAPI: CheckoutAPI) {
        self.checkoutAPI = checkoutAPI
    }
    
    func getType() -> String {
        return "PayPal"
    }
}



//Example usage:
let mobileCheckout = MobileCheckoutAPI()
let ccPayment = CreditCardPayment(checkoutAPI: mobileCheckout)
ccPayment.pay(amount: 88.44)

let webCheckout = WebCheckoutAPI()

let creditCardOnWeb = CreditCardPayment(checkoutAPI: webCheckout)
let paypalOnMobile = PayPalPayment(checkoutAPI: mobileCheckout)

creditCardOnWeb.pay(amount: 100.0)  // Should use web-specific payment processing
paypalOnMobile.pay(amount: 50.0)  // Should use mobile-specific payment processing

print(creditCardOnWeb.getType())  // Should print "Credit Card"
print(paypalOnMobile.getType())  // Should print "PayPal"

print(creditCardOnWeb.calculateFee(amount: 100.0))  // Should print the calculated fee for credit card
print(paypalOnMobile.calculateFee(amount: 50.0))  // Should print the calculated fee for PayPal

