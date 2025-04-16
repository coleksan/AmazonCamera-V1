import SwiftUI

@main
struct NextLevelApp: App {
    // Initialize the Amazon service
    private let amazonService = AmazonAPIService(
        accessKey: "YOUR_ACCESS_KEY",
        secretKey: "YOUR_SECRET_KEY",
        associateTag: "YOUR_ASSOCIATE_TAG"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(amazonService: amazonService)
        }
    }
}
