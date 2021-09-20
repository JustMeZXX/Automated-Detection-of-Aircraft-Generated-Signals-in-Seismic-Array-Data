### Dataset
The mulit-camera night time traffic surveillance datasets used in this paper can be downloaded from: [Dataset](https://drive.google.com/drive/folders/13jOnlugcSmGpu27-i477cq_AxN1kuV3X?usp=sharing). 

The dataset consists of synchronized front and rear-view night time traffic surveillance videos which are recorded by two iPhone 8 with 1920×1088 resolutions at 30 FPS. The captured videos are in both sparse and dense traffic situations, within which two lighting conditions, e.g., low and dark, are separately provided by adjusting the iPhone lens exposure time. These videos are provided as .avi files in folder "./videos". 

The vehicles at each 1-minute video (1800 frames) are all carefully annotated, where a vehicle contour (in polygon) at each frame is labeled as a 4x3 matrix. The matrix rows reprenset vertices of a vehicle contour in an anti-clockwise direction. The vehicle identies are given in the first column, and the x-y coordinates of vertices are given in the second and third columns. These polygon annotations are provided as .mat files in folder "./labels/vehicle_contour_polygon". 

Also, the annotations of vehicle headlights and taillights at each 1-minute video are provided, where a vehicle headlight or taillight (in bbox) at each frame is labeled as a 1x4 vector [left, top, width, height]. These bbox annotations are provided as .mat files in folder "./labels/headlight_and_taillight_bbox". 

The traffic monitoring ROI of both front and rear views are provided in "ROI.mat", where the x-y coordinates of each ROI are given in the first and second columns. In addition, the front and rear traffic landmarks are visible and can be obtained from "landmarks_front.avi" and "landmarks_rear.avi", respectively.
