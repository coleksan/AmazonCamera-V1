//
//  HomeView.swift
//  NextLevel (iOS)
//
//  Created by Cole on 4/15/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var isShowingCamera = false
    private let amazonService: AmazonAPIService
    
    init(amazonService: AmazonAPIService) {
        self.amazonService = amazonService
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Amazon Camera")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // App description
                VStack(spacing: 20) {
                    Text("Shop smarter with Amazon Camera")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Take a picture of any object to find matching products on Amazon")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Camera button
                Button(action: {
                    isShowingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Start Scanning")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView(amazonService: amazonService)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(amazonService: AmazonAPIService())
    }
} 
