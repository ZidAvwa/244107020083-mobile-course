# Performance Findings

## Baseline

- Run mode: Profile mode on an Android phone.
- Evidence: `screenshots/before-profile.png` shows the Flutter frame chart. The screenshot does not identify which user action was being performed.

## Confirmed finding

### 1. Raster jank on Flutter frame 124

`dart_devtools_before.json`

- Screen/action: Not identifiable.
- Evidence: `screenshots/peak1.png` shows **Raster Jank Detected** for Flutter frame 124. Raster phase took **21.6 ms**, exceeding the approximately **16.7 ms** frame budget for 60 FPS. UI build and paint took 0.1 ms and 0.4 ms, respectively, so the captured delay was in rasterization.
- Impact: This frame missed the 60 FPS budget and could appear as a brief dropped or delayed frame.
- Follow-up: Record again while noting the exact screen and action, then inspect the selected frame to connect the raster jank to its cause.

## Frames checked with no jank

- `screenshots/peak2.png`: Flutter frame 386; DevTools reports no jank. Build 3.0 ms, layout 3.3 ms, paint 2.3 ms, raster 8.6 ms.
- `screenshots/peak3.png`: Flutter frame 398; DevTools reports no jank. Build 3.2 ms, layout 6.6 ms, paint 1.9 ms, raster 6.9 ms.

These two frames are not performance findings. The screenshots currently support only one confirmed issue; they do not provide evidence for two additional findings. Do not infer repeated requests, excessive rebuilds, slow scrolling, or memory leaks without collecting evidence for them.

## Step 3: Optimizations applied

1. **Lazy announcement list:** Replaced the eager `ListView` children with `ListView.builder`, so rows are created as needed when scrolling. The current sample has only ten announcements, so the benefit for this dataset is small; this avoids eagerly creating every row as the list grows.
2. **Smaller rebuild scope:** Moved the search field and results list into separate consumer widgets. Typing in the search field updates those consumers without rebuilding the Home page and its AppBar.
3. **Reuse whitespace matcher:** Reused one compiled regular expression when normalizing search text instead of creating a new expression for each normalization.

These are general UI and search-path optimizations. The saved frame 124 shows raster-phase jank, not slow UI build work, and its screenshot does not reveal the raster workload. Therefore, these changes cannot yet be claimed as a fix for that specific jank; profile the same interaction again to compare.

## Step 4: Post-optimization verification

`dart_devtools_after.json`

- `screenshots/2peak1.png`: Selected Flutter frame 286 reports no jank; raster phase is 13.0 ms.
- `screenshots/2peak2.png`: Flutter frame 298 reports **Raster Jank Detected**; raster phase is 23.3 ms. UI phases are Build 4.6 ms, Layout 8.7 ms, and Paint 2.0 ms.
- `screenshots/2peak3.png`: Selected Flutter frame 308 reports no jank; raster phase is 14.8 ms.

The new capture still contains at least one janky frame (frame 298), so the changes above have not been shown to eliminate jank. The baseline screenshot `peak1.png` also recorded raster jank (21.6 ms on frame 124), but the captures do not establish that the same screen/action was tested under comparable conditions. We therefore cannot conclude from these screenshots whether overall performance improved or worsened. Record both before and after runs with the same interaction and compare the affected frames.
