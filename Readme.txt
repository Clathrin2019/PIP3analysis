Generation of the intensity profile heatmap of the mEGFP-tagged lipid sensor around the cell periphery from multiple cells 

Installation:
1. Set this folder as the working directory.

Usage:
1. Store images in separate folders. The image should be single-frame with single- or multi-channel.
2. Draw a cell mask for each image manually or by any program/software, and name it 'CellMask.tiff'. Make sure the mask file is binary.
3. Run 'split_channels.ijm' in Fiji to split multi-channel image into single-channel images, and create file structure for further analysis.
3. Run code 'getMiddleMask.m' in Matlab to get a eroded cell mask with given erosion width.
4. Run 'Intensity_profile.ijm' in Fiji to calculate the intensity profile along the eroded cell boundary. The profile will be saved automatically in '.csv' files.
5. Run 'plotHeatmap.m' in Matlab to generate the intensity profile heatmap.
