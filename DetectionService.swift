import UIKit
import Vision
import CoreML

class DetectionService: NSObject {
    static let shared = DetectionService()
    private var detectionQueue = DispatchQueue(label: "detection.queue")
    private var model: VNCoreMLModel?
    private var requests = [VNRequest]()
    
    override init() {
        super.init()
        setupModel()
    }
    
    private func setupModel() {
        guard let mlModel = try? player_detection(configuration: MLModelConfiguration()).model else {
            print("Model không tải được")
            return
        }
        guard let visionModel = try? VNCoreMLModel(for: mlModel) else { return }
        self.model = visionModel
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            self?.handleDetection(request: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFill
        self.requests = [request]
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        guard let model = model else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do { try handler.perform(requests) } catch { print("Vision error: \(error)") }
    }
    
    private func handleDetection(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        var detectedPlayers: [PlayerESP] = []
        for observation in results {
            let boundingBox = observation.boundingBox
            let confidence = observation.confidence
            guard confidence > 0.6 else { continue }
            let screenSize = UIScreen.main.bounds.size
            let rect = CGRect(
                x: boundingBox.origin.x * screenSize.width,
                y: (1 - boundingBox.origin.y - boundingBox.height) * screenSize.height,
                width: boundingBox.width * screenSize.width,
                height: boundingBox.height * screenSize.height
            )
            let distance = Float(100 / (boundingBox.width * boundingBox.height * 10))
            let health = Int.random(in: 20...100)
            let player = PlayerESP(
                rect: rect,
                confidence: confidence,
                distance: distance,
                health: health,
                name: "Địch #\(Int.random(in: 1...9))"
            )
            detectedPlayers.append(player)
        }
        DispatchQueue.main.async {
            ESPRenderer.shared.updatePlayers(detectedPlayers)
        }
    }
}

struct PlayerESP {
    let rect: CGRect
    let confidence: Float
    let distance: Float
    let health: Int
    let name: String
}
