# NCNN & YOLO Post-processing Guidelines

Guidelines for high-performance on-device neural network inference using NCNN and YOLOv8/v11 models.

---

## Scenario: YOLOv8-seg Post-processing

### 1. Scope / Trigger
- Trigger: Implementing or modifying YOLO instance segmentation post-processing in C++.

### 2. Signatures
- `void DecodeDetections(const ncnn::Mat& det_out, const ncnn::Mat& proto_out, std::vector<Detection>& dets)`
- `void Nms(std::vector<Detection>& dets, float iou_thresh)`
- `void ProcessMasks(const ncnn::Mat& proto_out, std::vector<Detection>& dets)`

### 3. Contracts
- **Input**: `det_out` (Raw logits from model), `proto_out` (Mask prototypes).
- **Activation**: Raw logits MUST be processed with Sigmoid before thresholding.
- **Lazy Decoding**: DO NOT generate 160x160 masks during `DecodeDetections`. Only generate masks for detections that survive NMS.

### 4. Validation & Error Matrix
| Condition | Behavior |
|-----------|----------|
| > 2000 initial detections | Truncate and log warning (prevents $O(N^2)$ NMS hang) |
| > `kMaxDets` (100) after NMS | Truncate to top 100 (prevents compute explosion) |
| Empty detections | Return empty mask/RGBA without error |

### 5. Good/Base/Bad Cases
- **Good**: 1-10 food items detected, processed in < 100ms.
- **Base**: Complex scene with 50+ items, truncated to 100, processed without ANR.
- **Bad**: Decoding masks for all 8400 anchors before NMS (causes 3-5s freeze).

### 6. Tests Required
- **Unit**: Verify `DecodeDetections` handles raw logits correctly (Sigmoid).
- **Integration**: Verify `nativeSegment` returns a valid file path and doesn't crash on empty input.
- **Performance**: Monitor Logcat for `after NMS` count and total execution time.

### 7. Wrong vs Correct

#### Wrong
Decoding masks for every anchor inside the first loop.
```cpp
for (int i = 0; i < anchors; i++) {
    // ...
    // BAD: Heavy computation for 8400 iterations
    for (int y = 0; y < 160; y++) {
        for (int x = 0; x < 160; x++) {
            // mask calculation...
        }
    }
}
```

#### Correct
Lazy decoding after NMS and batch merging.
```cpp
// 1. Decode basic box/score only
DecodeDetections(det_out, proto_out, dets);
// 2. NMS to filter down to < 100 boxes
Nms(dets, kIouThresh);
// 3. Heavy mask processing ONLY for survivors
ProcessMasks(proto_out, dets);
```

---

## Design Decision: Batch Mask Merging

**Context**: Resizing 160x160 masks to high-resolution (e.g., 4000x3000) for multiple objects is extremely slow.

**Decision**: We merge all masks in the 160x160 coordinate space (taking the maximum value per pixel) and then perform a **single** resize operation to the original image dimensions.

**Example**:
```cpp
// 1. Combine in 160x160 space
std::vector<float> combined160(160 * 160, 0.0f);
for (const auto& d : dets) {
    for (int i = 0; i < 160 * 160; i++) {
        if (d.mask160[i] > combined160[i]) combined160[i] = d.mask160[i];
    }
}
// 2. Single high-res resize
std::vector<float> combined = ResizeMaskToOriginal(combined160, orig_w, orig_h, lb);
```

---

## Common Mistakes: Raw Logits

**Symptom**: Thousands of detections even with a 0.25 threshold.

**Cause**: YOLOv8 raw output is often in logits (e.g., -10 to +10). A threshold of 0.25 on logits is very low.

**Fix**: Apply Sigmoid `1.0 / (1.0 + exp(-logit))` before checking the threshold.
