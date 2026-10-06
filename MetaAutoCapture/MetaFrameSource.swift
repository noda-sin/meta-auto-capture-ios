import AVFoundation

/// Integration seam for Meta Wearables Device Access Toolkit.
///
/// Keep Meta SDK types out of the scoring pipeline. The DAT adapter only needs
/// to convert/forward each SDK video frame as a CMSampleBuffer (or introduce a
/// common PixelFrame type if the SDK exposes CVPixelBuffer directly).
///
/// Mock Device Kit and physical glasses should both feed this adapter, so the
/// HighlightEngine/CaptureStore remain unchanged.
final class MetaFrameSource: FrameSource {
    weak var delegate: FrameSourceDelegate?

    func start() throws {
        // TODO(meta-dat): create/start DAT camera stream.
        // On each frame: delegate?.frameSource(self, didOutput: sampleBuffer)
        throw MetaSourceError.sdkNotLinked
    }

    func stop() {
        // TODO(meta-dat): stop stream.
    }

    enum MetaSourceError: Error { case sdkNotLinked }
}
