# Meta Auto Capture iOS

POC for a hands-free “personal camera operator”:

- continuous camera frames
- on-device best-shot scoring
- automatic still capture
- rolling video buffer architecture
- pluggable frame source for iPhone / Meta Wearables Device Access Toolkit

## MVP architecture

```
FrameSource (iPhone now / Meta later)
  -> HighlightEngine
      -> Vision face/person detection
      -> sharpness + exposure + composition score
      -> cooldown / event gating
  -> CaptureStore
      -> best frame JPEG
      -> rolling video clip (next milestone)
```

The first milestone intentionally has no cloud/LLM dependency. Candidate selection should be cheap, private and realtime on-device.

## Run

1. Open the project in Xcode (project scaffolding is added in the implementation branch).
2. Run on a physical iPhone.
3. Grant Camera and Photos permissions.
4. Point the rear camera at people/scenes.
5. High-scoring frames are surfaced by the app and can be auto-saved.

## Meta integration

`FrameSource` is deliberately independent of AVFoundation. A Meta DAT adapter can emit the SDK video frames into the same `HighlightEngine` without changing scoring/storage.

## Roadmap

- [x] architecture
- [ ] iPhone camera source
- [ ] Vision scoring
- [ ] automatic still save
- [ ] rolling encoded video buffer
- [ ] pre/post-event clip export
- [ ] Meta Mock Device adapter
- [ ] Meta glasses adapter
- [ ] optional semantic reranking
