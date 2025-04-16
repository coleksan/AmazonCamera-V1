import SwiftUI
import AVFoundation
import Vision

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectedObjects: [String] = []
    @Published var suggestedProducts: [AmazonProduct] = []
    @Published var isLoadingProducts = false
    @Published var isUsingFrontCamera = false
    private var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let amazonService: AmazonAPIService
    
    // Add flags to control object detection
    private var shouldDetectObjects = false
    private var hasDetectedObject = false
    
    init(amazonService: AmazonAPIService) {
        self.amazonService = amazonService
        super.init()
        setupCamera()
        // Start mock object detection
        startMockDetection()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        // Setup camera input
        let position: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Setup video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        // Start the capture session
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    func toggleCamera() {
        isUsingFrontCamera.toggle()
        captureSession?.stopRunning()
        setupCamera()
    }
    
    func capturePhoto() {
        // Reset detection state
        hasDetectedObject = false
        shouldDetectObjects = true
        
        // For demo purposes, we'll simulate a detection immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let mockObjects = ["book", "laptop", "camera", "headphones"]
            let randomObject = mockObjects.randomElement()!
            
            self.detectedObjects = [randomObject]
            
            // Only detect one object, then immediately search for products
            self.hasDetectedObject = true
            self.shouldDetectObjects = false
            
            // Go directly to product search
            self.searchProducts(for: randomObject, andAddToCart: true)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Only process frames if detection is enabled
        guard shouldDetectObjects && !hasDetectedObject else { return }
        
        // In a real implementation, you would do vision-based object detection here
        // For now, we're using the mock implementation in capturePhoto()
    }
    
    private func searchProducts(for object: String, andAddToCart: Bool = false) {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        
        Task {
            do {
                let products = try await amazonService.searchProducts(for: object)
                DispatchQueue.main.async {
                    self.suggestedProducts = products
                    self.isLoadingProducts = false
                    
                    // If we should add to cart immediately, do it with the first product
                    if andAddToCart && !products.isEmpty {
                        self.addToCart(product: products[0])
                    }
                }
            } catch {
                print("Error searching products: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingProducts = false
                }
            }
        }
    }
    
    func addToCart(product: AmazonProduct) {
        Task {
            do {
                let cartURL = try await amazonService.addToCart(product: product)
                DispatchQueue.main.async {
                    UIApplication.shared.open(cartURL)
                }
            } catch {
                print("Error adding to cart: \(error)")
            }
        }
    }
    
    private func startMockDetection() {
        // Simulate object detection every 3 seconds
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let mockObjects = ["book", "laptop", "camera", "headphones"]
            let randomObject = mockObjects.randomElement()!
            
            DispatchQueue.main.async {
                self.detectedObjects = [randomObject]
                self.searchProducts(for: randomObject)
            }
        }
    }
}

struct CameraView: View {
    @StateObject private var cameraManager: CameraManager
    @State private var isShowingSettings = false
    @Environment(\.presentationMode) var presentationMode
    
    init(amazonService: AmazonAPIService) {
        _cameraManager = StateObject(wrappedValue: CameraManager(amazonService: amazonService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                if let previewLayer = cameraManager.previewLayer {
                    CameraPreviewView(previewLayer: previewLayer)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Overlay UI
                VStack {
                    // Top bar
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        
                        Spacer()
                        
                        Text("Amazon Camera")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { isShowingSettings = true }) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        // Detected object
                        if !cameraManager.detectedObjects.isEmpty {
                            Text("Detected: \(cameraManager.detectedObjects[0])")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }
                        
                        // Product suggestions
                        if cameraManager.isLoadingProducts {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else if !cameraManager.suggestedProducts.isEmpty {
                            ProductCarousel(products: cameraManager.suggestedProducts,
                                         onAddToCart: { product in
                                cameraManager.addToCart(product: product)
                            })
                        }
                        
                        HStack(spacing: 50) {
                            Button(action: { cameraManager.toggleCamera() }) {
                                Image(systemName: "camera.rotate")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            // Capture button
                            Button(action: { cameraManager.capturePhoto() }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }
}

struct ProductCarousel: View {
    let products: [AmazonProduct]
    let onAddToCart: (AmazonProduct) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(products) { product in
                    ProductCard(product: product, onAddToCart: { onAddToCart(product) })
                }
            }
            .padding(.horizontal)
        }
        .background(Color.black.opacity(0.3))
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Text("Amazon Associate ID")
                    Text("API Settings")
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Auto-detect objects", isOn: .constant(true))
                    Toggle("Show price alerts", isOn: .constant(true))
                }
                
                Section(header: Text("About")) {
                    Text("Version 1.0.0")
                    Text("Privacy Policy")
                    Text("Terms of Service")
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ProductCard: View {
    let product: AmazonProduct
    let onAddToCart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text("$\(product.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Button(action: onAddToCart) {
                Text("Add to Cart")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .frame(width: 200)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(amazonService: AmazonAPIService(
            accessKey: "YOUR_ACCESS_KEY",
            secretKey: "YOUR_SECRET_KEY",
            associateTag: "YOUR_ASSOCIATE_TAG"
        ))
    }
} 
