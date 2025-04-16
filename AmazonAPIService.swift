import Foundation

// Mock version of AmazonAPIService for demo purposes
class AmazonAPIService {
    // Demo credentials - these aren't used in the mock version
    private let accessKey: String
    private let secretKey: String
    private let associateTag: String
    
    init(accessKey: String = "demo", secretKey: String = "demo", associateTag: String = "demo") {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.associateTag = associateTag
    }
    
    // Mock product data
    private let mockProducts: [String: [AmazonProduct]] = [
        "book": [
            AmazonProduct(id: "1", title: "The Great Gatsby", price: 9.99, url: "https://amazon.com"),
            AmazonProduct(id: "2", title: "To Kill a Mockingbird", price: 12.99, url: "https://amazon.com")
        ],
        "laptop": [
            AmazonProduct(id: "3", title: "MacBook Air M1", price: 999.99, url: "https://amazon.com"),
            AmazonProduct(id: "4", title: "Dell XPS 13", price: 1299.99, url: "https://amazon.com")
        ],
        "camera": [
            AmazonProduct(id: "5", title: "Canon EOS R5", price: 3899.99, url: "https://amazon.com"),
            AmazonProduct(id: "6", title: "Sony A7 IV", price: 2499.99, url: "https://amazon.com")
        ],
        "headphones": [
            AmazonProduct(id: "7", title: "Sony WH-1000XM4", price: 349.99, url: "https://amazon.com"),
            AmazonProduct(id: "8", title: "AirPods Pro", price: 249.99, url: "https://amazon.com")
        ],
        "default": [
            AmazonProduct(id: "9", title: "Popular Item 1", price: 29.99, url: "https://amazon.com"),
            AmazonProduct(id: "10", title: "Popular Item 2", price: 39.99, url: "https://amazon.com")
        ]
    ]
    
    func searchProducts(for query: String) async throws -> [AmazonProduct] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Convert query to lowercase and find matching products
        let searchTerm = query.lowercased()
        return mockProducts.first { key, _ in
            searchTerm.contains(key)
        }?.value ?? mockProducts["default"]!
    }
    
    func addToCart(product: AmazonProduct) async throws -> URL {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Return a mock Amazon URL
        return URL(string: "https://amazon.com/cart")!
    }
}

struct AmazonProduct: Identifiable {
    let id: String
    let title: String
    let price: Double
    let url: String
} 