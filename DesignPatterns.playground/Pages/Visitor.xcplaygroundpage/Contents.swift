/*
 This implementation demonstrates the Visitor pattern for our product analysis system. Here's a breakdown of the key components:

 ProductVisitor protocol defines the interface for all visitors.
 Product protocol defines the accept method for all products.
 Concrete product classes (Electronics, Clothing, Book) implement the Product protocol.
 Concrete visitor classes (ShippingCostVisitor, DiscountVisitor, DescriptionVisitor) implement the ProductVisitor protocol.
 ProductCatalog class manages a collection of products and allows applying a visitor to all products.

 The Visitor pattern allows us to add new operations (like calculating shipping cost, applying discounts, or generating descriptions) without modifying our existing product classes. It also enables us to perform these operations on different types of products while maintaining type-specific behavior.
 To answer the discussion questions:

 Compared to implementing these operations within each product class, the Visitor pattern provides better separation of concerns and makes it easier to add new operations without modifying existing code.
 Other scenarios in an e-commerce app where the Visitor pattern might be useful include:

 Generating different types of reports (sales, inventory, etc.)
 Applying different tax calculations based on product type and region
 Implementing various promotional strategies


 To extend this pattern for new product types or operations:

 For new product types: Add a new concrete product class and a new visit method in the ProductVisitor protocol.
 For new operations: Create a new visitor class implementing the ProductVisitor protocol.



 The Visitor design pattern in iOS development provides a way to separate algorithms from object structures. It's particularly useful when you need to perform various operations on a set of objects with different types, allowing you to add new operations without changing the objects themselves. This pattern promotes flexibility and maintainability in your codebase, especially when dealing with complex object structures or diverse sets of related operations.
 */

