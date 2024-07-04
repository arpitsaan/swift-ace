/*
 Certainly! Let's discuss the Flyweight pattern and its implementation in this e-commerce context.

 How does the Flyweight pattern compare to the Singleton pattern in terms of object reuse?

 The Flyweight and Singleton patterns both involve reusing objects, but they serve different purposes:

 Flyweight focuses on sharing multiple similar objects to reduce memory usage. It's about efficiency through reuse.
 Singleton ensures only one instance of a class exists. It's about global access and uniqueness.

 In our implementation, the ProductAttributesFactory uses a Flyweight-like approach to reuse ProductAttributes objects, while it could potentially be a Singleton itself if we wanted only one factory in the entire app.

 In what scenarios might you use the Flyweight pattern in conjunction with the Factory Method pattern we covered earlier?

 The Flyweight and Factory Method patterns can work well together:

 The Factory Method could be used to create different types of ProductAttributes (e.g., for different product categories).
 The Flyweight (ProductAttributesFactory) would then manage and reuse these created objects.
 
 How might the Flyweight pattern be useful in other areas of your e-commerce app, such as order management or user profiles?


 Order Management: Common order statuses, shipping methods, or payment types could be implemented as flyweights.
 User Profiles: Shared user attributes like membership levels or preferences could use the Flyweight pattern.
 Product Reviews: Common rating levels or review tags could be flyweights.
 Inventory Management: Shared inventory statuses or locations could be implemented as flyweights.

 The Flyweight pattern shines in scenarios where:

 You have a large number of objects.
 Storage costs are high because of the quantity of objects.
 Most object state can be made extrinsic.
 Many groups of objects may be replaced by relatively few shared objects once extrinsic state is removed.
 The application doesn't depend on object identity.

 In our e-commerce app, this pattern helps manage memory efficiently, which is crucial for mobile devices with limited resources. It allows the app to handle a large product catalog without excessive memory usage, potentially improving performance and user experience.
 */
/*
Problem: Efficient Product Catalog System using Flyweight Pattern

Description:
You're developing an iOS e-commerce app that needs to display a large catalog of products efficiently. Many products share common attributes (like brand, category, or shipping method), and you want to optimize memory usage by sharing these common attributes across multiple product instances.

Why Flyweight Pattern?
The Flyweight pattern is suitable here because:
1. We have a large number of similar objects (products).
2. Many products have common, shareable attributes.
3. We need to reduce memory usage, especially important for mobile devices.

Requirements:
1. Create a `ProductAttributes` struct that holds common, shareable product information (e.g., brand, category, shipping method).
   Why: This represents the intrinsic, shareable state of a product.

2. Implement a `Product` class that contains a reference to a `ProductAttributes` and the unique product information (e.g., name, price, SKU).
   Why: This separates the intrinsic state (shared attributes) from the extrinsic state (unique product details).

3. Create a `ProductAttributesFactory` that manages and reuses `ProductAttributes` instances.
   Why: This factory ensures that we don't create duplicate attribute objects.

4. Implement a `ProductCatalog` class that uses the `ProductAttributesFactory` to create and manage products.
   Why: This demonstrates how the Flyweight pattern is used in the context of the e-commerce app.

5. Add a method to `ProductCatalog` to calculate the memory usage of the catalog, both with and without the Flyweight pattern.
   Why: This helps visualize the memory savings achieved by using the pattern.

Example usage:
let catalog = ProductCatalog()
catalog.addProduct(name: "T-Shirt", price: 19.99, sku: "TS001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
catalog.addProduct(name: "Jeans", price: 49.99, sku: "JN001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
catalog.addProduct(name: "Sneakers", price: 79.99, sku: "SN001", brand: "SportyBrand", category: "Footwear", shippingMethod: "Express")
print(catalog.getMemoryUsage())
print(catalog.getMemoryUsageWithoutFlyweight())

Implement the Flyweight pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Flyweight pattern compare to the Singleton pattern in terms of object reuse?
2. In what scenarios might you use the Flyweight pattern in conjunction with the Factory Method pattern we covered earlier?
3. How might the Flyweight pattern be useful in other areas of your e-commerce app, such as order management or user profiles?

*/

