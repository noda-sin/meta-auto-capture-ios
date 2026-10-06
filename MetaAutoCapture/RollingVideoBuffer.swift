import AVFoundation

/// Encodes a sequence of short rolling segments. When a highlight fires, the
/// current and recent segment URLs can be promoted into a final clip.
/// This avoids retaining raw 30fps pixel buffers (hundreds of MB) in memory.
actor RollingVideoBuffer {
    struct Segment { let url: URL; let start: CMTime; let end: CMTime }
    private(set) var segments: [Segment] = []
    let retention: Double
    init(retention: Double = 30) { self.retention = retention }

    func appendCompletedSegment(_ segment: Segment) {
        segments.append(segment)
        let newest = segment.end.seconds
        let expired = segments.filter { newest - $0.end.seconds > retention }
        segments.removeAll { newest - $0.end.seconds > retention }
        for item in expired { try? FileManager.default.removeItem(at: item.url) }
    }

    func segments(around time: Double, pre: Double = 8, post: Double = 8) -> [URL] {
        segments.filter { $0.end.seconds >= time - pre && $0.start.seconds <= time + post }.map(\.url)
    }
}