/*
Problem: Product Analysis System using Visitor Pattern

Description:
You're developing an iOS e-commerce app that needs a flexible way to perform various analyses on different types of products. The app has multiple product types (e.g., Electronics, Clothing, Books), and you need to perform different operations on these products (e.g., calculate shipping cost, apply discount, generate description) without modifying the product classes.

Why Visitor Pattern?
The Visitor pattern is suitable here because:
1. You have a stable set of product classes but often need to define new operations on these classes.
2. You want to perform operations on products that don't naturally fit into the product classes.
3. You need to gather related operations into a single class rather than spreading them over the various product classes.

Step-by-Step Requirements:

1. Create a `ProductVisitor` protocol with visit methods for each concrete product type:
   - visitElectronics(product: Electronics)
   - visitClothing(product: Clothing)
   - visitBook(product: Book)
   Why: This defines the interface for all product visitors.

2. Create a `Product` protocol with an accept method:
   - accept(visitor: ProductVisitor)
   Why: This allows products to be "visited" by a visitor.

3. Implement concrete product classes (Electronics, Clothing, Book) conforming to the Product protocol.
   Why: These represent the elements that will be visited.

4. Implement concrete visitor classes for different operations:
   - ShippingCostVisitor
   - DiscountVisitor
   - DescriptionVisitor
   Each should conform to ProductVisitor and implement type-specific logic.
   Why: These encapsulate the operations to be performed on the products.

5. In each concrete product class, implement the accept method to call the appropriate visit method on the visitor.
   Why: This allows double dispatch, enabling the visitor to execute the correct method for each product type.

6. Create a `ProductCatalog` class that can hold multiple products and apply a visitor to all of them.
   Why: This demonstrates how to use the visitor pattern on a collection of products.

Example usage:
let catalog = ProductCatalog()
catalog.add(Electronics(name: "Laptop", price: 1000, weight: 2.5))
catalog.add(Clothing(name: "T-Shirt", price: 20, size: "M"))
catalog.add(Book(name: "Swift Programming", price: 50, author: "Apple"))

let shippingVisitor = ShippingCostVisitor()
catalog.accept(visitor: shippingVisitor)
print(shippingVisitor.totalShippingCost)

let discountVisitor = DiscountVisitor(discountPercentage: 10)
catalog.accept(visitor: discountVisitor)
print(discountVisitor.totalDiscount)

Implement the Visitor pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Visitor pattern compare to implementing these operations within each product class?
2. In what other scenarios in an e-commerce app might the Visitor pattern be useful?
3. How might this pattern be extended to handle new product types or new operations?

What is the Visitor design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here
import Foundation

// MARK: - Visitor Protocol
protocol ProductVisitor {
    func visitElectronics(product: Electronics)
    func visitClothing(product: Clothing)
    func visitBook(product: Book)
}

// MARK: - Product Protocol
protocol Product {
    func accept(visitor: ProductVisitor)
}

// MARK: - Concrete Products
class Electronics: Product {
    let name: String
    let price: Double
    let weight: Double
    
    init(name: String, price: Double, weight: Double) {
        self.name = name
        self.price = price
        self.weight = weight
    }
    
    func accept(visitor: ProductVisitor) {
        visitor.visitElectronics(product: self)
    }
}

class Clothing: Product {
    let name: String
    let price: Double
    let size: String
    
    init(name: String, price: Double, size: String) {
        self.name = name
        self.price = price
        self.size = size
    }
    
    func accept(visitor: ProductVisitor) {
        visitor.visitClothing(product: self)
    }
}

class Book: Product {
    let name: String
    let price: Double
    let author: String
    
    init(name: String, price: Double, author: String) {
        self.name = name
        self.price = price
        self.author = author
    }
    
    func accept(visitor: ProductVisitor) {
        visitor.visitBook(product: self)
    }
}

// MARK: - Concrete Visitors
class ShippingCostVisitor: ProductVisitor {
    private(set) var totalShippingCost: Double = 0
    
    func visitElectronics(product: Electronics) {
        totalShippingCost += product.weight * 2 // $2 per kg
    }
    
    func visitClothing(product: Clothing) {
        totalShippingCost += 5 // Flat $5 for clothing
    }
    
    func visitBook(product: Book) {
        totalShippingCost += 3 // Flat $3 for books
    }
}

class DiscountVisitor: ProductVisitor {
    private(set) var totalDiscount: Double = 0
    private let discountPercentage: Double
    
    init(discountPercentage: Double) {
        self.discountPercentage = discountPercentage
    }
    
    func visitElectronics(product: Electronics) {
        totalDiscount += product.price * discountPercentage / 100
    }
    
    func visitClothing(product: Clothing) {
        totalDiscount += product.price * discountPercentage / 100
    }
    
    func visitBook(product: Book) {
        totalDiscount += product.price * discountPercentage / 100
    }
}

class DescriptionVisitor: ProductVisitor {
    private(set) var descriptions: [String] = []
    
    func visitElectronics(product: Electronics) {
        descriptions.append("\(product.name) - $\(product.price) (Weight: \(product.weight)kg)")
    }
    
    func visitClothing(product: Clothing) {
        descriptions.append("\(product.name) - $\(product.price) (Size: \(product.size))")
    }
    
    func visitBook(product: Book) {
        descriptions.append("\(product.name) - $\(product.price) by \(product.author)")
    }
}

// MARK: - Product Catalog
class ProductCatalog {
    private var products: [Product] = []
    
    func add(_ product: Product) {
        products.append(product)
    }
    
    func accept(visitor: ProductVisitor) {
        for product in products {
            product.accept(visitor: visitor)
        }
    }
}

// MARK: - Usage
let catalog = ProductCatalog()
catalog.add(Electronics(name: "Laptop", price: 1000, weight: 2.5))
catalog.add(Clothing(name: "T-Shirt", price: 20, size: "M"))
catalog.add(Book(name: "Swift Programming", price: 50, author: "Apple"))

let shippingVisitor = ShippingCostVisitor()
catalog.accept(visitor: shippingVisitor)
print("Total Shipping Cost: $\(shippingVisitor.totalShippingCost)")

let discountVisitor = DiscountVisitor(discountPercentage: 10)
catalog.accept(visitor: discountVisitor)
print("Total Discount: $\(discountVisitor.totalDiscount)")

let descriptionVisitor = DescriptionVisitor()
catalog.accept(visitor: descriptionVisitor)
print("Product Descriptions:")
descriptionVisitor.descriptions.forEach { print($0) }
