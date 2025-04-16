import SwiftUI

struct ContentView: View {
    private let amazonService: AmazonAPIService
    
    init(amazonService: AmazonAPIService) {
        self.amazonService = amazonService
    }
    
    var body: some View {
        HomeView(amazonService: amazonService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(amazonService: AmazonAPIService(
            accessKey: "YOUR_ACCESS_KEY",
            secretKey: "YOUR_SECRET_KEY",
            associateTag: "YOUR_ASSOCIATE_TAG"
        ))
    }
}

// Original camera-related code moved to CameraView.swift 
