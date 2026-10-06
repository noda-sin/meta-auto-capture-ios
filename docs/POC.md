# POC acceptance criteria

## Before buying glasses

Use an iPhone as the POV source and walk around normally for 15–30 minutes.

Success means:

1. Interesting human moments produce saved frames without touching the phone.
2. False captures are low enough that reviewing the output is easier than manually taking photos.
3. Processing remains realtime and does not visibly stall preview.
4. The same scene is not spammed (cooldown works).
5. Quality scoring can be tuned from real samples.

## Scoring v0

The first stage intentionally favors cheap signals:

- face presence: 50%
- edge/sharpness proxy: 30%
- exposure: 20%

Evaluation is throttled to ~3 fps. Capture requires a face, threshold >= 0.62, and an 8-second cooldown.

This is deliberately not yet a “beautiful photo” model. The goal is to validate automatic capture behavior first.

## Next scoring iteration

Add:

- face area / distance
- face yaw/pitch
- eye openness
- smile probability or expression embedding
- optical-flow / motion penalty
- duplicate-scene suppression using perceptual embeddings
- multi-frame burst ranking

Only after local candidate filtering works should semantic/LLM reranking be considered.

## Video design

Do **not** retain 30 seconds of raw CMSampleBuffer frames. Encode rolling 2–5 second H.264/HEVC segments and retain only the latest ~30 seconds. On an event, keep pre-event segments and continue encoding post-event segments, then concatenate/export them.

`RollingVideoBuffer` establishes this retention model; segment encoding/export is the next implementation step.

## Meta

`MetaFrameSource` is the adapter boundary. Link Meta Wearables DAT and implement stream start/stop/frame forwarding there. Mock Device and physical glasses should exercise the same downstream pipeline.
