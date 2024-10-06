% Get eroded middle mask for each cell
% Choose a folder that contains all the single-frame images. Make sure each
% image is stored in a folder seperately. Each image should have a cell
% mask file (change mask file name on line 22).
% 
% Zhengyang An 20241006

% choose the folder
folder = uigetdir();
Contents = dir(fullfile(folder,'*'));
subFolders = setdiff({Contents([Contents.isdir]).name},{'.','..'});
subFolders = natsortfiles(subFolders);

% get eroded middle mask
width = 20; % erode width in pixel
count = 0;

for i = 1:numel(subFolders)
    path = [folder filesep subFolders{i} filesep 'IntensityProfile'];
    maskPath = [path filesep 'CellMask.tiff'];
    
    if ~exist(maskPath, 'file')
        message = ['...No cell mask found in [' subFolders{i} '].'];
        disp(message);
    
    else
        [midMask, flag, n] = MiddleMask(maskPath, width);
        count = count+n;
        
        switch flag
            case 1
                msg = ['...Object too small in [' subFolders{i} '], skipped.'];
                disp(msg)
            case 2
                msg = ['...Cell mask exists, but no object found in [' subFolders{i} '], skipped.'];
                disp(msg)
            case 3
                msg = ['...One of the objects is too small in [' subFolders{i} '], skipped.'];
                disp(msg)
        end
    end
end

disp([int2str(count) ' cell masks found.'])

function [midMask, flag, count] = MiddleMask(maskPath, width)
% Calculate and save middle cell mask to input folder
% 
% Zhengyang An, Last modified: 20220614
% 
    
    parts = strsplit(maskPath, filesep);
    folder = strjoin(parts(1:end-1), filesep);

    bw = logical(imread(maskPath));
    minObjArea = (width*2)^2;

    [L,nc] = bwlabel(bw,4);

    if nc == 1
        area = numel(find(L == 1));
        if area <= minObjArea
            flag = 1; % object too small
            count = 0;
        else
            flag = 0; % nothing wrong
            count = 1;
        end
    elseif nc == 0
        flag = 2; % no object found
        count = 0;
    else
        flag = 0;
        count = nc;
        area = zeros(1,nc);
        for x = 1:nc
            area(1,x) = sum(L(:) == x);
            if area(1,x) < 2500 % a cell must be bigger than 2500 pixels (50*50)
                bw(L == x) = 0;
                flag = 3; % one of the objects is too small and is skipped.
                count = count-1;
            end
        end
    end
    
    if count == 0
        midMask = [];
        return
    end
    
    [L2,nc2] = bwlabel(bw,4);
    SE = strel('disk',width);
    
    for j = 1:nc2
        maski = bw;
        maski(L2 ~= j) = 0;
        maski = logical(maski);
        
        midMask = imerode(maski, SE);
    
        [L,nm] = bwlabel(midMask,4);
        if nm>1 % if mask breaks
            area = zeros(1,nm);
            % find the biggest mask
            for x = 1:nm
                area(1,x) = sum(L(:) == x);
            end
            v = find(area == max(area));
            midMask(L~=v) = 0;
        end

        midMask = im2uint8(midMask);
        imwrite(midMask,[folder filesep 'Cell' int2str(j) '_mask.tif'])
    end
    
end