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
