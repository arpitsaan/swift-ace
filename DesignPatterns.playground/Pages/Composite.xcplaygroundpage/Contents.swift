/*
 What is the Composite design pattern?
 The Composite pattern is a structural design pattern that lets you compose objects into tree structures to represent part-whole hierarchies. It allows clients to treat individual objects and compositions of objects uniformly.
 Real-world applications in e-commerce:

 Product category management (as demonstrated)
 Order structure (orders containing multiple items, which could be individual products or bundles)
 Menu systems in e-commerce websites
 Pricing rules and discount structures

 Advantages in this scenario:

 Allows for creating complex category hierarchies with any level of nesting
 Provides a uniform way to interact with both individual products and entire categories
 Makes it easy to add new types of components without changing existing code

 Potential drawbacks:

 Can make the design overly general, making it harder to restrict certain operations on specific objects
 Might be overkill for simple category structures
 Can be less efficient for certain operations that need to distinguish between leaves and composites

 Compared to other solutions:

 More flexible than using separate classes for products and categories with different interfaces
 Easier to extend and maintain than a monolithic class handling all product and category logic
 Provides a more natural representation of hierarchical structures compared to flat data structures
 */

/*
Problem 8: E-commerce Product Category Management using Composite Pattern

Description:
You're developing an e-commerce platform that needs a flexible product category management system. Categories can contain products or other categories (subcategories). The system should allow operations like calculating the total price of all products in a category (including its subcategories) and applying discounts across entire category hierarchies.

Why Composite Pattern?
The Composite pattern is suitable for this scenario because:
1. We have a tree-like structure (categories containing products or other categories).
2. We want to treat individual products and categories of products uniformly.
3. We need to perform operations that work the same way on both individual products and entire categories.

Requirements:
1. Create a ProductComponent protocol with methods getPrice() -> Double and applyDiscount(percent: Double).
   Why: This defines a common interface for both products and categories.

2. Implement a Product class conforming to ProductComponent.
   Why: This represents individual products in the system.

3. Implement a Category class conforming to ProductComponent that can contain other ProductComponents (products or subcategories).
   Why: This allows for creating a hierarchical structure of categories and products.

4. The Category class should have methods to add and remove ProductComponents.
   Why: This allows for dynamic management of the category structure.

5. Implement the getPrice() method in Category to return the total price of all contained components.
   Why: This demonstrates treating individual products and categories uniformly.

6. Implement the applyDiscount(percent: Double) method in both Product and Category.
   Why: This shows how operations can be applied across the entire structure.

7. Add a method in Category to print the structure of the category (including subcategories and products).
   Why: This helps visualize the composite structure.

Example usage:
let shirt = Product(name: "T-Shirt", price: 20.0)
let pants = Product(name: "Jeans", price: 50.0)
let shoes = Product(name: "Sneakers", price: 80.0)

let clothingCategory = Category(name: "Clothing")
clothingCategory.add(shirt)
clothingCategory.add(pants)

let footwearCategory = Category(name: "Footwear")
footwearCategory.add(shoes)

let rootCategory = Category(name: "All Products")
rootCategory.add(clothingCategory)
rootCategory.add(footwearCategory)

print(rootCategory.getPrice()) // Should print the total price of all products
rootCategory.applyDiscount(percent: 10)
print(rootCategory.getPrice()) // Should print the discounted total price
rootCategory.printStructure() // Should print the entire category structure
*/


protocol ProductComponent {
    
    var name: String { get }
    
    func getPrice() -> Double
    
    func applyDiscount(percent: Double)
    
    func printDetail()
    
}

class Product: ProductComponent {
    
    private(set) var name = ""
    private var price = 0.0
    
    init(name: String, price: Double = 0.0) {
        self.name = name
        self.price = price
    }
    
    func getPrice() -> Double {
        return price
    }
    
    func applyDiscount(percent: Double) {
        price *= (1 - percent / 100)
    }
    
    func printDetail() {
        print("Item with name \(name) and price \(getPrice()).")
    }
    
}


class Category: ProductComponent {

    private(set) var name = ""
    private var components: [ProductComponent] = []
    
    init(name: String, components: [ProductComponent] = []) {
        self.name = name
        self.components = components
    }
    
    func add(_ component: ProductComponent) {
        components.append(component)
    }
    
    func remove(_ component: ProductComponent) {
        components.removeAll(where: { $0.name == component.name })
    }
    
    func printStructure() {
        components.forEach { $0.printDetail() }
    }
    
    func printDetail() {
        print("Category with name \(name) and total price \(getPrice()).")
        components.forEach { $0.printDetail() }
    }
    
    //ProductComponent protocol
    func getPrice() -> Double {
        return components.reduce(0) { $0 + $1.getPrice() }
    }
    
    func applyDiscount(percent: Double) {
        components.forEach { $0.applyDiscount(percent: percent) }
    }
    
}


//Usage
let shirt = Product(name: "T-Shirt", price: 20.0)
let pants = Product(name: "Jeans", price: 50.0)
let shoes = Product(name: "Sneakers", price: 80.0)

let clothingCategory = Category(name: "Clothing")
clothingCategory.add(shirt)
clothingCategory.add(pants)

let footwearCategory = Category(name: "Footwear")
footwearCategory.add(shoes)

let rootCategory = Category(name: "All Products")
rootCategory.add(clothingCategory)
rootCategory.add(footwearCategory)

print(rootCategory.getPrice()) // Should print the total price of all products
rootCategory.applyDiscount(percent: 10)
print(rootCategory.getPrice()) // Should print the discounted total price
rootCategory.printStructure() // Should print the entire category structure
