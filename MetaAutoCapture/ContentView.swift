import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = CaptureViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(session: model.session).ignoresSafeArea()
            VStack(spacing: 8) {
                HStack {
                    Label(model.running ? "ANALYZING" : "STOPPED", systemImage: model.running ? "viewfinder" : "pause.circle")
                    Spacer()
                    Text(String(format: "score %.2f", model.score)).monospacedDigit()
                }
                .font(.caption.bold())
                if let reason = model.reason { Text(reason).font(.caption2).frame(maxWidth: .infinity, alignment: .leading) }
                Button(model.running ? "Stop" : "Start") { model.toggle() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .task { await model.prepare() }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView { let v = PreviewView(); v.layer.session = session; return v }
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var layer: AVCaptureVideoPreviewLayer { super.layer as! AVCaptureVideoPreviewLayer }
    override init(frame: CGRect) { super.init(frame: frame); layer.videoGravity = .resizeAspectFill }
    required init?(coder: NSCoder) { fatalError() }
}
