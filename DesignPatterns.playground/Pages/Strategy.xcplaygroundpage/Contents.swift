/*
 What is the Strategy design pattern in the context of iOS development?
 The Strategy pattern is a behavioral design pattern that enables selecting an algorithm's implementation at runtime. It defines a family of algorithms, encapsulates each one, and makes them interchangeable within that family. In iOS development, this pattern is often used to implement different behaviors that can be switched dynamically, such as different UI layouts, data processing algorithms, or, as in this case, pricing strategies.
 Discussion points:

 Comparison to using simple conditional statements:

 Strategy pattern provides better organization and encapsulation of different algorithms.
 It's more extensible: adding new strategies doesn't require modifying existing code.
 It adheres better to the Open/Closed principle of SOLID.


 Advantages in iOS app architecture:

 Promotes code reusability and modularity.
 Makes it easier to unit test individual strategies.
 Allows for easy addition of new behaviors without modifying existing code.
 Improves code readability by separating complex logic into distinct classes.


 Potential drawbacks or limitations:

 Can increase the number of classes in your project.
 Might be overkill for very simple variations in behavior.
 Requires clients to be aware of different strategies.


 Combining with other patterns:

 Factory Pattern: Use a factory to create appropriate strategies based on certain conditions.
 Observer Pattern: Notify observers when a strategy changes.
 Singleton: If a strategy needs to maintain state across the app.


 iOS-specific considerations:

 Can be used for implementing different UI layouts for iPhone and iPad.
 Useful for handling different networking strategies (e.g., REST vs GraphQL).
 Can be applied to implement various animation strategies in UIKit.


 Swift-specific implementation notes:

 Protocols in Swift make it easy to define strategy interfaces.
 Swift's first-class functions can sometimes be used as a lightweight alternative to full strategy classes.


 This implementation provides a solid foundation for using the Strategy pattern in iOS apps. It's particularly useful in scenarios where you need to switch between different algorithms or behaviors at runtime, which is common in dynamic, user-centric iOS applications.
 */
 /*
Problem 13: Dynamic Pricing Strategy for E-commerce App using Strategy Pattern

Description:
You're developing an iOS e-commerce app that needs to support various pricing strategies for products. The app should be able to switch between different pricing strategies (e.g., regular pricing, discount pricing, bulk purchase pricing) dynamically based on various factors like user type, time of day, or special promotions.

Why Strategy Pattern?
The Strategy pattern is suitable for this scenario because:
1. We need to define a family of algorithms (pricing strategies) and make them interchangeable.
2. We want to be able to switch between different pricing strategies at runtime.
3. We need to avoid a complex conditional structure for different pricing scenarios.

Requirements:
1. Create a PricingStrategy protocol that defines a method for calculating the price.
   Why: This provides a common interface for all pricing strategies.

2. Implement concrete classes for different pricing strategies (e.g., RegularPricing, DiscountPricing, BulkPurchasePricing).
   Why: These represent the different algorithms for calculating prices.

3. Create a Product class that uses a PricingStrategy to determine its price.
   Why: This allows the pricing strategy to be changed dynamically for each product.

4. Implement a method to change the pricing strategy of a product at runtime.
   Why: This demonstrates the flexibility of the Strategy pattern.

5. (Bonus) Implement a context-based strategy selector that chooses the appropriate strategy based on factors like user type, time of day, etc.
   Why: This shows how the Strategy pattern can be used in real-world scenarios with complex decision-making.

Example usage:
let product = Product(name: "Fancy Gadget", basePrice: 100.0, strategy: RegularPricing())
print(product.getPrice()) // Should print the regular price

product.setPricingStrategy(DiscountPricing(discountPercentage: 20))
print(product.getPrice()) // Should print the discounted price

product.setPricingStrategy(BulkPurchasePricing(quantity: 5, discountPercentage: 10))
print(product.getPrice()) // Should print the bulk purchase price

Implement the Strategy pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. How the Strategy pattern compares to using simple conditional statements for pricing logic
2. Advantages of using the Strategy pattern in iOS app architecture
3. Potential drawbacks or limitations of the Strategy pattern in iOS
4. How the Strategy pattern can be combined with other patterns (e.g., Factory, Observer) in an iOS app

What is the Strategy design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/


protocol PricingStrategy {
    func getPrice(basePrice: Double) -> Double
}

class RegularPricing: PricingStrategy {
    func getPrice(basePrice: Double) -> Double {
        return basePrice
    }
}

class DiscountPricing: PricingStrategy {
    private var discountPercentage: Double
    
    init(discountPercentage: Double) {
        self.discountPercentage = discountPercentage
    }
    
    func getPrice(basePrice: Double) -> Double {
        return basePrice * (1 - discountPercentage / 100)
    }
}

class BulkPurchasePricing: PricingStrategy {
    private var discountPercentage: Double = 0.0
    private var quantity: Int
    
    init(discountPercentage: Double, quantity: Int) {
        self.discountPercentage = discountPercentage
        self.quantity = quantity
    }
    
    func getPrice(basePrice: Double) -> Double {
        let effectiveDiscount = discountPercentage + discountPercentage * (0.1 * Double(quantity))
        return basePrice * (1 - effectiveDiscount / 100)
    }
}


class Product {
    private var name: String
    private var basePrice: Double
    private var strategy: PricingStrategy
    
    init(name: String, basePrice: Double, strategy: PricingStrategy) {
        self.name = name
        self.basePrice = basePrice
        self.strategy = strategy
    }
    
    func setPricingStrategy(_ strategy: PricingStrategy) {
        self.strategy = strategy
    }
    
    func getPrice() -> Double {
        return self.strategy.getPrice(basePrice: self.basePrice)
    }
}

//example usage
let product = Product(name: "Fancy Gadget", basePrice: 100.0, strategy: RegularPricing())
print(product.getPrice()) // Should print the regular price

product.setPricingStrategy(DiscountPricing(discountPercentage: 10))
print(product.getPrice()) // Should print the discounted price

product.setPricingStrategy(BulkPurchasePricing(discountPercentage: 10, quantity: 5))
print(product.getPrice()) // Should print the bulk purchase price

