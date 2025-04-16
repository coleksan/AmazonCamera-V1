//
//  AmazonCameraApp.swift
//  NextLevel (iOS)
//
//  Created by Cole on 4/15/25.
//

import Foundation
import SwiftUI

@main
struct AmazonCameraApp: App {
    // Create an AmazonAPIService instance to pass to ContentView
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