struct ProductAttributes: Hashable {
    var brand: String
    var category: String
    var shippingMethod: String
}

struct Product {
    var sku: String
    var name: String
    var price: Double
    var attributes: ProductAttributes
     
    init(sku: String, name: String, price: Double, attributes: ProductAttributes) {
        self.sku = sku
        self.name = name
        self.price = price
        self.attributes = attributes
    }
}


class ProductAttributesFactory {
    private var attributesCache: [ProductAttributes: ProductAttributes] = [:]
    
    func getProductAttributes(brand: String, category: String, shippingMethod: String) -> ProductAttributes {
        let attributes = ProductAttributes(brand: brand, category: category, shippingMethod: shippingMethod)
        if let cachedAttributes = attributesCache[attributes] {
            return cachedAttributes
        } else {
            attributesCache[attributes] = attributes
            return attributes
        }
    }
    
    var uniqueAttributesCount: Int {
        return attributesCache.count
    }
}

class ProductCatalog {
    
    private var products: [Product] = []
    private let attributesFactory = ProductAttributesFactory()
    
    func addProduct(name: String, price: Double, sku: String, brand: String, category: String, shippingMethod: String) {
        let attributes = attributesFactory.getProductAttributes(brand: brand, category: category, shippingMethod: shippingMethod)
        let product = Product(sku: sku, name: name, price: price, attributes: attributes)
        products.append(product)
    }
    
    var productsCount: Int {
        return products.count
    }
    
    var uniqueAttributesCount: Int {
        return attributesFactory.uniqueAttributesCount
    }
    
    func getMemoryUsage() -> Int {
        //simplified estimation
        return MemoryLayout<Product>.size * products.count +
        MemoryLayout<ProductAttributes>.size * attributesFactory.uniqueAttributesCount
    }
    
    func getMemoryUsageWithoutFlyweight() -> Int {
        //simplified estimation
        return (MemoryLayout<Product>.size + MemoryLayout<ProductAttributes>.size) * products.count
    }
    
}

//Example usage:
let catalog = ProductCatalog()
catalog.addProduct(name: "T-Shirt", price: 19.99, sku: "TS001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
catalog.addProduct(name: "Jeans", price: 49.99, sku: "JN001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
catalog.addProduct(name: "Sneakers", price: 79.99, sku: "SN001", brand: "SportyBrand", category: "Footwear", shippingMethod: "Express")
print(catalog.getMemoryUsage())
print(catalog.getMemoryUsageWithoutFlyweight())

//-----------------------------------------------------------------------------------------------------------

import XCTest
import PlaygroundSupport


class FlyweightTests: XCTestCase {
    
    var catalog: ProductCatalog!
    
    override func setUp() {
        super.setUp()
        catalog = ProductCatalog()
    }
    
    override func tearDown() {
        catalog = nil
        super.tearDown()
    }
    
    func testAddProduct() {
        catalog.addProduct(name: "T-Shirt", price: 19.99, sku: "TS001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
        XCTAssertEqual(catalog.productsCount, 1, "Product count should be 1 after adding a product")
    }
    
    func testFlyweightReuse() {
        catalog.addProduct(name: "T-Shirt", price: 19.99, sku: "TS001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
        catalog.addProduct(name: "Jeans", price: 49.99, sku: "JN001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
        
        XCTAssertEqual(catalog.uniqueAttributesCount, 1, "There should be only one unique ProductAttributes instance")
    }
    
    func testMemoryUsage() {
        catalog.addProduct(name: "T-Shirt", price: 19.99, sku: "TS001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
        catalog.addProduct(name: "Jeans", price: 49.99, sku: "JN001", brand: "FashionCo", category: "Apparel", shippingMethod: "Standard")
        
        let flyweightMemory = catalog.getMemoryUsage()
        let nonFlyweightMemory = catalog.getMemoryUsageWithoutFlyweight()
        
        XCTAssertLessThan(flyweightMemory, nonFlyweightMemory, "Flyweight implementation should use less memory")
    }
}

// Run the tests
FlyweightTests.defaultTestSuite.run()
