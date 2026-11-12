# Performance Findings

## Baseline

- Run mode: Profile mode on an Android phone.
- Evidence: `screenshots/before-profile.png` shows the Flutter frame chart. The screenshot does not identify which user action was being performed.

## Confirmed finding

`dart_devtools_2026-11-12_14_12_55.104.json`

### 1. Raster jank on Flutter frame 124

- Screen/action: Not identifiable.
- Evidence: `screenshots/peak1.png` shows **Raster Jank Detected** for Flutter frame 124. Raster phase took **21.6 ms**, exceeding the approximately **16.7 ms** frame budget for 60 FPS. UI build and paint took 0.1 ms and 0.4 ms, respectively, so the captured delay was in rasterization.
- Impact: This frame missed the 60 FPS budget and could appear as a brief dropped or delayed frame.
- Follow-up: Record again while noting the exact screen and action, then inspect the selected frame to connect the raster jank to its cause.

## Frames checked with no jank

- `screenshots/peak2.png`: Flutter frame 386; DevTools reports no jank. Build 3.0 ms, layout 3.3 ms, paint 2.3 ms, raster 8.6 ms.
- `screenshots/peak3.png`: Flutter frame 398; DevTools reports no jank. Build 3.2 ms, layout 6.6 ms, paint 1.9 ms, raster 6.9 ms.

These two frames are not performance findings. The screenshots currently support only one confirmed issue; they do not provide evidence for two additional findings. Do not infer repeated requests, excessive rebuilds, slow scrolling, or memory leaks without collecting evidence for them.
