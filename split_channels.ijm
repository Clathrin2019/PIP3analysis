/*   Split image channels for intensity profile analysis
 *   Zhengyang An 20210821
 *   modified on 20241006
 */

dir = getDirectory("Choose a Directory");
setBatchMode(true);
count = 0;
countFiles(dir);
n = 0;
processFiles(dir);

function countFiles(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/"))
          countFiles(""+dir+list[i]);
      else
          count++;
  }
}

function processFiles(dir) {
  list = getFileList(dir);
  for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/"))
          processFiles(""+dir+list[i]);
      else {
     	 if (list[i] == "RGB.tif"){
	         showProgress(n++, count);
	         path = dir+list[i];
	         processFile(path);
      	 }
      }
  }
}

function processFile(path) {
	open(path);
	dir = File.getParent(path);
	savePath = dir + File.separator + "IntensityProfile";
	File.makeDirectory(savePath); 
	//fn = getTitle();
	print(dir);
	getDimensions(width, height, channels, slices, frames);
	
	for (i = 0; i < channels; i++) {
		selectWindow("RGB.tif");
		channelNumber = i+1;
		run("Duplicate...", "duplicate channels=channelNumber");
		rename("Ch"+channelNumber);
		saveAs("Tiff", savePath + File.separator + "Ch"+channelNumber+".tif");
		close("Ch"+channelNumber);
	}
    close("RGB.tif");
}

