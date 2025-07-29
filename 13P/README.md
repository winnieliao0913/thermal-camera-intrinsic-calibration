# Thermal Camera Intrinsic Calibration

This repository contains MATLAB scripts for detecting circular objects in thermal images, verifying detections, and estimating camera parameters using a circular dot grid pattern.

---

## Prerequisites

- **MATLAB R2024b** (or newer)
- **Image Processing Toolbox**
- **Computer Vision Toolbox**

> Install these via the MATLAB Add-On Explorer before proceeding.

---

## Before You Start

- Place all thermal images for calibration in the same folder as the provided MATLAB scripts.
   1. Images should be captured from the same camera.
   2. Include **6 to 10 images** taken from different angles to ensure calibration accuracy.


## File Summary

| Script / Function                   | Description                                              |
|-------------------------------------|----------------------------------------------------------|
| `DetectCirclesInThermalImages.m`    | Detects circles in individual PNG images and exports CSVs. |
| `Verify.m`                          | Plots detected circle centers alongside reference points. |
| `World_Points.m`                    | Generates reference world coordinates for a checkerboard. |
| `reorderCentroids.m`                | Reorders detected centroids to match world grid layout.  |
| `minboundparallelogram.m`           | Computes bounding parallelogram for point sets.          |
| `p_poly_dist.m`                     | Helper: distance from points to line segments.           |
| `Parameters_Obtain_ajc.m`           | Estimates camera parameters from matched points.         |

---

## Usage Instructions

1. **Detect circles**
   1. Open `DetectCirclesInThermalImages.m`.
   2. On **line 9**, update the file pattern:
      ```matlab
      % Example:
      d = dir('10.png');  % Change '10.png' to your image file name
      ```
   3. Run the script. For each figure:
      - Draw the region of interest polygon and press `Enter`.
      - Draw a line across one circle to measure its diameter.
      - Inspect the detection window:
        - If **no** false positives/negatives appear, close the figure to proceed.
        - Otherwise, close the figure, adjust the file name on line 9, and rerun.
   4. Repeat until all images have correct detections.

2. **Verify detections**
   1. Run `Verify.m`.
   2. A multi-panel figure will display all detected centers and the world points.
   3. Confirm that detected circles align with expectations.

3. **Estimate camera parameters**
   1. Run `Parameters_Obtain_ajc.m`.
   2. The script reads your CSV outputs, reorders centroids, and computes calibration.
   3. Review the reprojection error plot and extrinsics visualization.

---

## Tips & Troubleshooting

- Ensure all helper functions (`reorderCentroids.m`, `minboundparallelogram.m`, `p_poly_dist.m`) are on your MATLAB path.
- If a script cannot find a function, confirm the file name matches exactly and is located in the working folder.
- For noisy images, adjust sensitivity and edge thresholds in `DetectCirclesInThermalImages.m`.

---

**Date:** April 2025
