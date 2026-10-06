import AVFoundation
import Photos

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var score = 0.0
    @Published var reason: String?
    @Published var running = false
    let source = IPhoneCameraSource()
    var session: AVCaptureSession { source.session }
    private let engine = HighlightEngine()
    private let store = CaptureStore()
    private var lastEvaluation = Date.distantPast
    private var lastCapture = Date.distantPast
    private let threshold = 0.62

    init() { source.delegate = self }

    func prepare() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else { reason = "Camera permission denied"; return }
        _ = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        toggle()
    }
    func toggle() {
        if running { source.stop(); running = false }
        else { try? source.start(); running = true }
    }
}

extension CaptureViewModel: FrameSourceDelegate {
    nonisolated func frameSource(_ source: any FrameSource, didOutput buffer: CMSampleBuffer) {
        let copy = buffer
        Task { @MainActor in
            guard Date().timeIntervalSince(lastEvaluation) >= 0.35 else { return } // ~3 fps scoring
            lastEvaluation = Date()
            guard let result = await engine.score(copy) else { return }
            score = result.total; reason = result.reason
            guard result.faces > 0, result.total >= threshold,
                  Date().timeIntervalSince(lastCapture) >= 8 else { return }
            lastCapture = Date()
            await store.saveStill(from: copy)
            reason = "SAVED • " + result.reason
        }
    }
}
