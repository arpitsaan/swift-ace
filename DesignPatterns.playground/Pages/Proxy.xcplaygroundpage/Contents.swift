/*
 Your implementation effectively demonstrates the key principles of the Proxy pattern:

 Control: It controls access to the PremiumProduct object.
 Enhancement: It adds functionality (access checking and caching) without changing the Product interface.
 Transparency: Clients interact with the proxy using the same interface as the real object.

 Now, let's discuss the Proxy pattern:
 What is the Proxy design pattern?
 The Proxy pattern is a structural design pattern that provides a surrogate or placeholder for another object to control access to it. It creates a representative object that controls access to another object, which may be remote, expensive to create, or in need of securing.
 Real-world applications in e-commerce systems:

 Access control for premium content or features (as demonstrated)
 Lazy loading of product images or detailed descriptions
 Caching frequently accessed product information
 Logging access to sensitive product data

 Advantages of using the Proxy pattern in this scenario:

 Separation of concerns: Access control logic is separated from the product logic
 Enhanced security: Provides a layer of protection for sensitive objects
 Improved performance: Allows for caching and lazy loading
 Flexibility: Easy to add or modify access control without changing the product classes

 Potential drawbacks or limitations:

 Added complexity: Introduces an additional layer, which can make the system more complex
 Potential performance impact: If not implemented carefully, the proxy can introduce a slight performance overhead

 Compared to other solutions:

 More flexible than hard-coding access control into the product classes
 More maintainable than using inheritance to create secured versions of each product type
 Provides better separation of concerns than implementing access control in the client code

 */

/*
Problem 11: Secure Product Catalog Access using Proxy Pattern

Description:
You're developing an e-commerce platform with a product catalog. Some products in the catalog are premium items with restricted access. You need to implement a system that controls access to these premium products based on user permissions.

Why Proxy Pattern?
The Proxy pattern is suitable for this scenario because:
1. We need to control access to certain objects (premium products).
2. We want to add functionality (access checking) when accessing these objects.
3. We need to maintain the same interface for all products, regardless of their access level.

Requirements:
1. Create a Product protocol with methods getDetails() -> String and getPrice() -> Double.
   Why: This defines the interface for all products, whether they're regular or premium.

2. Implement a RegularProduct class conforming to the Product protocol.
   Why: This represents standard products that don't require access control.

3. Implement a PremiumProduct class conforming to the Product protocol.
   Why: This represents the "real" premium products that require access control.

4. Create a PremiumProductProxy class that also conforms to the Product protocol.
   Why: This proxy will control access to PremiumProduct instances.

5. The PremiumProductProxy should check user permissions before allowing access to the premium product details.
   Why: This demonstrates how the proxy can add functionality (access control) when accessing an object.

6. Implement a simple UserPermission system to determine if a user has access to premium products.
   Why: This simulates a real-world authorization system.

7. The proxy should cache the product details after the first successful access to improve performance.
   Why: This shows how a proxy can add optimizations.

Example usage:
let userPermissions = UserPermissions(hasPremiumAccess: false)
let regularProduct = RegularProduct(name: "Standard Widget", price: 19.99)
let premiumProduct = PremiumProduct(name: "Luxury Gadget", price: 999.99)
let premiumProxy = PremiumProductProxy(product: premiumProduct, userPermissions: userPermissions)

print(regularProduct.getDetails()) // Always accessible
print(premiumProxy.getDetails()) // Access denied

userPermissions.grantPremiumAccess()
print(premiumProxy.getDetails()) // Now accessible

Implement the Proxy pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Proxy pattern in e-commerce systems
2. Advantages of using the Proxy pattern in this scenario
3. Potential drawbacks or limitations of the Proxy pattern
4. How the Proxy pattern compares to other potential solutions for access control and lazy loading

What is the Proxy design pattern?
[You'll answer this after implementing the solution]
*/


protocol Product {
    var name: String { get }
    func getDetails() -> String?
    func getPrice() -> Double?
}

class RegularProduct: Product {
    
    private(set) var name: String
    private var price: Double
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
    
    func getDetails() -> String? {
        return "Regular product details: \(name) for \(price)"
    }
    
    func getPrice() -> Double? {
        return price
    }
}

class PremiumProduct: Product {
    
    private(set) var name: String
    private var price: Double
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
    
    func getDetails() -> String? {
        return "Premium product details: \(name) for \(price)"
    }
    
    func getPrice() -> Double? {
        return price
    }
}

class PremiumProductProxy: Product {
    
    private(set) var name: String
    private var price: Double? = nil
    private var details: String? = nil
    
    private var product: PremiumProduct
    
    init(product: PremiumProduct) {
        self.product = product
        self.name = product.name
    }

    func getDetails() -> String? {
        guard UserPermissions.shared.hasPremiumAccess else {
            return nil
        }
        
        if let d = details {
            return d
        }
        
        details = product.getDetails()
        return details
    }
    
    func getPrice() -> Double {
        guard UserPermissions.shared.hasPremiumAccess else {
            return nil
        }
        
        if let p = price {
            return p
        }
        
        price = product.getPrice()
        return price
    }
}

class UserPermissions {
    
    private(set) var hasPremiumAccess = false
    
    static let shared = UserPermissions()
    
    private init() {}
    
    func grantPremiumAccess() {
        hasPremiumAccess = true
    }
    
    func revokePremiumAccess() {
        hasPremiumAccess = false
    }
    
}

let regularProduct = RegularProduct(name: "Standard Widget", price: 19.99)
let premiumProduct = PremiumProduct(name: "Luxury Gadget", price: 999.99)
let premiumProxy = PremiumProductProxy(product: premiumProduct)

print(regularProduct.getDetails()) // Always accessible
print(premiumProxy.getDetails()) // Access denied

UserPermissions.shared.grantPremiumAccess()
print(premiumProxy.getDetails()) // Now accessible

