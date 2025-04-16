import CoreML
import Vision

// Mock version of MobileNetV2 for demo purposes
class MobileNetV2 {
    static let shared = MobileNetV2()
    
    private init() {}
    
    // Mock model that returns predefined classifications
    var model: MLModel {
        get throws {
            // This is a mock model that will be replaced with the real MobileNetV2 later
            MockMLModel()
        }
    }
}

// Mock MLModel for demo purposes
class MockMLModel: MLModel {
    override var modelDescription: MLModelDescription {
        MLModelDescription()
    }
    
    override func prediction(from input: MLFeatureProvider, options: MLPredictionOptions = MLPredictionOptions()) throws -> MLFeatureProvider {
        // Return mock predictions based on a timer to simulate different objects being detected
        let mockObjects = ["book", "laptop", "camera", "headphones"]
        let index = Int(Date().timeIntervalSince1970) % mockObjects.count
        return MockPrediction(label: mockObjects[index])
    }
}

class MockPrediction: MLFeatureProvider {
    let label: String
    
    init(label: String) {
        self.label = label
    }
    
    var featureNames: Set<String> {
        ["classLabel"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "classLabel" {
            return MLFeatureValue(string: label)
        }
        return nil
    }
} 