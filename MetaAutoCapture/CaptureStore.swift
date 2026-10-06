import Photos
import UIKit
import AVFoundation

actor CaptureStore {
    private let context = CIContext()
    func saveStill(from buffer: CMSampleBuffer) async {
        guard let pixel = CMSampleBufferGetImageBuffer(buffer),
              let cg = context.createCGImage(CIImage(cvPixelBuffer: pixel), from: CIImage(cvPixelBuffer: pixel).extent) else { return }
        let image = UIImage(cgImage: cg, scale: 1, orientation: .right)
        guard let data = image.jpegData(compressionQuality: 0.94) else { return }
        try? await PHPhotoLibrary.shared().performChanges {
            let req = PHAssetCreationRequest.forAsset()
            req.addResource(with: .photo, data: data, options: nil)
        }
    }
}
