
Scanning Diffraction Imaging without Stable Illumination and Scan Position Information  
====================================================================================
This repository contains the MATLAB code and experimental dataset for the research article:  
"Scanning diffraction imaging without stable illumination and scan position information"  

Environment Requirements 
---------------------------  
- MATLAB 2021b or newer  
- NVIDIA GPU with >=12GB memory (CUDA compatible)  
- Required MATLAB Toolboxes:  
  * Parallel Computing Toolbox  
  * Image Processing Toolbox 

Quick Start
---------------------------  
> Open MATLAB and execute:  
>> Reconstruction_Main  

File Description
---------------------------  
Figure6 2024.5.20- the code and dataset file
|-> Data- X-ray dataset of Figure 6
|=> Support Functions - The support functions for reconstruction
|-> probe_guess - Probe function which is the input of  the algorithm
|->Reconstruction_Main - The main reconstruction function

Open source dataset
--------------------------- 
https://figshare.com/articles/dataset/Open_source_data_for_Scanning_Diffraction_Imaging_without_Stable_Illumination_and_Scan_Position_Information/28642340
Please download data from this website

Development logs
---------------------------  
09/2022 improve image quality

11/2022 try different experimental parameters

02/2023 get stable high quality image and rewrite the whole algorithm

04/2023 biological sample

09/2023 try structural beam

02/2024 add scaling gradient algorithm to enhance the positioning accuracy in low overlapped data

04/2024 data analysis for modulator calibration with only probe known

05/2024 finish analysis for whole dataset


Contact
---------------------------  
Email: taoliu_cn@outlook.com
