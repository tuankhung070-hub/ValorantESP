import UIKit
import ReplayKit
import AVFoundation

class CaptureManager: NSObject {
    static let shared = CaptureManager()
    private let recorder = RPScreenRecorder.shared()
    private var captureQueue = DispatchQueue(label: "capture.queue")
    private var currentPixelBuffer: CVPixelBuffer?
    
    func startCapture() {
        guard recorder.isAvailable else { return }
        recorder.startCapture(handler: { [weak self] sampleBuffer, bufferType, error in
            guard let self = self else { return }
            if let error = error {
                print("Lỗi ghi: \(error.localizedDescription)")
                return
            }
            if bufferType == .video {
                self.captureQueue.async {
                    if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        self.currentPixelBuffer = pixelBuffer
                        DispatchQueue.main.async {
                            DetectionService.shared.processFrame(pixelBuffer)
                        }
                    }
                }
            }
        }) { error in
            print("Không thể bắt đầu ghi: \(error?.localizedDescription ?? "unknown")")
        }
    }
    
    func stopCapture() {
        recorder.stopCapture { error in
            print("Dừng ghi: \(error?.localizedDescription ?? "ok")")
        }
    }
}
