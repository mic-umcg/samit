---
layout: page
title: SPM Manual
---

The aim of this toolbox is to facilitate the construction of new tracer specific templates and the subsequent voxel-based and/or volume-of-interest based analysis of small animal PET and SPECT brain images. After its installation, the SAMIT toolbox will be available from the `toolbox` pull-down in the main SPM window.
<img src="http://s3-eu-west-1.amazonaws.com/learningspacebucket/umcgmic/images/images/000/000/258/original/samit.png?1430497543" alt="SAMIT interface" style="align:right;float:right;width:30%;margin:1em">

## Select Atlas
The first step is to define the animal species by selecting the desired atlas. This step is needed to preload some default values.

## Image pre-processing
### Spatial normalization
1. Reset orientation: This function removes any previous transformation stored in the image and prepares the image for further processing
2.	Coordinates of the “origin”: The location of the coordinates system in the image is a crucial step while handling the images. The zero or “origin” of this coordinates is usually located in bregma in small animals brains. If bregma is not properly defined in the atlas, the center of the image is an alternative reference
3.	Spatial registration. This section of the toolbox use the normalization process implemented in SPM8, and allows the selection of multiple images at once.
    1. Registration type (for further details see ‘spm_affreg’ function in SPM)
    2. Normalize multiple images

In addition to any previous registration done in VINCI, or any other software package, images can be spatially normalized in SPM. While this is not always necessary, it can be useful when a previous automatic registration was not accurate enough or to improve manual registration procedures. Remember that the best results will be obtained when the images and the target template have similar dimensions.

>Take in consideration that initial alignment between the images must be within about 4 cm and about 15 degrees in order for SPM to find the optimal solution.

### Normalize uptake
This section allows the normalization of the uptake in multiple images at once. This procedure has two steps.

1. Create the table: The input file can be created manually or with the help of `Create table` button. It will ask for the images to be normalized and it will generate a template file. The content of this file can be filled with any text or spreadsheet editor, and saved as tabulated file (*.txt*) or Excel file (*.xls / .xlsx*).
   1. First column: Full path and name of the image
   2. Second column: Activity of the injected tracer (MBq)
   3. Third column: Animal body weight (gr)
   4. Fourth column: glucose level in blood (mmol/l)
   <img src="http://s3-eu-west-1.amazonaws.com/learningspacebucket/umcgmic/images/images/000/000/259/original/samit_-_table.png?1430498605" alt="SUV Table" stye="align:center;margin:1em">

2. Construction of new images
   1. Image units: Select the units of the uptake represented in the image. 
   2.	Normalization type: 
     * SUV (Standardized Uptake Values). Default option. The new image will have the suffix **–SUV**
     * SUVglc (SUV corrected for blood glucose level).  The new image will have the suffix **–SUVglc**
     * SUV whole brain. The SUV will be corrected for the mean uptake value of the whole brain. The new image will have the suffix **–SUVw**
     * IDg (Percentage of injected dose per gram).  The new image will have the suffix **–IDg**
3. Basal Glucose Plasma. This is the reference value for the glucose level
4. Create normalized images. The program will ask for the file containing the table with all the information needed for the construction of the new images according to the parameters previously selected.

### Apply whole brain mask
A new image will be created in the same location as the original one, removing the signal from the outside of the brain. The new images will have the prefix ‘m’ 

## Templates
The construction process to obtain tracer-specific PET and SPECT templates has been automatized, as described in [Vallez Garcia et al. 2015](http://dx.doi.org/10.1371/journal.pone.0122363). The program assumes that the images are already aligned between them in space and in its uptake. The first selected image will be defined as the reference, and all the other images will be aligned to this one in the first step of the template construction. It is recommended to check the images that will be used for the construction of the template with Check Image Registration (`Check Reg`) in SPM, to select the most appropriate reference image and to confirm that the images are correctly aligned between them.

The steps performed by the program are:

1. Spatial normalization of the selected images to the first one
2. Construction of a mean symetrical image
3. Co-registration of the symmetrical image to the reference MRI template
4. Co-registration of the images used for the construction of the template with the parameters obtained in the previous step. This new images are saved with a prefix **r** and can be used for the evaluation of the template
5. The final version of the template and its registration with the MRI is displayed

Several files will be created when the construction of the template is completed:

- *NameTemplate*_coreg.mat The co-registration matrix obtained in the step 3
- *NameTemplate*_MRI_Size.nii. The new template with the same dimensions and voxel size as the reference MRI
- *NameTemplate*_Original_Size.nii. The same template as before but preserving the original dimensions of the image. The co-registration matrix is stored in the file. This image can be used for the construction of other versions of the template with different dimension size.

The evaluation of the registration accuracy of the images to the template can be performed by selecting `Evaluation of the template` in SAMIT. The previously constructed template must be selected (*_MRI_Size.nii*), followed by the new version of the images used for the construction of the template.

## VOI Analysis
The purpose of this function is to facilitate the extraction of the mean values from the images for further volume of interest (VOI) analysis. The program will ask you for the image containing the VOIs, followed by the image(s) from which to calculate the values. The results will be saved in a tabulated text file (\*.txt) and in a Matlab file (\*.mat).
