/*   For single images analysis
 *   Get intensity profile along cell boundary
 *   Choose a folder contains all the single-frame images, 
 *   will save profile information as .csv file.
 *   Zhengyang An
 *   20211118
 */

dir = getDirectory("Choose a Directory");
setBatchMode(true);

list = getFileList(dir);
channel = 2;

run("Line Width...", "line=40");

for (i = 0; i < list.length; i++) {
	if (endsWith(list[i], "/")){
		print(list[i]);
		files = getFileList(dir+list[i]+"IntensityProfile");
		nMask = 0;
		for (j = 0; j < files.length; j++) {
		    if (endsWith(files[j], "_mask.tif")){
		    	nMask++;
		    }
		}
		print(nMask);
		
		maskPaths = newArray(nMask);
		imgPath = newArray(1);
		
		x = 0;
		for (k = 0; k < files.length; k++) {
		    if (endsWith(files[k], "_mask.tif")){
		    	maskPaths[x] = dir+list[i]+"IntensityProfile"+File.separator+files[k];
		    	x++;
		    }
		    if (endsWith(files[k], "Ch"+channel +".tif")){
	      		imgPath = dir+list[i]+"IntensityProfile"+File.separator+files[k];
	        }
		}

		for (jj = 0; jj < nMask; jj++){
			maskPath = maskPaths[jj];
	    	getIntProfile(imgPath,maskPath,jj+1,channel);
		}
	}
}

function getIntProfile(imgPath,maskPath,n,channelNumber) {
	run("Clear Results");
	dir = File.getParent(imgPath); 
	open(maskPath);
	run("Create Selection");
//	run("Make Inverse");
	open(imgPath);
	run("Restore Selection");
	
	run("Area to Line");
	Stack.setXUnit("pixel");
	Stack.setYUnit("pixel");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

	// save boundary region mask
	run("Create Mask");
	run("Options...", "iterations=1 count=1 black do=Nothing");
	selectWindow("Mask");
	saveAs("Tiff", dir + File.separator + "BoundaryMask_" + n + ".tif");
	close();

	// get intensity profile
	profile = getProfile();
    for (i=0; i<profile.length; i++){
      setResult("Value", i, profile[i]);
      updateResults;
    }
    saveAs("Results", dir + File.separator + "IntensityProfile_Ch" + channelNumber + "_" + n + ".csv");
    
    run("Close All");
}

