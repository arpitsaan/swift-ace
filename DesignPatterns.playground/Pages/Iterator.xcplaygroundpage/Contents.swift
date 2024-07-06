/*
 The Iterator Pattern:
 The Iterator pattern provides a way to access the elements of an aggregate object sequentially without exposing its underlying representation. It's particularly useful when you want to traverse a collection without needing to know how the collection is structured internally.
 Key Components:

 Iterator: Defines an interface for accessing and traversing elements.
 ConcreteIterator: Implements the Iterator interface and keeps track of the current position in the traversal.
 Aggregate: Defines an interface for creating an Iterator object.
 ConcreteAggregate: Implements the Aggregate interface and returns an instance of the ConcreteIterator.

 Advantages:

 Simplifies the interface of aggregate objects.
 Supports variations in the traversal of a collection.
 More than one traversal can be pending on a collection.

 Disadvantages:

 Overkill for simple collections.
 Introduces additional classes which can increase complexity.

 In iOS/Swift Context:

 Swift's Standard Library: Swift already implements this pattern with its Sequence and IteratorProtocol protocols. Any type that conforms to Sequence can be iterated over using a for-in loop.
 Custom Collections: When you create custom collection types, you can make them iterable by conforming to Sequence and providing an iterator.
 Lazy Evaluation: Swift's lazy collections use iterators to provide on-demand computation of elements.
 Combining with Other Patterns: Iterator can be combined with the Composite pattern to iterate over tree-like structures.

 Example Use Cases in an E-commerce App:

 Paginated Product Listing: Use an iterator to fetch and display products page by page.
 Shopping Cart Items: Iterate over items in a shopping cart for display or checkout processes.
 Order History: Provide an iterator for browsing through a user's past orders.
 Category Navigation: If you have a hierarchical category structure, an iterator can help navigate through it.
*/

class PaginatedProductIterator: IteratorProtocol {
    private let pageSize: Int
    private var currentPage = 0
    private var currentIndex = 0
    private let productRepository: ProductRepository

    init(pageSize: Int, productRepository: ProductRepository) {
        self.pageSize = pageSize
        self.productRepository = productRepository
    }

    func next() async throws -> Product? {
        if currentIndex % pageSize == 0 {
            let products = try await productRepository.getProducts(page: currentPage, pageSize: pageSize)
            guard !products.isEmpty else { return nil }
            currentPage += 1
        }

        let product = try await productRepository.getProduct(at: currentIndex)
        currentIndex += 1
        return product
    }
}

// Usage
let iterator = PaginatedProductIterator(pageSize: 20, productRepository: productRepository)
var productList: [Product] = []

do {
    while let product = try await iterator.next() {
        productList.append(product)
        if productList.count >= 100 { break } // Limit to 100 products for this example
    }
} catch {
    print("Error fetching products: \(error)")
}
