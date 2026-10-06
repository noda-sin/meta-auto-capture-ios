import Vision
import CoreImage
import AVFoundation

struct HighlightScore {
    let total: Double
    let faces: Int
    let sharpness: Double
    let exposure: Double
    var reason: String { "faces=\(faces) sharp=\(String(format: "%.2f", sharpness)) exposure=\(String(format: "%.2f", exposure))" }
}

actor HighlightEngine {
    private let context = CIContext(options: [.cacheIntermediates: false])

    func score(_ buffer: CMSampleBuffer) async -> HighlightScore? {
        guard let pixel = CMSampleBufferGetImageBuffer(buffer) else { return nil }
        let ci = CIImage(cvPixelBuffer: pixel)
        let faceRequest = VNDetectFaceRectanglesRequest()
        try? VNImageRequestHandler(ciImage: ci, orientation: .right).perform([faceRequest])
        let faces = faceRequest.results?.count ?? 0

        // Cheap quality proxies suitable for first-stage gating.
        let exposure = meanLuma(ci)
        let exposureScore = max(0, 1 - abs(exposure - 0.52) / 0.52)
        let sharpness = edgeEnergy(ci)
        let faceScore = min(1, Double(faces) * 0.65)
        let total = 0.50 * faceScore + 0.30 * sharpness + 0.20 * exposureScore
        return HighlightScore(total: total, faces: faces, sharpness: sharpness, exposure: exposureScore)
    }

    private func meanLuma(_ image: CIImage) -> Double {
        let extent = image.extent
        guard let f = CIFilter(name: "CIAreaAverage") else { return .5 }
        f.setValue(image, forKey: kCIInputImageKey); f.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
        guard let out = f.outputImage else { return .5 }
        var px = [UInt8](repeating: 0, count: 4)
        context.render(out, toBitmap: &px, rowBytes: 4, bounds: CGRect(x: 0,y: 0,width: 1,height: 1), format: .RGBA8, colorSpace: nil)
        return (0.2126*Double(px[0]) + 0.7152*Double(px[1]) + 0.0722*Double(px[2])) / 255
    }

    private func edgeEnergy(_ image: CIImage) -> Double {
        guard let f = CIFilter(name: "CIEdges") else { return 0 }
        f.setValue(image, forKey: kCIInputImageKey); f.setValue(3.0, forKey: kCIInputIntensityKey)
        return min(1, meanLuma(f.outputImage ?? image) * 3.5)
    }
}
