import AVFoundation

protocol FrameSourceDelegate: AnyObject {
    func frameSource(_ source: any FrameSource, didOutput buffer: CMSampleBuffer)
}
protocol FrameSource: AnyObject {
    var delegate: FrameSourceDelegate? { get set }
    func start() throws
    func stop()
}

/// AVFoundation implementation used for the hardware-free Meta POC.
/// Meta DAT/Mock adapters should conform to the same protocol.
final class IPhoneCameraSource: NSObject, FrameSource, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: FrameSourceDelegate?
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "camera.frames", qos: .userInitiated)

    override init() {
        super.init()
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else { session.commitConfiguration(); return }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
    }
    func start() throws { if !session.isRunning { session.startRunning() } }
    func stop() { if session.isRunning { session.stopRunning() } }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.frameSource(self, didOutput: sampleBuffer)
    }
}
